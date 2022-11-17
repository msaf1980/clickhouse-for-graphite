#!/bin/sh

NAME=clickhouse-graphite

IMAGE="clickhouse/clickhouse-server"
VERSION="22.10"

#IMAGE="yandex/clickhouse-server"
#VERSION="19.17.10.1"

DIR="$( dirname $0 )"
[ "${DIR}" == "." ] && DIR="`pwd`"

DATA="/data/graphite/data"

case "$1" in
start)
    docker start ${NAME}
    ;;
stop)
    docker stop ${NAME}
    ;;
restart)
    docker stop ${NAME} && docker start ${NAME}
    ;;
create)
    mkdir ${DIR}/log ${DIR}/data
    [ -d ${DIR}/data ] && \
    docker run -d --name ${NAME} \
        --ulimit nofile=262144:262144 \
        -p 127.0.0.1:8123:8123 -p 127.0.0.1:9000:9000 \
        -v ${DATA}/log:/var/log/clickhouse-server \
        -v ${DATA}/data:/var/lib/clickhouse \
        -v ${DIR}/config.xml:/etc/clickhouse-server/config.xml \
        -v ${DIR}/config.d:/etc/clickhouse-server/config.d \
        -v ${DIR}/users.xml:/etc/clickhouse-server/users.xml \
        -v ${DIR}/rollup.xml:/etc/clickhouse-server/config.d/rollup.xml \
        -v ${DIR}/init.sql:/docker-entrypoint-initdb.d/init.sql \
        ${IMAGE}:${VERSION}
    ;;
drop)
    docker inspect --format '{{.Name}}' ${NAME} 2>&1 >/dev/null && {
        docker rm ${NAME} || exit 1
    }
    rm -rf ${DIR}/log ${DIR}/data
    ;;
logs)
    docker logs ${NAME}
    ;;
logfile)
    docker exec -ti ${NAME} cat /var/log/clickhouse-server/clickhouse-server.log
    ;;    
force-drop)
    docker inspect --format '{{.Name}}' ${NAME} 2>&1 >/dev/null && {
        docker rm -f ${NAME} || exit 1
    }
    rm -rf ${DIR}/log ${DIR}/data
    ;;
client)
    docker exec -ti ${NAME} clickhouse-client
    ;;
*)
    echo "Usage: $0 {start|stop|restart|logs|logfile|create|drop|force-drop}"
    exit 2
    ;;
esac
