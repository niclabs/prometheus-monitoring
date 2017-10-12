#! /bin/bash

function usage {
    echo "Usage: $0 run | start | restart | stop | delete ";
    exit 1;
    }

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
grafana_pass="niclabs.13"

function run {
    # run the docker containers
    ## Telegram Bot
    cd $DIR/prometheus_bot
    docker build --tag telegram-bot .
    cd $DIR
    docker run -v $(pwd)/prometheus_bot:/bot/prometheus_bot/config --name telegram-bot \
	  --restart=always -d telegram-bot -c /bot/prometheus_bot/config/config.yaml -d

    ## Alertmanager
    docker run -d -p 9093:9093 --name alertmanager \
    --link telegram-bot:telegram-bot  --restart=always \
    -v /etc/localtime:/etc/localtime:ro  \
    -v $DIR/alertmanager:/etc/alertmanager/config \
    prom/alertmanager -config.file=/etc/alertmanager/config/config.yml

    ## Prometheus Server
    docker run -d -p 9090:9090 --name prom-server \
    --link alertmanager:alertmanager  --restart=always \
    --link blackbox:blackbox \
    -v /etc/localtime:/etc/localtime:ro  \
    -v $DIR/prometheus:/etc/prometheus \
    -v $DIR/storage:/prometheus \
    prom/prometheus -alertmanager.url=http://alertmanager:9093 \
    -config.file=/etc/prometheus/prometheus.yml \

    ## Grafana
    docker run -d -p 3000:3000 --name grafana \
    -e "GF_SECURITY_ADMIN_PASSWORD=$grafana_pass" \
    --link prom-server:prom-server --restart=always \
    grafana/grafana:4.5.2
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
  http://admin:$grafana_pass@127.0.0.1:3000/api/datasources
}

function add_dashboard () {
  echo "Adding dashboard from $1"
  echo "{\"dashboard\": `cat $1` , \
   \"inputs\": [{\"name\": \"DS_PROMETHEUS\", \
              \"pluginId\": \"prometheus\", \"type\": \"datasource\", \
              \"value\":\"Prometheus\"}], \
   \"overwrite\": true}" | curl --output /dev/null --silent \
  -H "Content-Type: application/json" -X POST \
  -d @- http://admin:$grafana_pass@127.0.0.1:3000/api/dashboards/import
}


function stop {
    #Stop the aplication
    docker stop telegram-bot alertmanager prom-server grafana
}

function start {
    #start the aplication
    docker start telegram-bot alertmanager prom-server grafana
}

function restart {
    #restart the aplication
    docker restart telegram-bot alertmanager prom-server grafana
}

function delete {
    #Stop application and delete all data
    stop;
    docker rm -f telegram-bot alertmanager prom-server grafana
}

function reload_config {
    # Reload configuration
    alertmanager_ip=$(docker inspect --format={{.NetworkSettings.IPAddress}} alertmanager)
    curl -X POST http://$alertmanager_ip:9093/-/reload
    prometheus_ip=$(docker inspect --format={{.NetworkSettings.IPAddress}} prom-server)
    curl -X POST http://$prometheus_ip:9090/-/reload
    docker restart telegram-bot
}

case "$1" in
    run) run ;;
    start) start ;;
    restart) restart ;;
    stop) stop ;;
    delete) delete ;;
    reload) reload_config ;;
    *) usage ;;
esac
