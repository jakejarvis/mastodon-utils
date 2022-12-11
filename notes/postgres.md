# Postgres

## Optimization

- https://pgtune.leopard.in.ua/#/

### PgBouncer

- https://docs.joinmastodon.org/admin/scaling/#pgbouncer
- https://masto.host/mastodon-pgbouncer-guide/

#### Installation

creating the pgbouncer admin user:

```bash
DB_PASSWORD=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c32; echo)
echo "pgbouncer password (save this securely): $DB_PASSWORD"
echo "CREATE USER pgbouncer WITH PASSWORD '$DB_PASSWORD' CREATEDB" | sudo -u postgres psql -f -
```

#### Running database migrations

Mastodon `db:migrate`s should be pointed directly at Postgres (default port: 5432), ***not through PgBouncer***, by overriding `DB_PORT` env variable.

```bash
RAILS_ENV=production DB_PORT=5432 bundle exec rails db:migrate
```

#### Config

.env.production:

```sh
DB_HOST=localhost
DB_USER=mastodon
DB_NAME=mastodon_production
DB_PASS=

# change from postgres port (default: 5432) to pgbouncer (default: 6432)
DB_PORT=6432
# add this:
PREPARED_STATEMENTS=false
```

---

/etc/pgbouncer/pgbouncer.ini:

```ini
[databases]
mastodon_production = host=127.0.0.1 port=5432 dbname=mastodon_production user=mastodon password=

[pgbouncer]
listen_addr = localhost
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
admin_users = pgbouncer
pool_mode = transaction
max_client_conn = 100
default_pool_size = 20
```

---

/etc/pgbouncer/userlist.txt:

generate md5 hash of postgres passwords with `echo -n "pass" | md5sum`

```
"mastodon" "md5xxxxxxxx"
"pgbouncer" "md5xxxxxxxx"
```

## Connecting from TablePlus.app via Tailscale

Connect directly to Postgres (default port: 5432), ***not via PgBouncer!***

---

/etc/postgresql/15/main/postgres.conf

```
listen_addresses = '*'
```

---

/etc/postgresql/15/main/pg_hba.conf:

```
# tailscale
host   all              all             100.64.0.0/10           md5
```

---

![](https://user-images.githubusercontent.com/1703673/206910912-1dea1173-7090-47db-b964-1b4bbe0d197e.png)
