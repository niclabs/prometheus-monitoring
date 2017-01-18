#NicAlarming
 A monitoring solution for NicLabs projets and containers with [Prometheus](https://github.com/prometheus/prometheus), [Grafana](https://github.com/grafana/grafana), [cAdvisor](https://github.com/google/cadvisor), [NodeExporter](https://github.com/prometheus/node_exporter), [PostgresExporter](https://github.com/wrouesnel/postgres_exporter), [NginxExporter](https://github.com/hnlq715/nginx-vts-exporter) and alerting with [AlertManager](https://github.com/prometheus/alertmanager), [Bot Telegram](https://github.com/inCaller/prometheus_bot)..

## Deploy Instructions

To deploy NicAlarming:

1. Edit `run.sh`, in the file on method "start_postgres_exporter", edit the database name, the user, the password, hostname and the port with our values. For more info you can visit the link above (PostgresExporter). Also on method "start_nginx_exporter" you have to edit `-nginx.scrape_uri` with your Nginx JSON format status page

2. To configure bot to alert with telegram:
	Edit `prometheus_bot/config.yaml` with the token of your telegram bot.
	Edit `alertmanager/config.yaml` chatID with the ChatID of your group in telegram.

3. Edit `prometheus.yml` scrape_configs with your ip adresses (I recommend check out the ip adress of the containers using `docker inspect --format '{{ .NetworkSettings.IPAddress }}' container_name_or_id` and local ip adress)

4. Start the monitoring solution with

  ```shell
  $ ./run.sh start
  ```


## Content

### run.sh
Bash script to  start, restart, remove, upgrade and stop the application. The usage is:

```bash
# To build, start, restart, stop, delete, upgrade
$ ./run.sh build | start | restart | stop | delete | upgrade

```

### Dashboards

	Thanks to [dackprom](https://github.com/stefanprodan/dockprom) for the darshboards to Grafana's imports. 

### Others

For more informations you can visit all links above to answers your questions about Prometheus or his tools.
