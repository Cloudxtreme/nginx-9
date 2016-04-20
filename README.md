# nginx simple semi-automated reverse proxy

Simply mount your volume or a directory as `/etc/nginx/conf.d` to the container,
it will automatically detect the differences in there and load-up the new configuration!


**docker-compose.yml** file example
```
version '2'

networks:
  backend: {}
  frontend: {}

services:
  nginx:
    image: andrey01/nginx
    networks:
      - backend
      - frontend
    volumes:
      - /home/docker/configs/letsencrypt:/etc/letsencrypt:ro
      - /home/docker/configs/nginx:/etc/nginx/conf.d:ro
    ports:
      - 80:80
      - 443:443
    restart: always
```

Then you can add some configuration to the `/home/docker/configs/nginx` directory,
for example you may add the following config:

**webmail.conf** file example
```
server {
  listen 80;
  server_name webmail.mydomain.com;
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl http2;
  server_name webmail.mydomain.com;
  ssl on;
  ssl_certificate /etc/letsencrypt/live/mydomain.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/mydomain.com/privkey.pem;

  # enable HSTS (HTTP Strict Transport Security) to avoid SSL stripping
  add_header Strict-Transport-Security "max-age=15768000; includeSubdomains" always;

  # Built-in Docker's DNS server
  resolver 127.0.0.11:53 ipv6=off valid=10s;
  set $upstream_endpoint http://webmail:8080;

  location / {
    proxy_pass $upstream_endpoint;
    proxy_redirect off;
    proxy_buffering off;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
```

You can have your `webmail` service running in the `backend` network, of which the nginx will take care of and pass it to the frontend.

