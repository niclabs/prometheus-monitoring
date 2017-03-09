#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function run {
	for exporter in ${exporters[@]}; do
		cd $DIR/$exporter
		./run.sh run
	done
	cd $DIR
}

function start {
	for exporter in ${exporters[@]}; do
		cd $DIR/$exporter
		./run.sh start
	done
	cd $DIR
}

function stop {
	for exporter in ${exporters[@]}; do
		cd $DIR/$exporter
		./run.sh stop
	done
	cd $DIR
}

function delete {
	for exporter in ${exporters[@]}; do
		cd $DIR/$exporter
		./run.sh delete
	done
	cd $DIR
}

function restart {
	stop $1
	start
}

function usage {
    echo "Usage: $0 start | restart | stop | delete <exporter_list>";
		echo "Where <exporter_list> is a comma separated list which may contain:"
		echo "blackbox, cadvisor, nginx, node, postgres or 'all'"
    exit 1;
}

function parse_list () {
	list=$(echo $1 | tr "," "\n")
	for exporter in $list;do
			case "$exporter" in
					blackbox) exporters+=("blackbox_exporter") ;;
					cadvisor) exporters+=("cAdvisor_exporter") ;;
					nginx) exporters+=("nginx_exporter") ;;
					node) exporters+=("node_exporter") ;;
					postgres) exporters+=("postgres_exporter") ;;
					all) exporters=('blackbox_exporter' 'cAdvisor_exporter' \
					 'nginx_exporter' 'node_exporter' 'postgres_exporter') ;;
			    *) usage ;;
			esac
	done
}

parse_list $2
case "$1" in
		run) run ;;
    start) start ;;
    restart) restart ;;
    stop) stop ;;
    delete) delete ;;
    *) usage ;;
esac
