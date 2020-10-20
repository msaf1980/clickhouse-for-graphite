#!/bin/sh

DIR="$( dirname $0 )"
cd $DIR || exit 1

mkdir log data

docker run -d --name clickhouse-graphite \
     --ulimit nofile=262144:262144 \
     -p 127.0.0.1:8123:8123 -p 127.0.0.1:9000:9000 \
     -v ${PWD}/log:/var/log/clickhouse-server \
     -v ${PWD}/data:/var/lib/clickhouse \
     -v ${PWD}/rollup.xml:/etc/clickhouse-server/config.d/rollup.xml \
     -v ${PWD}/init.sql:/docker-entrypoint-initdb.d/init.sql \
     yandex/clickhouse-server:19.17.10.1
