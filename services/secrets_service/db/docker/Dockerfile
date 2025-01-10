FROM postgres:15

COPY ./db/init/ /docker-entrypoint-initdb.d/

RUN echo "max_connections = 200"  >> /usr/share/postgresql/postgresql.conf

