# Use the official Ruby image
FROM ruby:latest
# Set the working directory inside the container
WORKDIR /usr/src/app
RUN apt-get update && apt-get install -y iputils-ping
RUN gem install bundler
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
# Ensure PostgreSQL client tools are installed
RUN apt-get update && apt-get install -y libpq-dev
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# Set the default command to run the Ruby script
CMD ["ruby", "./auth_service.rb", "-o", "0.0.0.0"]
