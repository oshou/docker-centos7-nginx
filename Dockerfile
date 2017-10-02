# pull base image
FROM centos:7

# locale & timezone
RUN sed -i -e "s/LANG=\"en_US.UTF-8\"/LANG=\"ja_JP.UTF-8\"/g" /etc/locale.conf && \
    cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# system update
RUN  yum -y update

# install repository
COPY conf/nginx.repo /etc/yum.repos.d/nginx.repo
RUN  yum install -y epel-release && \
     rpm -Uvh http://www.city-fan.org/ftp/contrib/yum-repo/city-fan.org-release-1-13.rhel7.noarch.rpm && \
     rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

# install packages
RUN  yum install -y \
        #  Tools
        less \
        libcurl \
        net-tools \
     yum install -y --enablerepo=nginx \
        # nginx
        nginx && \
     # cache cleaning
     yum clean all

# nginx
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/vhost-phpfpm.conf /etc/nginx/conf.d/vhost-phpfpm.conf
COPY ./conf/vhost-unit.conf /etc/nginx/conf.d/vhost-unit.conf

# document root
RUN groupadd --gid 1000 www-data && \
    useradd www-data --uid 1000 --gid 1000 && \
    mkdir -p /var/www && \
    chmod -R 755 /var/www && \
    chown -R www-data:www-data /var/www

# listen port
EXPOSE 80

# startup
CMD nginx
