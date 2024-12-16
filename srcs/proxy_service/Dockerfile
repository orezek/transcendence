FROM nginx:latest
RUN mkdir -p /var/www/proxy_service/static
COPY nginx.conf /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]
