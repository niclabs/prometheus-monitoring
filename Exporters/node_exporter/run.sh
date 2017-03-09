#! /bin/bash



function run {

	docker run -d -p 9100:9100 --name node_exporter \
	  -v "/proc:/host/proc" \
	  -v "/sys:/host/sys" \
	  -v "/:/rootfs" \
	  --net="host" \
	  prom/node-exporter \
	    -collector.procfs /host/proc \
	    -collector.sysfs /host/sys \
	    -collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"
}

function start {
	docker start node_exporter
}

function stop {
	docker stop node_exporter
}

function delete {
	stop
	docker rm node_exporter
}

function usage {
    echo "Usage: $0 start | stop | delete";
    exit 1;
}

case "$1" in
    run) run ;;
    start) start ;;
    stop) stop ;;
    delete) delete ;;
    *) usage ;;
esac
