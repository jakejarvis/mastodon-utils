# Brotli compression for nginx

- https://github.com/google/ngx_brotli
- https://www.atlantic.net/dedicated-server-hosting/how-to-install-brotli-module-for-nginx-on-ubuntu-20-04/
- https://linuxhint.com/enable-brotli-compression-nginx/
- https://www.bowsercache.com/blog/enable-brotli-for-nginx-on-ubuntu-20-04/#install-the-brotli-module-for-nginx

---

/etc/apt/sources.list.d/nginx.list:

```
deb [arch=amd64 signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu/ focal nginx
deb-src [arch=amd64 signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu/ focal nginx
```

---

```bash
cd /usr/local/src

apt-get source nginx
apt-get build-dep nginx -y

git clone --recursive https://github.com/google/ngx_brotli

cd nginx-1.22.1/
./configure --with-compat --add-dynamic-module=../ngx_brotli
make modules

cp ./objs/ngx_http_brotli_*.so /usr/lib/nginx/modules/
```

---

/etc/nginx/nginx.conf:

```
load_module modules/ngx_http_brotli_filter_module.so;
load_module modules/ngx_http_brotli_static_module.so;
```

---

nginx site config: ([ref](https://github.com/google/ngx_brotli#sample-configuration))

```
server {
  # ...

  brotli on;
  brotli_comp_level 4;
  brotli_static on;
  brotli_types application/atom+xml application/javascript application/json application/rss+xml
               application/vnd.ms-fontobject application/x-font-opentype application/x-font-truetype
               application/x-font-ttf application/x-javascript application/xhtml+xml application/xml
               font/eot font/opentype font/otf font/truetype image/svg+xml image/vnd.microsoft.icon
               image/x-icon image/x-win-bitmap text/css text/javascript text/plain text/xml;
  brotli_min_length 256;

  # ...
}
```

---

```bash
nginx -t
nginx -s reload
```
