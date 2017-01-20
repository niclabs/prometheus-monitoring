#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function start_postgres_exporter {

	# Below edit the database name, the user, the password, hostname and the port with our values.

	sudo docker run --name postgres_exporter -e DATA_SOURCE_NAME="postgresql://login:password@hostname:port/dbname?sslmode=disable" -p 9187:9187 wrouesnel/postgres_exporter &
}

function stop_postgres_exporter {

	docker stop postgres_exporter
}

function remove_postgres_exporter {
	
	docker rm postgres_exporter
}

function start_nginx_exporter {
	
	# Below edit nginx.scrape_uri with your Nginx JSON format status page.

	cd "$DIR/nginx_exporter"
	./bin/nginx-vts-exporter -nginx.scrape_uri=http://localhost/status/format/json &
	
}

function start_prometheus {
	
	cd "$DIR/prometheus"
	./prometheus -config.file=prometheus.yml -alertmanager.url http://localhost:9093 &
}

function stop_prometheus {
	
	killall prometheus
	
}


function start_alertmanager {

	cd "$DIR/alertmanager"
	./alertmanager -config.file=config.yaml &
}

function stop_alertmanager {
	
	killall alertmanager
}

function start_grafana {

	cd "$DIR/grafana"
	./bin/grafana-server web &
}

function stop_grafana {
	
	killall grafana-server
}

function start_telegram_bot {

	cd "$DIR/prometheus_bot"
	./prometheus_bot telegram_bot &
}

function stop_telegram_bot {
	
	killall prometheus_bot
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
	    -collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"	
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
		google/cadvisor:latest
}

function stop_cadvisor {

	docker stop cadvisor
}

function remove_cadvisor {

	docker rm cadvisor
}	


function start {

	start_prometheus
	start_alertmanager
	start_grafana
	start_nodeexporter
	start_cadvisor
	start_postgres_exporter
	start_telegram_bot
	
}

function stop {

	stop_prometheus
	stop_alertmanager
	stop_grafana
	stop_nodeexporter
	stop_cadvisor
	stop_postgres_exporter
	stop_telegram_bot

}

function remove {

	remove_cadvisor
	remove_nodeexporter
	remove_postgres_exporter

}

function restart {

	stop
	start
}

function upgrade {

	remove
	start
}

function usage {
    echo "Usage: $0 start | restart | stop | remove | upgrade";
    exit 1;
    }


case "$1" in
    start) start ;;
    restart) restart ;;
    stop) stop ;;
    remove) remove ;;
    upgrade) upgrade ;;
    *) usage ;;
esac