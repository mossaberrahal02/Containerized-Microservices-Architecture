#!/bin/bash

export REDIS_PASSWORD=$(cat $REDIS_PASSWORD_FILE)

echo ">>>>>>>>>>>Starting Redis server..."
redis-server /etc/redis/redis.conf --requirepass "$REDIS_PASSWORD"
