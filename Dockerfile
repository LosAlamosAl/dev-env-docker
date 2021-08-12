FROM debian:buster-slim

RUN adduser --home /home/devboy --no-create-home devboy \
    && usermod -aG sudo devboy \
    && mkdir /home/devboy \
    && chown devboy /home/devboy \
    && chgrp devboy /home/devboy

RUN apt-get update \
    && apt-get -y install --no-install-recommends bash git ssh openssh-client ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN update-ca-certificates

USER devboy
WORKDIR /home/devboy
#RUN git clone -c http.sslverify=false https://github.com/losalamosal/cy-max.git
RUN git clone https://github.com/losalamosal/cy-max.git
