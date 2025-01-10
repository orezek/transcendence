FROM nginx:latest
RUN mkdir -p /var/www/proxy_service/static && mkdir -p /var/www/proxy_service/frontend
COPY nginx.conf /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]
