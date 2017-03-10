#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Edit this with the appropiate credentials
PostgresURI="postgresql://felipe:niclabs.13@postgres/res?sslmode=disable"

function run {
	sudo docker run --name postgres_exporter \
	-e DATA_SOURCE_NAME="$PostgresURI" -p 9187:9187 \
	-d --link postgres-nv:postgres \
	 wrouesnel/postgres_exporter
}

function start {
	docker start postgres_exporter
}

function stop {
	docker stop postgres_exporter
}

function delete {
	stop
	docker rm postgres_exporter
}

function usage {
    echo "Usage: $0 run | start | stop | delete";
    exit 1;
}

case "$1" in
		run) run ;;
    start) start ;;
    stop) stop ;;
    delete) delete ;;
    *) usage ;;
esac
