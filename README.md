# 🦣 Mastodon randomness

Random opinionated helper scripts & front-end customizations for my [personal Mastodon instance](https://fediverse.jarv.is/about) (running on [`glitch-soc`](https://github.com/glitch-soc/mastodon)). You definitely don't want to use any of this as-is — check out my more general purpose [mastodon-installer](https://github.com/jakejarvis/mastodon-installer) scripts instead.

## Notes

The [wiki of this repo](https://github.com/jakejarvis/mastodon-scripts/wiki) and the [`/etc` folder](etc/) are simply my way of not forgetting how I did something, which I do quite a bit. Refer there for random notes on PgBouncer, Grafana, etc. but **DO NOT BLINDLY COPY & PASTE** anything there without doing your own research!

- [Grafana & Prometheus](https://github.com/jakejarvis/mastodon-scripts/wiki/Prometheus-&-Grafana)
- [PgBouncer](https://github.com/jakejarvis/mastodon-scripts/wiki/Postgres-&-PgBouncer)
- [Brotli compression](https://github.com/jakejarvis/mastodon-scripts/wiki/Brotli-compression-for-nginx)

## Usage

***AGAIN, DEFINITELY DO NOT JUST RUN THIS IF YOU'RE NOT ME!!! 😊***

```sh
git clone https://github.com/jakejarvis/mastodon-scripts.git /home/mastodon/scripts

# apply vanilla patches:
cd /home/mastodon/live
git apply --allow-binary-replacement /home/mastodon/scripts/patches/*.patch

# apply glitch-only patches:
if [ -d /home/mastodon/live/app/javascript/flavours/glitch ]; then
  git apply --allow-binary-replacement /home/mastodon/scripts/patches/glitch/*.patch
fi

# compile new assets:
RAILS_ENV=production bundle exec rails assets:precompile
chown -R mastodon:mastodon /home/mastodon/{scripts,live}

# restart Mastodon:
systemctl restart mastodon-*
```

## Patches

- [`favicons.patch`](patches/favicons.patch): Use custom icon images instead of Mastodon logo
- [`robots.patch`](patches/robots.patch): Disallow search engines for all of Mastodon
- [`system-font.patch`](patches/system-font.patch): Use the system's default sans-serif font stack instead of Roboto
  - [Additional `glitch-soc` patch](patches/glitch/system-font.patch)
- [`hide-contact-email.patch`](patches/hide-contact-email.patch): Hides the `mailto:` link on the About page
  - [Additional `glitch-soc` patch](patches/glitch/hide-contact-email.patch)
- [`hide-rules.patch`](patches/hide-rules.patch): Applies just to homepage, meant only for single-user instances
  - [Additional `glitch-soc` patch](patches/glitch/hide-rules.patch)
- [`hide-signup.patch`](patches/hide-signup.patch): Hide the "create account" button (for aesthetics, **not security!**)
  - [Additional `glitch-soc` patch](patches/glitch/hide-signup.patch)
- [`glitch-soc` only] [`sidebar-logo.patch`](patches/glitch/sidebar-logo.patch): Restore Mastodon logo in logged-out sidebar

## License

MIT
