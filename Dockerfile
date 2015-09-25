# Use phusion/passenger-full as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/passenger-full:0.9.17
MAINTAINER Graham Pugh <g.r.pugh@gmail.com>

# Set correct environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV APP_DIR /home/app/munkiwebadmin
ENV TIME_ZONE America/New_York
ENV APPNAME MunkiWebAdmin

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Install python
RUN apt-get update && apt-get install -y \
  python-pip \
  python-dev \
  libpq-dev

RUN git clone https://github.com/SteveKueng/munkiwebadmin.git $APP_DIR
RUN cd $APP_DIR && \
    git checkout tags/v0.3
ADD django/requirements.txt $APP_DIR/
RUN mkdir -p /etc/my_init.d
RUN pip install -r $APP_DIR/requirements.txt
ADD django/ $APP_DIR/
#ADD nginx/nginx-env.conf /etc/nginx/main.d/
ADD nginx/munkiwebadmin.conf /etc/nginx/sites-enabled/munkiwebadmin.conf
ADD settings.py $APP_DIR/munkiwebadmin/
ADD run.sh /etc/my_init.d/run.sh
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-enabled/default
RUN groupadd munki
RUN usermod -g munki app

VOLUME ["/munki_repo", "/home/app/munkiwebadmin" ]
EXPOSE 80

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
