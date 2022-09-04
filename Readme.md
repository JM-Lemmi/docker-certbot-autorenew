# Certbot-autorenew

This container is used to renew existing certificates. Use it in conjunction original certbot/certbot container to generate new certificates.

The crontab is copied from [certbot documentation](https://eff-certbot.readthedocs.io/en/stable/using.html#automated-renewals).

Mount the same volumes you mount to certbot as read write:

- `/var/www/certbot/`
- `/etc/letsencrypt/`

## Example

### Docker standalone

`docker run -v "./certbot/www/:/var/www/certbot/:rw" -v "./certbot/conf/:/etc/letsencrypt/:rw" ghcr.io/jm-lemmi/certbot-autorenew`

Depends on an external webserver to serve the certificates and another container to generate the original certificates.

Don't forget to restart nginx to apply the new certificates!

### Docker compose

```yml
version: '3'
services:
  proxy:
    image: nginx:latest
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./conf/:/etc/nginx/conf.d/:ro"
      - "./certbot/www/:/var/www/certbot/:ro"
      - "./certbot/conf/:/etc/nginx/ssl/:ro"
  certbot:
    image: certbot/certbot:latest
    volumes:
    - "./certbot/www/:/var/www/certbot/:rw"
    - "./certbot/conf/:/etc/letsencrypt/:rw"
  certbot_renew:
    image: ghcr.io/jm-lemmi/certbot-autorenew
    depends_on:
      - proxy
    restart: unless-stopped
    volumes:
    - "./certbot/www/:/var/www/certbot/:rw"
    - "./certbot/conf/:/etc/letsencrypt/:rw"
```

#### `./conf/default.conf`

```conf
server {
    listen 80;
    listen [::]:80;

    server_name ~^(.*)\.example\.de$ ;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}
```

#### Request new certificates with

`docker-compose run --rm  certbot certonly --webroot --webroot-path /var/www/certbot/ -d sub.example.de`
