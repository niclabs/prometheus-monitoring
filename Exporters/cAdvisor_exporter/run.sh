#! /bin/bash

function run {

	sudo docker run \
		-v /:/rootfs:ro \
		-v /var/run:/var/run:rw \
		-v /sys:/sys:ro \
		-v /var/lib/docker/:/var/lib/docker:ro \
		-p 8080:8080 -d --name=cadvisor \
		google/cadvisor
}

function start {
	docker start cadvisor
}

function stop {
	docker stop cadvisor
}

function delete {
	stop
	docker rm cadvisor
}


function usage {
    echo "Usage: $0 run | start | stop | delete";
    exit 1;
}

case "$1" in
		run) run ;;
    start) start ;;
    restart) restart ;;
    stop) stop ;;
    delete) delete ;;
    *) usage ;;
esac
