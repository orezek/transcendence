FROM nginx:latest
RUN mkdir -p /var/www/proxy_service
COPY nginx.conf /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]
