#!/bin/sh

## Parent wodby/node container entrypoint
## https://stackoverflow.com/questions/18805073/docker-multiple-entrypoints#answer-57078300
/docker-entrypoint.sh "$@"

## Proxy (env | grep proxy)
if [ -n "${PROXY_SERVER}" ]; then

    ## "Move" symlinks from /usr/local/bin to /usr/bin
    YARN_VERSION=`yarn --version`
    rm /usr/local/bin/npm
    rm /usr/local/bin/npx
    rm /usr/local/bin/yarn
    ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm
    ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/bin/npx
    ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/bin/yarn

    for i in wget curl npm npx yarn
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

## Make the entrypoint a pass through that then runs the docker command (redirect all input arguments)
exec "$@"
