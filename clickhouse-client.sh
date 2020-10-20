#!/bin/sh

exec docker exec -it clickhouse-graphite clickhouse client
