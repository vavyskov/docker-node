# docker-node

!!! Proxy server is not working !!!

Supported tags and respective `Dockerfile` links:
- [`14-1.0.0-alpine3.11`](https://github.com/vavyskov/docker-node/tree/master/14/alpine3.11) (wodby/node:14-0.68.0)
- [`14-dev-1.0.0-alpine3.11`](https://github.com/vavyskov/docker-node/tree/master/14/alpine3.11) (wodby/node:14-dev-0.68.0)

Build command example:

    docker build --build-arg WODBY_NODE_TAG=14-0.68.0 -t vavyskov/node:14-1.0.0-alpine3.11 .
    docker build --build-arg WODBY_NODE_TAG=14-dev-0.68.0 -t vavyskov/node:14-dev-1.0.0-alpine3.11 .
