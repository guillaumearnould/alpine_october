# October CMS based on Alpine Linux, with Nginx and PHP7

***
# Infos 
1. Actually, only pgsql driver is installed
2. After first run, it's take some minutes install and configure October. 
 You can execute ```docker logs -f [october_container]``` to see the installation

***
# How to use
Example with Docker Compose:
```
version: '2'
services:

    postgresql:
        restart: always
        image: sameersbn/postgresql:9.5-4
        container_name: postgresql
        ports:
          - "5432:5432"
        environment:
          - PG_PASSWORD=adminpassword
          - DB_USER=octoberlogin
          - DB_PASS=octoberpassword
          - DB_NAME=octobercms
          - DB_EXTENSION=pg_trgm


    redis:
        restart: always
        image: sameersbn/redis:latest
        container_name: redis
        command:
          - --loglevel warning

    site:
        restart: always
        image: guillaumearnould/alpine_october:1.0
        restart: always
        container_name: october
        depends_on:
          - postgresql
          - redis
        ports:
          - "80:80"
        environment:
          - OCTOBER_DB_DRIVER=pgsql
          - OCTOBER_DB_HOST=postgresql
          - OCTOBER_DB_PORT=5432
          - OCTOBER_DB_NAME=octobercms
          - OCTOBER_DB_USER=octoberlogin
          - OCTOBER_DB_PASSWORD=octoberpassword
          - OCTOBER_BACKEND=mybackend
          - REDIS_HOST=redis
```
***