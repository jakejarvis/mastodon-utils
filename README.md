# 🦣 Mastodon utilities

Random opinionated helper scripts & front-end customizations for my [personal Mastodon instance](https://fediverse.jarv.is/about) (running on [`glitch-soc`](https://github.com/glitch-soc/mastodon)). You definitely don't want to use any of this as-is — check out my more general purpose [mastodon-installer](https://github.com/jakejarvis/mastodon-installer) scripts instead.

## Notes

The [wiki of this repo](https://github.com/jakejarvis/mastodon-utils/wiki) and the [`/etc` folder](etc/) are simply my way of not forgetting how I did something, which I do quite a bit. Refer there for random notes on PgBouncer, Grafana, etc. but **DO NOT BLINDLY COPY & PASTE** anything there without doing your own research!

- [Grafana & Prometheus](https://github.com/jakejarvis/mastodon-utils/wiki/Prometheus-&-Grafana)
- [ElasticSearch](https://github.com/jakejarvis/mastodon-utils/wiki/ElasticSearch)
- [PgBouncer](https://github.com/jakejarvis/mastodon-utils/wiki/Postgres-&-PgBouncer)
- [Brotli compression](https://github.com/jakejarvis/mastodon-utils/wiki/Brotli-compression-for-nginx)

## Usage

***AGAIN, DEFINITELY DO NOT JUST RUN THIS IF YOU'RE NOT ME!!! 😊***

This sets up the bare minimum customizations ***after*** Mastodon is installed:

```sh
git clone https://github.com/jakejarvis/mastodon-utils.git /home/mastodon/utils && cd /home/mastodon/utils

# setup nginx using conf files from this repo:
./scripts/setup_nginx.sh

# back up Postgres, Redis, and secrets:
./scripts/backup.sh

# pull latest Mastodon (vanilla or glitch-soc) and apply patches from this repo:
./scripts/upgrade.sh

# cherry-pick everything else below...
```

## Scripts

- [`init.sh`](init.sh): A small helper that runs at the very beginning of each script below to initialize `rbenv` and set consistent environment variables.
  - **Optional:** To make your life easier, you can also source this script from the `.bashrc` of the `mastodon` user and/or whichever user you regularly SSH in as:

```sh
if [ -f /home/mastodon/utils/init.sh ]; then
  . /home/mastodon/utils/init.sh
fi
```

- [`apply_patches.sh`](scripts/apply_patches.sh): Dangerously applies ***every patch*** listed below, and automatically detects if `glitch-soc` patches should also be applied
- [`backup.sh`](scripts/backup.sh): Backs up Postgres, Redis, and `.env.production` secrets to a `.tar.gz` file in `/home/mastodon/backups` — useful for a [periodic cronjob](https://github.com/jakejarvis/mastodon-utils/wiki/Cron-jobs#backups)
- [`setup_nginx.sh`](scripts/setup_nginx.sh): Sets up symlinks from `/etc/nginx` to nginx confs in this repo
- [`upgrade.sh`](scripts/upgrade.sh): Upgrades Mastodon server (latest version if vanilla Mastodon, latest commit if `glitch-soc`) and re-applies patches listed below
- [`version.sh`](scripts/version.sh): Tests `init.sh` by printing Mastodon, Ruby, and rbenv versions.
- [`weekly_cleanup.sh`](scripts/weekly_cleanup.sh): Runs Mastodon's built-in [cleanup commands](https://docs.joinmastodon.org/admin/setup/#cleanup), designed for a [weekly cronjob](https://github.com/jakejarvis/mastodon-utils/wiki/Cron-jobs#media-cleanup)
  - Keeps 7 days of media (in object storage)
  - Keeps 90 days of generated preview cards

## Patches

#### Vanilla and `glitch-soc`:

- [`robots.patch`](patches/robots.patch): Disallow search engines for all of Mastodon
- [`increase-sidekiq-timeout.patch`](patches/increase-sidekiq-timeout.patch): Small bump in Sidekiq's timeout before it decides a remote instance isn't available. **Use this one very carefully!**
- [`favicons.patch`](patches/favicons.patch): Use custom icon images instead of Mastodon logo
- [`system-font.patch`](patches/system-font.patch): Use the system's default sans-serif font stack instead of Roboto
  - [`glitch/system-font.patch`](patches/glitch/system-font.patch)
- [`hide-contact-email.patch`](patches/hide-contact-email.patch): Hides the `mailto:` link on the About page
  - [`glitch/hide-contact-email.patch`](patches/glitch/hide-contact-email.patch)
- [`hide-rules.patch`](patches/hide-rules.patch): Applies just to homepage, meant only for single-user instances
  - [`glitch/hide-rules.patch`](patches/glitch/hide-rules.patch)
- [`hide-signup.patch`](patches/hide-signup.patch): Hide the "create account" button (for aesthetics, **not security!**)
  - [`glitch/hide-signup.patch`](patches/glitch/hide-signup.patch)

#### `glitch-soc` only:
  - [`custom-glitch-defaults.patch`](patches/glitch/custom-glitch-defaults.patch): Sets default Glitch appearance settings for logged-out users
  - [`remove-glitch-cruft.patch`](patches/glitch/remove-glitch-cruft.patch): Removes a bunch of junk no longer used by `glitch-soc`
  - [`sidebar-logo.patch`](patches/glitch/sidebar-logo.patch): Restore Mastodon logo in logged-out sidebar

## License

MIT
