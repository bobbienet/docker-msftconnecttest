FROM openresty/openresty:alpine
RUN printf '%s\n' \
'events {}' \
'http {' \
'  server_tokens off;' \
'  default_type text/plain;' \
'  server {' \
'    listen 80 default_server;' \
'    more_clear_headers Server;' \
'    location = /connecttest.txt {' \
'      add_header Cache-Control "max-age=30, must-revalidate";' \
'      return 200 "Microsoft Connect Test";' \
'    }' \
'    location / {' \
'      return 404 "Page not found";' \
'    }' \
'  }' \
'}' > /usr/local/openresty/nginx/conf/nginx.conf
EXPOSE 80
