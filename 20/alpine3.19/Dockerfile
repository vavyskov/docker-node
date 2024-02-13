ARG ALPINE_VERSION=3.19

## LTS
ARG NODE_VERSION=20.11.0
ARG NPM_VERSION=10.2.4

FROM node:${NODE_VERSION:+${NODE_VERSION}-}alpine${ALPINE_VERSION} AS node

ARG TZ=Europe/Prague

ENV YARN_VERSION 1.22.19

ENV TIME_ZONE ${TZ}
ENV PROJECT_MODE dev
ENV PROJECT_ROOT /var/www/html
ENV PROJECT_HOSTNAME ${UNSET}
ENV DOCUMENT_ROOT /var/www/html/public
ENV USER_HOME /var/www
ENV USER_NAME user
ENV FASTCGI_PORT 9001
ENV GIT_EMAIL my@email.com
## Equivalent ways of writing a variable: ENV GIT_NAME=My\ Name | ENV GIT_NAME="My Name"
## Attention: ENV GIT_NAME="" does not contain empty string, but contains ""
ENV GIT_NAME My Name
ENV NODE_SENDMAIL_PATH /usr/bin/msmtp -t --read-envelope-from
ENV NODE_CRONTAB ${UNSET}
ENV CERTIFICATE_CA_1 ${UNSET}
ENV SMTP_HOSTNAME ${UNSET}
ENV SMTP_PORT 1025
ENV SMTP_FROM team@example.com
## A way, how to create an unset variable
ENV SMTP_USER ${UNSET}
ENV SMTP_PASSWORD password
## Proxy server example: "http://user:password@proxy.example.com:8080"
ENV PROXY_SERVER ${UNSET}
ENV HOST_USER_ID ${UNSET}
ENV PGPASSFILE ${PROJECT_ROOT}/.pgpass.local

RUN echo "Setting the timezone..." \
&&  apk add --no-cache --virtual .build-deps \
        tzdata \
&&  cp /usr/share/zoneinfo/${TZ} /etc/localtime \
#&&  ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
&&  apk del --purge .build-deps

RUN echo "Sendmail" \
&&  apk add --no-cache msmtp
## Sendmail configuraton viz entrypoint.sh

## MongoDB - missing in oficial repository (in this repository is old version)
#RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/community' >> /etc/apk/repositories \
#&&  apk add --no-cache \
#        mongodb \
#        mongodb-tools

RUN echo "System tools" \
&&  apk add --no-cache \
        ## Certificates
        ca-certificates \
        openssl \
        ## Users
        shadow \
        ## Wordpress
        ghostscript

## ---------------------------------------------------------------------------------------------------------------------

FROM node AS node-ssh

RUN echo "SSH" \
&&  apk add --no-cache \
        ## openssh-server + openssh-client + openssh-sftp-server
        openssh \
        #bash \
&&  ssh-keygen -A \
#&&  sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
&&  sed -i 's/#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config

RUN echo "System tools" \
&&  apk add --no-cache \
        ## Users
        shadow \
        git \
        ## The default busybox wget cannot handle (https) proxies
        wget \
        #patch \
        #curl \
        #tar \
        zip \
        #unzip \
        vim \
        mc

RUN echo "GitLab (The SSH runner executor supports only scripts generated in Bash.)" \
&&  apk add --no-cache \
        bash

RUN echo "Database clients" \
&&  apk add --no-cache \
        mariadb-client \
        postgresql-client

#RUN echo "npm nodejs yarn" \
#&&  apk add --no-cache \
#        npm \
#        nodejs \
#&&  npm install -g yarn

RUN echo "node nodejs npm pnx yarn yarnpkg" \
&&  mv /usr/local/bin/node /usr/bin/node \
&&  rm /usr/local/bin/nodejs \
&&  ln -s /usr/bin/node /usr/bin/nodejs \
&&  rm /usr/local/bin/npm \
&&  ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm \
&&  rm /usr/local/bin/npx \
&&  ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/bin/npx \
&&  rm /usr/local/bin/yarn \
&&  ln -s /opt/yarn-v${YARN_VERSION}/bin/yarn /usr/bin/yarn \
&&  rm /usr/local/bin/yarnpkg \
&&  ln -s /opt/yarn-v${YARN_VERSION}/bin/yarnpkg /usr/bin/yarnpkg

## ---------------------------------------------------------------------------------------------------------------------

FROM node-ssh AS node-cron

## ---------------------------------------------------------------------------------------------------------------------

## Initialize container
COPY config/entrypoint.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
#ENTRYPOINT	[ "entrypoint.sh", "docker-node-entrypoint" ]

## node-ssh
#WORKDIR /var/www/html

WORKDIR ${PROJECT_ROOT}

## node
#EXPOSE 5173 3000 80

## node-ssh
#EXPOSE 22

EXPOSE 22

## node-ssh
#CMD ["/usr/sbin/sshd", "-D"]
## node-cron
#CMD ["/usr/sbin/crond", "-f", "-d", 0]

## Default service
#CMD ["/usr/sbin/sshd", "-D"]

## ---------------------------------------------------------------------------------------------------------------------

RUN echo "Multi-services" \
&&  mkdir -p /var/log/supervisor \
&&  chown -R node:node /var/log/supervisor \
&&  apk add --no-cache \
        supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
