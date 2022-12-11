# Prometheus & Grafana notes

- https://grafana.pipe.fail/public-dashboards/b5ca7a7c8e844f90b0973d2ab02bad0a
- https://ipng.ch/s/articles/2022/11/27/mastodon-3.html
- https://ourcodeworld.com/articles/read/1686/how-to-install-prometheus-node-exporter-on-ubuntu-2004

## Exporters

- https://github.com/prometheus-community/postgres_exporter
- https://github.com/prometheus/statsd_exporter
- https://github.com/oliver006/redis_exporter
- https://github.com/prometheus/node_exporter
- https://github.com/nginxinc/nginx-prometheus-exporter
- https://github.com/prometheus-community/json_exporter

## Installation

repeat for each exporter:

```bash
wget https://github.com/oliver006/redis_exporter/releases/download/v1.45.0/redis_exporter-v1.45.0.linux-amd64.tar.gz
tar xvf redis_exporter-v1.45.0.linux-amd64.tar.gz
cp redis_exporter-v1.45.0.linux-amd64/redis_exporter /usr/local/bin/

useradd --no-create-home --shell /bin/false redis_exporter
chown redis_exporter:redis_exporter /usr/local/bin/redis_exporter

nano /etc/system/systemd/redis-exporter.service # see below

systemctl daemon-reload
systemctl enable --now redis-exporter.service
systemctl status redis-exporter.service
```

## Config

/home/mastodon/live/.env.production:

```sh
STATSD_ADDR=localhost:9125
```

---

/etc/prometheus/prometheus.yml:

```yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node_exporter_metrics"
    static_configs:
      - targets: ["localhost:9100"]

  - job_name: "redis_exporter_targets"
    static_configs:
      - targets: ["redis://localhost:6379"]
    metrics_path: /scrape
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: localhost:9121

  - job_name: "redis_exporter_metrics"
    static_configs:
      - targets: ["localhost:9121"]

  - job_name: "postgres_exporter_metrics"
    static_configs:
      - targets: ["localhost:9187"]

  - job_name: "nginx_exporter_metrics"
    static_configs:
      - targets: ["localhost:9113"]

  - job_name: "statsd_exporter_metrics"
    static_configs:
      - targets: ["localhost:9102"]

  - job_name: "elasticsearch_exporter_metrics"
    static_configs:
      - targets: ["localhost:9114"]

  - job_name: "json_exporter_metrics"
    static_configs:
      - targets: ["localhost:9079"]

  - job_name: "json_exporter_targets"
    metrics_path: /probe
    scrape_interval: 30s
    params:
      module: [linode_bucket]
    static_configs:
      - targets:
        - https://api.linode.com/v4/object-storage/buckets/us-east-1/jarvis-mastodon
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: localhost:9079

  - job_name: "json_exporter_targets"
    metrics_path: /probe
    scrape_interval: 30s
    params:
      module: [linode_transfer]
    static_configs:
      - targets:
        - https://api.linode.com/v4/account/transfer
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: localhost:9079
```

---

/etc/prometheus/json-config.yml:

```yml
modules:
  linode_bucket:
    headers:
      # https://cloud.linode.com/profile/tokens
      Authorization: "Bearer XXXXXX"
    metrics:
    - name: json_linode_size
      path: "{.size}"
      labels:
        bucket: "{.label}"
        zone: "{.cluster}"
        hostname: "{.hostname}"
    - name: json_linode_objects
      path: "{.objects}"
      labels:
        bucket: "{.label}"
        zone: "{.cluster}"
        hostname: "{.hostname}"

  linode_transfer:
    headers:
      # https://cloud.linode.com/profile/tokens
      Authorization: "Bearer XXXXXX"
    metrics:
    - name: json_linode_transfer_used
      path: "{.used}"
    - name: json_linode_transfer_quota
      path: "{.quota}"
```

---

/etc/prometheus/statsd-mapping.yml:

