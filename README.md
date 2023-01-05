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
mkdir -p /home/mastodon
git clone https://github.com/jakejarvis/mastodon-utils.git /home/mastodon/utils
cd /home/mastodon/utils

# override default environment variables if necessary:
cp .env.example .env

# install Mastodon on fresh Ubuntu box:
./scripts/install.sh

# back up Postgres, Redis, and secrets:
./scripts/backup.sh

# pull latest Mastodon (vanilla or glitch-soc) and apply patches from this repo:
./scripts/upgrade.sh
```

## Scripts

- [`init.sh`](init.sh): A small helper that runs at the very beginning of each script below to initialize `nvm`/`rbenv` and set consistent environment variables.
  - **Optional:** The default values of each config variable can be seen in [`.env.example`](.env.example). Create a new file named `.env` in the root of this repository (probably at `/home/mastodon/utils/.env`) to override any or all of them.
  - **Optional:** To make your life easier, you can also source this script from the `.bashrc` of the `mastodon` user and/or whichever user you regularly SSH in as:

```sh
[ -s /home/mastodon/utils/init.sh ] && \. /home/mastodon/utils/init.sh >/dev/null 2>&1
```

- [`version.sh`](scripts/version.sh): A quick and easy way to test `init.sh` and `.env` by printing the version numbers of Mastodon, rbenv, nvm, Ruby, Node, and Yarn.

#### Periodic tasks

- [`backup.sh`](scripts/backup.sh): Backs up Postgres, Redis, and `.env.production` secrets to a `.tar.gz` file in `/home/mastodon/backups` — useful for a [periodic cronjob](https://github.com/jakejarvis/mastodon-utils/wiki/Cron-jobs#backups).
- [`weekly_cleanup.sh`](scripts/weekly_cleanup.sh): Runs Mastodon's built-in [cleanup commands](https://docs.joinmastodon.org/admin/setup/#cleanup), designed for a [weekly cronjob](https://github.com/jakejarvis/mastodon-utils/wiki/Cron-jobs#media-cleanup).
  - Keeps 14 days of media
  - Keeps 90 days of profile avatars, headers, and link preview cards

#### Dangerous

**The following scripts are highly opinionated, catastrophically destructive, and very specific to me.** Check them out line-by-line instead of running them.

- [`install.sh`](scripts/install.sh): Assumes an absolutely clean install of Ubuntu and installs Mastodon ***with all of the quirks from this repo.*** Configure `MASTODON_USER` and other paths in `.env` first (see [`.env.example`](.env.example)) if necessary. [Get the far less dangerous version of `install.sh` here instead.](https://github.com/jakejarvis/mastodon-installer/blob/main/install.sh)
- [`upgrade.sh`](scripts/upgrade.sh): Upgrades Mastodon server (latest version if vanilla Mastodon, latest commit if `glitch-soc`) and ***re-applies all customizations***. [Get the far less dangerous version of `upgrade.sh` here instead.](https://github.com/jakejarvis/mastodon-installer/blob/main/upgrade.sh)
- [`customize.sh`](scripts/customize.sh): Applies ***every Git patch below***, sets defaults (mostly for logged-out visitors) and removes unused files.

## Patches

#### Vanilla only:

- [`increase-sidekiq-timeout.patch`](patches/increase-sidekiq-timeout.patch): Small bump in Sidekiq's timeout before it decides a remote instance isn't available. **Use this one very carefully!**

#### Vanilla and `glitch-soc`:

- [`system-font.patch`](patches/system-font.patch): Use the system's default sans-serif font stack instead of Roboto
  - [`glitch/system-font.patch`](patches/glitch/system-font.patch)
- [`hide-contact-email.patch`](patches/hide-contact-email.patch): Hides the `mailto:` link on the About page
  - [`glitch/hide-contact-email.patch`](patches/glitch/hide-contact-email.patch)
- [`hide-rules.patch`](patches/hide-rules.patch): Hides the list of rules on the About page (meant only for single-user instances)
  - [`glitch/hide-rules.patch`](patches/glitch/hide-rules.patch)
- [`hide-signup.patch`](patches/hide-signup.patch): Hide the "create account" button (for aesthetics, **not security!**)
  - [`glitch/hide-signup.patch`](patches/glitch/hide-signup.patch)

#### `glitch-soc` only:

- [`mastodon-logo.patch`](patches/glitch/sidebar-logo.patch): Restore the Mastodon logo in the non-advanced sidebar
- [`settings-sidebar-cleanup.patch`](patches/glitch/settings-sidebar-cleanup.patch): Why is the most frequently used admin page listed under a link that takes you to another page to open a submenu in the sidebar to finally be able to click on it to go to the page?!?

## License

MIT
