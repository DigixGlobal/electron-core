# Electron Core

Checkout the
[wiki](https://wiki.digixdev.com/electron-development#electron-core
"Electron Core Wiki") for more of a comprehensive guide

## Installation

To quickly setup with `docker`, do the following:

```
docker network create electron

docker-compose build
docker-compose run web bundle install
docker-compose run web rake db:drop db:create db:migrate db:seed
docker-compose up
```

For the development, checkout the wiki.