```yml
## Prometheus Statsd Exporter mapping for Mastodon 4.0+
##
## Version 1.0, November 2022
##
## Documentation: https://ipng.ch/s/articles/2022/11/27/mastodon-3.html

mappings:
  ## Web collector
  - match: Mastodon\.production\.web\.(.+)\.(.+)\.(.+)\.status\.(.+)
    match_type: regex
    name: "mastodon_controller_status"
    labels:
      controller: $1
      action: $2
      format: $3
      status: $4
      mastodon: "web"
  - match: Mastodon\.production\.web\.(.+)\.(.+)\.(.+)\.db_time
    match_type: regex
    name: "mastodon_controller_db_time"
    labels:
      controller: $1
      action: $2
      format: $3
      mastodon: "web"
  - match: Mastodon\.production\.web\.(.+)\.(.+)\.(.+)\.view_time
    match_type: regex
    name: "mastodon_controller_view_time"
    labels:
      controller: $1
      action: $2
      format: $3
      mastodon: "web"
  - match: Mastodon\.production\.web\.(.+)\.(.+)\.(.+)\.total_duration
    match_type: regex
    name: "mastodon_controller_duration"
    labels:
      controller: $1
      action: $2
      format: $3
      mastodon: "web"

  ## Database collector
  - match: Mastodon\.production\.db\.tables\.(.+)\.queries\.(.+)\.duration
    match_type: regex
    name: "mastodon_db_operation"
    labels:
      table: "$1"
      operation: "$2"
      mastodon: "db"

  ## Cache collector
  - match: Mastodon\.production\.cache\.(.+)\.duration
    match_type: regex
    name: "mastodon_cache_duration"
    labels:
      operation: "$1"
      mastodon: "cache"

  ## Sidekiq collector
  - match: Mastodon\.production\.sidekiq\.(.+)\.processing_time
    match_type: regex
    name: "mastodon_sidekiq_worker_processing_time"
    labels:
      worker: "$1"
      mastodon: "sidekiq"
  - match: Mastodon\.production\.sidekiq\.(.+)\.success
    match_type: regex
    name: "mastodon_sidekiq_worker_success_total"
    labels:
      worker: "$1"
      mastodon: "sidekiq"
  - match: Mastodon\.production\.sidekiq\.(.+)\.failure
    match_type: regex
    name: "mastodon_sidekiq_worker_failure_total"
    labels:
      worker: "$1"
      mastodon: "sidekiq"
  - match: Mastodon\.production\.sidekiq\.queues\.(.+)\.enqueued
    match_type: regex
    name: "mastodon_sidekiq_queue_enqueued"
    labels:
      queue: "$1"
      mastodon: "sidekiq"
  - match: Mastodon\.production\.sidekiq\.queues\.(.+)\.latency
    match_type: regex
    name: "mastodon_sidekiq_queue_latency"
    labels:
      queue: "$1"
      mastodon: "sidekiq"
  - match: Mastodon\.production\.sidekiq\.(.+)
    match_type: regex
    name: "mastodon_sidekiq_$1"
    labels:
      mastodon: "sidekiq"
```

---

(example) /etc/systemd/system/redis-exporter.service:

```
[Unit]
Description=Redis Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=redis_exporter
Group=redis_exporter
Type=simple
ExecStart=/usr/local/bin/redis_exporter
Restart=always

[Install]
WantedBy=multi-user.target
```

---

/etc/grafana/grafana.ini:

```ini
[server]
http_addr =
http_port = 3003
root_url = https://grafana.pipe.fail

[analytics]
reporting_enabled = false
check_for_updates = false
check_for_plugin_updates = false
feedback_links_enabled = false

[security]
disable_initial_admin_creation = true
disable_gravatar = true
cookie_secure = true

[snapshots]
external_enabled = false

[dashboards]
versions_to_keep = 100

[users]
allow_sign_up = false
default_theme = dark

[auth]
disable_login = true
disable_login_form = true

[auth.grafana_com]
enabled = true
allow_sign_up = false
client_id =
client_secret =
scopes = user:email
allowed_organizations =

[metrics]
enabled = false

[live]
max_connections = 10

[feature_toggles]
publicDashboards = true
```
