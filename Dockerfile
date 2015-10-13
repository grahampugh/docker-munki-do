# Use phusion/passenger-full as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/passenger-full:0.9.17
MAINTAINER Graham Pugh <g.r.pugh@gmail.com>

# Set correct environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV APP_DIR /home/app/munkido
ENV TIME_ZONE America/New_York
ENV APPNAME Munki-Do

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Install python
RUN apt-get update && apt-get install -y \
  python-pip \
  python-dev \
  libpq-dev

RUN git clone https://github.com/munki/munki.git /munki-tools
RUN git clone https://github.com/grahampugh/munki-do.git $APP_DIR  #force28
ADD django/requirements.txt $APP_DIR/
RUN mkdir -p /etc/my_init.d
RUN pip install -r $APP_DIR/requirements.txt
ADD django/ $APP_DIR/munkido/
#ADD nginx/nginx-env.conf /etc/nginx/main.d/
ADD nginx/munkido.conf /etc/nginx/sites-enabled/munkido.conf
ADD run.sh /etc/my_init.d/run.sh
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-enabled/default
RUN groupadd munki
RUN usermod -g munki app

VOLUME ["/munki_repo", "/home/app/munkido" ]
EXPOSE 80

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
