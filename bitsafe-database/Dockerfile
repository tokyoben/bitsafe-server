FROM postgres:9.5
EXPOSE 5432
ENV POSTGRES_DB bitsafe
ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD notsafe123


WORKDIR /app

COPY *.sql /docker-entrypoint-initdb.d/

