FROM debian:bookworm

RUN apt-get update && apt-get install -y redis-server

COPY --chmod=755 tools/rds-entrypoint.sh .

COPY --chmod=744 conf/redis.conf /etc/redis/redis.conf

CMD ["./rds-entrypoint.sh"]
