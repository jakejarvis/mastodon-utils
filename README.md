# 🦣 Mastodon randomness

Random opinionated helper scripts & front-end customizations for my [personal Mastodon instance](https://fediverse.jarv.is/about) (running on [`glitch-soc`](https://github.com/glitch-soc/mastodon)). You definitely don't want to use any of this as-is — check out my more general purpose [mastodon-installer](https://github.com/jakejarvis/mastodon-installer) scripts instead.

## Usage

**AGAIN, DEFINITELY DO NOT JUST RUN THIS IF YOU'RE NOT ME!!! 😊**

```sh
git clone https://github.com/jakejarvis/mastodon-scripts.git /home/mastodon/scripts
git config --global --add safe.directory /home/mastodon/scripts

cd /home/mastodon/live
git apply --allow-binary-replacement --whitespace=warn /home/mastodon/scripts/patches/*.patch || true
RAILS_ENV=production bundle exec rails assets:precompile

chown -R mastodon:mastodon /home/mastodon/{scripts,live}

systemctl restart mastodon-web
```

## Patches

- [`hide-signup.patch`](patches/hide-signup.patch): Hide the "create account" button (for aesthetics, not security!)
- [`favicons.patch`](patches/favicons.patch): Use custom icon images instead of Mastodon logo
- [`robots.patch`](patches/robots.patch): Disallow search engines for all of Mastodon
- [`system-font.patch`](patches/favicons.patch): Use the system's default sans-serif font stack instead of Roboto

## License

MIT
