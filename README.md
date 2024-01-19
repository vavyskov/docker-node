# docker-node

Supported tags and respective `Dockerfile` links:
- [`20-1.0.0`](https://github.com/vavyskov/docker-node/tree/master/20/alpine3.19)
  - node: 20.11.0
  - npm/npx: 10.2.4
  - yarn/yarnpkg: 1.22.19
- [`18-1.0.1`](https://github.com/vavyskov/docker-node/tree/master/18/alpine3.18)
  - node: 18.17.1
  - npm/npx: 9.6.7
  - yarn/yarnpkg: 1.22.19

Other:
- sendmail:
  - ssmtp

System tools:
- ghostscript
- bash
- mariadb-client
- postgresql-client

Multi-services:
- supervisor
  - sshd
  - crond
    - edit and restart cron service in container:
      ```
      vi /etc/crontabs/root
      /usr/sbin/crond restart
      ```
  - node /var/www/html/build/index.js

---

Get Node.js and NPM version:
- LTS
  - `docker pull node:lts-alpine`
  - `docker run --rm node:lts-alpine node -v`
  - `docker run --rm node:lts-alpine npm -v`
  - `docker run --rm node:lts-alpine yarn -v`
- Current
  - `docker pull node:current-alpine`
  - `docker run --rm node:current-alpine node -v`
  - `docker run --rm node:current-alpine npm -v`
  - `docker run --rm node:current-alpine yarn -v`

Build and push example:
```
cd docker-node/20/alpine3.19
docker build -t vavyskov/node:20-1.0.0 .
(docker build --build-arg NODE_VERSION=20.11.0 -t vavyskov/node:20-1.0.0 .)
docker push vavyskov/node:20-1.0.0
```

Image test example:
```
docker run -d vavyskov/node:20-1.0.0
docker container ls
docker exec -it <CONTAINER-ID> sh
  node --version
  npm --version
  yarn --version
  exit
```

ToDo:
- supervisor (PORT=80 node build/index.js)
