#! /bin/bash

NginxURI="http://nginx/nginx_status" #Example: http://172.17.42.1/nginx_status



function run {
	sudo docker run --name nginx_exporter -d -p 9113:9113 \
		--link nginx-nv:nginx \
		fish/nginx-exporter -nginx.scrape_uri="$NginxURI"
}

function start {
	docker start nginx_exporter
}

function stop {
	docker stop nginx_exporter
}

function delete {
	stop
	docker rm nginx_exporter
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
