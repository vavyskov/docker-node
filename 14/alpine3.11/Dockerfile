## 14-0.68.0 | 14-dev-0.68.0
ARG WODBY_NODE_TAG="14-0.68.0"

FROM wodby/node:${WODBY_NODE_TAG}

ENV PROXY_SERVER ${UNSET}

USER root

## Initialize container
COPY config/entrypoint-vavyskov.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/entrypoint-vavyskov.sh
ENTRYPOINT ["entrypoint-vavyskov.sh"]

USER node

#CMD ["node"]
