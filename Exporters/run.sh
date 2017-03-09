#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#TO EDIT
PostgresURL="postgresql://login:password@hostname:port/dbname?sslmode=disable"
NginxURI="your Nginx status page" #Example: http://172.17.42.1/nginx_status

function start_postgres_exporter {


	sudo docker run --name postgres_exporter -e DATA_SOURCE_NAME="$PostgresURL" -p 9187:9187 wrouesnel/postgres_exporter &
}

function stop_postgres_exporter {

	docker stop postgres_exporter
}

function remove_postgres_exporter {

	docker rm postgres_exporter
}

function start_nginx_exporter {


	sudo docker pull fish/nginx-exporter &

	sudo docker run --name nginx_exporter -d -p 9113:9113 fish/nginx-exporter \
    -nginx.scrape_uri="$NginxURI" &

}

function stop_nginx_exporter {

	docker stop nginx_exporter
}

function remove_nginx_exporter {

	docker rm nginx_exporter
}

function start_blackbox {

	sudo docker run -d --name blackbox \
       --read-only \
       -p 9115:9115 \
       -v $(pwd)/blackbox_exporter/blackbox.yml:/etc/blackbox_exporter/config.yml \
       prom/blackbox-exporter &
}

function stop_blackbox {

	docker stop blackbox
}

function remove_blackbox {

	docker rm blackbox
}


function start_nodeexporter {

	sudo docker run -d --name nodeexporter -p 9100:9100 \
	  -v "/proc:/host/proc" \
	  -v "/sys:/host/sys" \
	  -v "/:/rootfs" \
	  --net="host" \
	  quay.io/prometheus/node-exporter \
	    -collector.procfs /host/proc \
	    -collector.sysfs /host/sys \
	    -collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"	&
}

function stop_nodeexporter {

	docker stop nodeexporter
}

function remove_nodeexporter {

	docker rm nodeexporter
}

function start_cadvisor {

	sudo docker run \
		--volume=/:/rootfs:ro \
		--volume=/var/run:/var/run:rw \
		--volume=/sys:/sys:ro \
		--volume=/var/lib/docker/:/var/lib/docker:ro \
		--publish=8080:8080 \
		--detach=true \
		--name=cadvisor \
		google/cadvisor:latest &
}

function stop_cadvisor {

	docker stop cadvisor
}

function remove_cadvisor {

	docker rm cadvisor
}


function start {

	start_blackbox
	start_nodeexporter
	start_cadvisor
	start_nginx_exporter
	start_postgres_exporter

}

function stop {
	stop_nodeexporter
	stop_cadvisor
	stop_blackbox
	stop_nginx_exporter
	stop_postgres_exporter
}

function remove {

	remove_cadvisor
	remove_nginx_exporter
	remove_blackbox
	remove_nodeexporter
	remove_postgres_exporter

}

function restart {
	stop
	start
}

function usage {
    echo "Usage: $0 start | restart | stop | remove";
    exit 1;
}

case "$1" in
    start) start ;;
    restart) restart ;;
    stop) stop ;;
    remove) remove ;;
    *) usage ;;
esac
