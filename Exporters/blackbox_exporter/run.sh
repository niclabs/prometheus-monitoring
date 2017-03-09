#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function run {
	sudo docker run -d --name blackbox \
       --read-only \
       -p 9115:9115 \
       -v $DIR/blackbox.yml:/etc/blackbox_exporter/config.yml \
       prom/blackbox-exporter
}

function start {
	docker start blackbox
}

function stop {
	docker stop blackbox
}

function delete {
	stop
	docker rm blackbox
}

function usage {
    echo "Usage: $0 start | restart | stop | delete";
    exit 1;
}

case "$1" in
		run) run ;;
    start) start ;;
    stop) stop ;;
    delete) delete ;;
    *) usage ;;
esac
