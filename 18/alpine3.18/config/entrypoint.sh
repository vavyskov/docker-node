#!/bin/sh
## Exit script if any command fails (non-zero status)
set -e

## node-ssh + node-cron ------------------------------------------------------------------------------------------------

## Proxy (env | grep proxy)
if [ -n "${PROXY_SERVER}" ]; then
    for i in wget curl node npm npx yarn yarnpkg
    do
        { \
            echo '#!/bin/sh'; \
            echo "export http_proxy='${PROXY_SERVER}'"; \
            echo "export https_proxy='${PROXY_SERVER}'"; \
            echo "export ftp_proxy='${PROXY_SERVER}'"; \
            echo "/usr/bin/$i \$@"; \
            echo 'unset http_proxy'; \
            echo 'unset https_proxy'; \
            echo 'unset ftp_proxy'; \
        } > /usr/local/bin/$i
        chmod +x /usr/local/bin/$i
    done
fi

## Update custom certificates
update-ca-certificates

## node-ssh ------------------------------------------------------------------------------------------------------------

## If home directory does not exist, create it
if ! [ -d "${USER_HOME}" ]; then
  mkdir -p "${USER_HOME}"
fi

## If file .profile does not exist, create it
if ! [ -f "${USER_HOME}/.profile" ]; then
  touch "${USER_HOME}/.profile"
fi

## Standard uid/gid for "www-data" for Alpine: 82, for Debian: 33
WEB_USER_ID=1000

## Set Time Zone
#TZ="Europe/Prague"
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

## Get standard web user and group
WEB_USER=$(getent passwd ${WEB_USER_ID} | cut -d: -f1)
WEB_GROUP=$(getent group ${WEB_USER_ID} | cut -d: -f1)

## Simplification
NODE_GROUP=${USER_NAME}
HOST_GROUP_ID=${HOST_USER_ID}

## Test if string is not empty
if [ -n "${HOST_USER_ID}" ]; then

    ## Test if userId is not standard webId
    if [ "${HOST_USER_ID}" != "${WEB_USER_ID}" ]; then

        # Set webUserId as hostUserId
        WEB_USER_ID=${HOST_USER_ID}

        ## Create user with hostId in container
        groupadd -g "${HOST_GROUP_ID}" "${NODE_GROUP}"

        ## node-ssh
        useradd -d "${USER_HOME}" -s /bin/sh -g "${NODE_GROUP}" -u "${HOST_USER_ID}" "${USER_NAME}"

    fi

fi

## Change home path
## From: www-data:x:82:82:Linux User,,,:/home/www-data:/sbin/nologin
## To:   www-data:x:82:82:Linux User,,,:/var/www:/sbin/nologin
## Syntax: sed -i "/SEARCH/s/FIND/REPLACE/" /etc/passwd
sed -i "/${WEB_USER_ID}/s/home\/${WEB_USER}/var\/www/" /etc/passwd

## Test if string is not empty
if [ -n "${USER_NAME}" ]; then

    ## Test if users are not the same
    if [ "${WEB_USER}" != "${USER_NAME}" ]; then

        ## Change home
        #mv /home/"${WEB_USER}" ${USER_HOME}"

        ## Change group
        ## From: www-data:x:82:www-data
        ## To:   new-group:x:82:new-group
        ## Syntax: sed -i "s/FIND/REPLACE/" /etc/group
        sed -i "s/${WEB_GROUP}:x:${WEB_USER_ID}:${WEB_GROUP}/${NODE_GROUP}:x:${WEB_USER_ID}:${NODE_GROUP}/" /etc/group

        ## Change user
        ## From: www-data:x:82:82:Linux User,,,:/var/www:/bin/sh
        ## To:   new-user:x:82:82:Linux User,,,:/var/www/bin/sh
        ## Syntax: sed -i "s/FIND/REPLACE/" /etc/passwd
        sed -i "s/${WEB_USER}:x:${WEB_USER_ID}/${USER_NAME}:x:${WEB_USER_ID}/" /etc/passwd

    fi

    ## Create symbolic link
    #ln -s /var/www/html "${USER_HOME}"/html
    #chown -h "${USER_NAME}":"${NODE_GROUP}" "${USER_HOME}"/html

#    ## Shell configuration - Proxy (env | grep proxy)
#    if [ -n "${PROXY_SERVER}" ]; then
#        ## Shell configuration (Proxy)
#        { \
#            echo "export http_proxy='${PROXY_SERVER}'"; \
#            echo "export https_proxy='${PROXY_SERVER}'"; \
#            echo "export ftp_proxy='${PROXY_SERVER}'"; \
#        } >> "${USER_HOME}"/.profile
#        chown "${USER_NAME}":"${NODE_GROUP}" "${USER_HOME}"/.profile
#    fi

fi

## Change home permission
chown -R "${USER_NAME}":"${NODE_GROUP}" "${USER_HOME}"

## TimeZone (default is Europe/Prague)
if [ "${TIME_ZONE}" = "UTC" ]; then
    rm /etc/localtime
fi

## Image mode (dev | prod)
#if [ "${PROJECT_MODE}" = "dev" ]; then
#
#else
#
#fi

