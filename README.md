# 🦣 Mastodon utilities

Random opinionated helper scripts & front-end customizations for my [personal Mastodon instance](https://fediverse.jarv.is/about) (running on [`glitch-soc`](https://github.com/glitch-soc/mastodon)).

> ⚠️ You definitely don't want to use any of this as-is. [Check out my more general-purpose scripts instead.](https://github.com/jakejarvis/mastodon-installer)

## Notes

The [wiki of this repo](https://github.com/jakejarvis/mastodon-utils/wiki) and the [`/etc` folder](etc/) are simply my way of not forgetting how I did something, which I do quite a bit. Refer there for random notes on PgBouncer, Grafana, etc. but **DO NOT BLINDLY COPY & PASTE** anything there without doing your own research!

- [Grafana & Prometheus](https://github.com/jakejarvis/mastodon-utils/wiki/Prometheus-&-Grafana)
- [ElasticSearch](https://github.com/jakejarvis/mastodon-utils/wiki/ElasticSearch)
- [PgBouncer](https://github.com/jakejarvis/mastodon-utils/wiki/Postgres-&-PgBouncer)
- [S3 for media storage](https://github.com/jakejarvis/mastodon-utils/wiki/Media-storage)
- [Maintenance cronjobs](https://github.com/jakejarvis/mastodon-utils/wiki/Cron-jobs)
- [nginx tweaks](https://github.com/jakejarvis/mastodon-utils/wiki/nginx)

## Usage

***AGAIN, DEFINITELY DO NOT JUST RUN THIS IF YOU'RE NOT ME!!! 😊***

```sh
git clone https://github.com/jakejarvis/mastodon-utils.git /home/mastodon/utils && cd /home/mastodon/utils

# install Mastodon on fresh Ubuntu 20.04:
./scripts/install.sh

# back up Postgres, Redis, and secrets:
./scripts/backup.sh

# pull latest Mastodon (vanilla or glitch-soc) and apply patches from this repo:
./scripts/upgrade.sh
```

## Scripts

- [`init.sh`](init.sh): A small helper that runs at the very beginning of each script below to initialize `rbenv` and set consistent environment variables.
  - **Optional:** To make your life easier, you can also source this script from the `.bashrc` of the `mastodon` user and/or whichever user you regularly SSH in as:

```sh
if [ -f /home/mastodon/utils/init.sh ]; then
  . /home/mastodon/utils/init.sh
fi
```

- [`version.sh`](scripts/version.sh): Tests `init.sh` by printing Mastodon, Ruby, and rbenv versions.

#### Periodic tasks

- [`backup.sh`](scripts/backup.sh): Backs up Postgres, Redis, and `.env.production` secrets to a `.tar.gz` file in `/home/mastodon/backups` — useful for a [periodic cronjob](https://github.com/jakejarvis/mastodon-utils/wiki/Cron-jobs#backups).
- [`weekly_cleanup.sh`](scripts/weekly_cleanup.sh): Runs Mastodon's built-in [cleanup commands](https://docs.joinmastodon.org/admin/setup/#cleanup), designed for a [weekly cronjob](https://github.com/jakejarvis/mastodon-utils/wiki/Cron-jobs#media-cleanup).
  - Keeps 7 days of media (in object storage)
  - Keeps 90 days of generated preview cards

#### Dangerous

**The following scripts are highly opinionated, catastrophically destructive, and very specific to me.** Check them out line-by-line instead of running them.

- [`install.sh`](scripts/install.sh): Assumes an absolutely clean install of Ubuntu 20.04 and installs Mastodon ***with all of the quirks from this repo.*** [Get the far less dangerous version of `install.sh` here instead.](https://github.com/jakejarvis/mastodon-installer/blob/main/install.sh)
- [`upgrade.sh`](scripts/upgrade.sh): Upgrades Mastodon server (latest version if vanilla Mastodon, latest commit if `glitch-soc`) and ***re-applies every patch*** listed below. [Get the far less dangerous version of `upgrade.sh` here instead.](https://github.com/jakejarvis/mastodon-installer/blob/main/upgrade.sh)
- [`apply_patches.sh`](scripts/apply_patches.sh): Apply every patch below on top of the currently installed version of Mastodon.

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
