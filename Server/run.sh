#! /bin/bash

function usage {
    echo "Usage: $0 run | start | restart | stop | delete ";
    exit 1;
    }

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function run {
    # run the docker containers
    ## Alertmanager
    docker run -d -p 9093:9093 --name alertmanager \
    -v $DIR/alertmanager/config.yml:/etc/alertmanager/config.yml \
    prom/alertmanager

    ## Telegram Bot
    ## TODO add telegram bot

    ## Prometheus Server
    docker run -d -p 9090:9090 --name prom-server \
    -v $DIR/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
    -v $DIR/storage:/prometheus \
    prom/prometheus

    ## Grafana
    grafana_pass="secret"
    docker run -d -p 3000:3000 --name grafana \
    -e "GF_SECURITY_ADMIN_PASSWORD=$grafana_pass" \
    --link prom-server:prom-server \
    grafana/grafana
    printf "Starting Grafana "
    until $(curl --output /dev/null --silent --fail http://127.0.0.1:3000); do
      printf "."
      sleep 5
    done
    printf "\n"
    add_datasource
    dashboards_arr=($DIR/dashboards/*)
    for f in "${dashboards_arr[@]}"; do
       add_dashboard $f
    done

}

function add_datasource {
  curl --output /dev/null --silent\
  -H "Content-Type: application/json" -X POST \
  -d "{\"name\":\"Prometheus\",\"type\":\"prometheus\",\"access\":\"proxy\",\"url\":\"http://prom-server:9090\",\"basicAuth\":false}" \
  http://admin:secret@127.0.0.1:3000/api/datasources
}
function add_dashboard () {
  echo "{\"dashboard\": `cat $1` }" | curl --output /dev/null --silent\
  -H "Content-Type: application/json" -X POST \
  -d @- http://admin:secret@127.0.0.1:3000/api/dashboards/db
}

function stop {
    #Stop the aplication
    docker stop alertmanager prom-server grafana
}

function start {
    #start the aplication
    docker start alertmanager prom-server grafana
}

function restart {
    #restart the aplication
    docker restart alertmanager prom-server grafana
}

function delete {
    #Stop application and delete all data
    stop;
    docker rm -f alertmanager prom-server grafana
}

case "$1" in
    run) run ;;
    start) start ;;
    restart) restart ;;
    stop) stop ;;
    delete) delete ;;
    *) usage ;;
esac