## Sendmail
if [ -n "${SMTP_HOSTNAME}" ] && [ -n "${SMTP_PORT}" ] && [ -z "${SMTP_USER}" ]; then
    { \
        echo 'account default'; \
        echo "host ${SMTP_HOSTNAME}"; \
        echo "port ${SMTP_PORT}"; \
        echo "from ${SMTP_FROM}";
        echo '#syslog on'; \
        echo '#logfile /var/log/msmtp.log'; \
    } > /etc/msmtprc
else
    { \
        echo 'account default'; \
        echo "host ${SMTP_HOSTNAME}"; \
        echo "port ${SMTP_PORT}"; \
        echo "from ${SMTP_FROM}"; \
        echo '#syslog on'; \
        echo '#logfile /var/log/msmtp.log'; \
        echo 'auth login'; \
        echo "user ${SMTP_USER}"; \
        echo "password ${SMTP_PASSWORD}"; \
        echo '#tls on'; \
        echo 'tls_starttls on'; \
        echo 'tls_trust_file /etc/ssl/certs/ca-certificates.crt'; \
        echo 'tls_certcheck on'; \
    } > /etc/msmtprc

#    cat << EOF > /etc/msmtprc
#account default
#host ${SMTP_HOSTNAME}
#port ${SMTP_PORT}
#from ${SMTP_FROM}
#syslog on
#logfile /var/log/msmtp.log
#auth login
#user ${SMTP_USER}
#password ${SMTP_PASSWORD}
##tls on
#tls_starttls on
#tls_trust_file /etc/ssl/certs/ca-certificates.crt
#tls_certcheck on
#EOF

fi

## node ----------------------------------------------------------------------------------------------------------------

# If DOCUMENT_ROOT exists
if [ -d "${DOCUMENT_ROOT}" ]; then
  # If DOCUMENT_ROOT is empty
	if ! [ "$(ls -A "${DOCUMENT_ROOT}")" ]; then
     ## Insert default data
     git clone https://gitlab.com/vavyskov/webserver-info.git /tmp/webserver-info
     cp -R /tmp/webserver-info/src/. "${DOCUMENT_ROOT}"
     #rm ${DOCUMENT_ROOT}/index.html
     rm -fr /tmp/webserver-info

     ## Set permission (82 is the standard uid/gid for "www-data" in Alpine)
     chown -R "${USER_NAME}":"${NODE_GROUP}" "${DOCUMENT_ROOT}"
	fi
#else
	## Create document root
  #mkdir -p "${DOCUMENT_ROOT}"
fi

## node-ssh ------------------------------------------------------------------------------------------------------------

## Set shell for standard web user (enable login)
## From: www-data:x:82:82:Linux User,,,:/var/www:/sbin/nologin
## To:   www-data:x:82:82:Linux User,,,:/var/www:/bin/sh
## Syntax: sed -i "/SEARCH/s/FIND/REPLACE/" /etc/passwd
sed -i "/${WEB_USER_ID}/s/sbin\/nologin/bin\/sh/" /etc/passwd

## Test if string is not empty
if [ -n "${USER_NAME}" ] && [ -n "${USER_PASSWORD}" ]; then
    ## Set user password
    echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd

    if [ -n "${PROXY_SERVER}" ]; then
        ## Proxy configuration
        { \
            echo 'export PATH="/usr/local/bin:$PATH"'; \
        } >> "${USER_HOME}"/.profile
    fi

    ## Set owner and group
    chown "${USER_NAME}":"${NODE_GROUP}" "${USER_HOME}"/.profile

    ## Switch to USER_NAME user
    #su -l "${USER_NAME}"

    ## Run command as specific user (su - <username> -c "<commands>") and switch back to root user
    ## Reload changes for USER_NAME (source ~/.profile OR . ~/.profile OR . .profile)
    su - "${USER_NAME}" -c ". ${USER_HOME}/.profile"

fi

## Git
{ \
    echo '[user]'; \
    echo "    name = ${GIT_NAME}"; \
    echo "    email = ${GIT_EMAIL}"; \
    echo '[core]'; \
    echo '    autocrlf = false'; \
} > "${USER_HOME}"/.gitconfig
chown "${USER_NAME}":"${NODE_GROUP}" "${USER_HOME}"/.gitconfig

## SSH key
if [ -d "${USER_HOME}"/.shared/.ssh ]; then
    cp -R "${USER_HOME}"/.shared/.ssh "${USER_HOME}"/.ssh
    chown -R "${USER_NAME}":"${NODE_GROUP}" "${USER_HOME}"/.ssh
fi

## Postgres password file path
{ \
    echo "export PGPASSFILE='${PGPASSFILE}'"; \
} >> "${USER_HOME}"/.profile

## Set default SSH login folder
{ \
    echo "cd ${PROJECT_ROOT}"; \
} >> "${USER_HOME}"/.profile

## node-cron -----------------------------------------------------------------------------------------------------------

## Crontab
if [ -n "${NODE_CRONTAB}" ]; then
    echo "${NODE_CRONTAB}" > /etc/crontabs/root
    ## Remember to end this file with an empty new line
    echo "" >> /etc/crontabs/root
fi

## ---------------------------------------------------------------------------------------------------------------------

## Make the entrypoint a pass through that then runs the docker command (redirect all input arguments)
exec "$@"
