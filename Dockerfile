FROM ubuntu:20.04 AS base

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -yqq apt-utils

RUN apt-get install -y python3-pip
RUN pip install google-api-python-client google-auth-oauthlib google-auth-httplib2 oauth2client Pillow

RUN groupadd -g 1000 ubuntu
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g 1000 -G sudo -u 1000 ubuntu
RUN touch /home/ubuntu/.sudo_as_admin_successful
RUN touch /home/ubuntu/.hushlogin
USER ubuntu:ubuntu
