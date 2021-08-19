FROM debian:buster-slim

RUN adduser --home /home/devboy --no-create-home devboy \
    && usermod -aG sudo devboy \
    && mkdir /home/devboy \
    && chown devboy /home/devboy \
    && chgrp devboy /home/devboy

# Had to update certificates--git https clone was failing
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends bash zsh zip unzip less curl git jq htop gnupg2 ssh openssh-client ca-certificates \
    && update-ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g aws-cdk

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

USER devboy
WORKDIR /home/devboy
RUN zsh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || true

ENV TERM xterm
ENV SHELL /bin/zsh
RUN git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
RUN curl -fsSLO https://raw.githubusercontent.com/romkatv/dotfiles-public/master/.purepower

# All clones into the container must be public, so HTTPS is best
RUN git clone https://gist.github.com/a662f0204a310631750906edd4bd2146.git zshrc \
    && mv ./zshrc/.zshrc . \
    && rm -rf zshrc
RUN git clone https://github.com/losalamosal/cy-max.git
