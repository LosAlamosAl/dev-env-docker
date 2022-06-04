FROM debian:buster-slim

RUN adduser --home /home/devboy --shell /usr/bin/zsh --no-create-home devboy \
    && usermod -aG sudo devboy \
    && mkdir /home/devboy \
    && chown devboy /home/devboy \
    && chgrp devboy /home/devboy

# Had to update certificates--git https clone was failing
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        bash                                      \
        zsh                                       \
        zip                                       \
        unzip                                     \
        less                                      \
        httpie                                    \
        curl                                      \
        git                                       \
        jq                                        \
        htop                                      \
        gnupg2                                    \
        ssh                                       \
        groff                                     \
        python3                                   \
        python3-pip                               \
        python3-setuptools                        \
        openssh-client ca-certificates \
    && update-ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g aws-cdk

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64-2.0.30.zip" -o awscliv2.zip \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

RUN npm install -g aws-cdk@next

RUN /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"

RUN pip3 install cfn-lint

USER devboy
WORKDIR /home/devboy
RUN zsh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || true
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

RUN steampipe plugin install steampipe
RUN steampipe plugin install aws
RUN steampipe plugin install github

# Oh My ZSH installs a .zshrc. Remove so we can overwrite it when cloning dotfiles.
RUN rm ~/.zshrc

#ENV SHELL /bin/zsh    THIS IS WRONG
