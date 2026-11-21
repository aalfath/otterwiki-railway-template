# Changelog

Breaking changes are listed first in each entry.

## 2.27.0 (2026-11-21)

First release of this template.

- An Otter Wiki 2.27.0 from the official image `redimp/otterwiki:2.27.0@sha256:9cf1d76c6bff097ff924404aa5a149b235b15aaa05553870e96504cd1d92752b`.
- Private by default: approved accounts only for reading, editing and attachments; registration off.
- First admin created on the first boot from `OTTERWIKI_ADMIN_EMAIL` and the generated `OTTERWIKI_ADMIN_PASSWORD`.
- `/healthz` health check (the app's storage and database check), nginx on Railway's `PORT`, HTTPS scheme passed to the app.
- The container exits 1 when nginx or uWSGI stops unexpectedly, so Railway restarts it.
