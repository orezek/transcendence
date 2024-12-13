FROM postgres:15

# Set up environment variables for initialization
ENV POSTGRES_USER=auth_user
ENV POSTGRES_PASSWORD=securepassword
ENV POSTGRES_DB=auth_db

# Copy initialization scripts into the image
COPY ./init /docker-entrypoint-initdb.d/

# Expose the PostgreSQL default port
EXPOSE 5432
