# docker-node

Supported tags and respective `Dockerfile` links:
- [`18-1.0.0`](https://github.com/vavyskov/docker-node/tree/master/18/alpine3.16)
  - node: 18.12.1
  - npm/npx: 8.19.2
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
  - node-ssh (sshd)
  - node-cron (crond)
    - edit and restart cron service in container:
      ```
      vi /etc/crontabs/root
      /usr/sbin/crond restart
      ```

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
cd docker-node/18/alpine3.16
docker build -t vavyskov/node:18-1.0.0 .
(docker build --build-arg NODE_VERSION=18.12.1 -t vavyskov/node:18-1.0.0 .)
docker push vavyskov/node:18-1.0.0
```

Image test example:
```
docker run -d vavyskov/node:18-1.0.0
docker container ls
docker exec -it <CONTAINER-ID> sh
  node --version
  npm --version
  yarn --version
  exit
```

ToDo:
- ???
