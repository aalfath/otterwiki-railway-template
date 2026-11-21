[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/an-otter-wiki?utm_medium=integration&utm_source=button&utm_campaign=otterwiki)

# An Otter Wiki on Railway

One-click [An Otter Wiki](https://otterwiki.com) for [Railway](https://railway.com), built from the official [`redimp/otterwiki`](https://hub.docker.com/r/redimp/otterwiki) image ([redimp/otterwiki](https://github.com/redimp/otterwiki)).

- **An Otter Wiki 2.27.0**, pinned as `redimp/otterwiki:2.27.0@sha256:9cf1d76c6bff097ff924404aa5a149b235b15aaa05553870e96504cd1d92752b` (Debian, nginx, uWSGI, Python 3.11).
- One service, one volume. Pages live in a git repository and users and settings in SQLite, both on the volume. No external database is needed.

## What the template deploys

| Service | What it does | Volume |
|---|---|---|
| **An Otter Wiki** (this repo) | Wiki web app on Railway's `PORT` (8080), public domain, health check `/healthz` | `/app-data`: `repository/` (git repo with every page, attachment and revision), `db.sqlite` (users, settings), `settings.cfg` (secret key generated on the first boot) |

The wiki starts **private**: reading, editing and attachments need an approved account, and public sign-up is off. On the first boot the wrapper creates the admin account from `OTTERWIKI_ADMIN_EMAIL` and `OTTERWIKI_ADMIN_PASSWORD`, so nobody else can claim the admin account first. Upstream's own defaults are anonymous reading and editing, and the first person to register becomes admin.

## After deploying

1. Open the service's public URL. You land on the login page.
2. Log in with the email `admin@YOUR-RAILWAY-DOMAIN` (the `OTTERWIKI_ADMIN_EMAIL` value) and the password in `OTTERWIKI_ADMIN_PASSWORD`. Both are on the service's **Variables** tab.
3. Under **Settings** (top right), change your name and password. Under **Settings → User Management**, set your real email address on your account and add users.
4. Under **Settings → Permissions and Registration**, decide who may read, edit and upload, and whether people may register. For example, make the wiki readable by anyone but editable only by approved users.

The two admin variables are used only while there is no admin account. After the first boot, changing them does nothing. Manage accounts in the wiki itself.

Optional: under **Settings → Mail Preferences**, add an SMTP server for password-reset and approval emails. Under **Settings → Repository Management**, push the wiki's git repository to a remote such as GitHub as an off-site backup.

## Variables

| Variable | Default | Notes |
|---|---|---|
| `PORT` | `8080` | Port nginx listens on. |
| `OTTERWIKI_ADMIN_EMAIL` | `admin@${{RAILWAY_PUBLIC_DOMAIN}}` | Login email of the first admin. Used only on the first boot. |
| `OTTERWIKI_ADMIN_PASSWORD` | `${{secret(24, …)}}` | Generated password of the first admin. Used only on the first boot. |

Any [An Otter Wiki setting](https://otterwiki.com/Configuration) can be added as a variable, for example `SITE_NAME`, `SITE_DESCRIPTION` or `NGINX_MAX_UPLOAD` (default `64M` here). Settings saved in the admin UI override variables.

## Resources

It runs on Railway's smallest plans (0.5 GB RAM, 1 vCPU): it idles at about 110 MB and is healthy about 3 s after start. One uWSGI worker serves the app. If nginx or uWSGI stops unexpectedly, or the first admin can't be created, the container exits with code 1 so that Railway's restart policy starts it again.

## Updates

Each new An Otter Wiki release is a commit to `main` here: a new pinned version and digest, plus an entry in [CHANGELOG.md](CHANGELOG.md), with breaking changes first. Railway shows you an "update available" notice, and you choose when to apply it. Your pages, users and settings stay on the volume, and the app updates its database tables itself on start. Before an update, back up the volume, or push the git repository to a remote.

## Files

- `Dockerfile`: the pinned official image, private-by-default settings, and the wrapper below.
- `railway/entrypoint.sh`: makes nginx listen on `PORT`, then runs the upstream entrypoint (which creates `/app-data`, the git repository and `settings.cfg`).
- `railway/start.sh`: adds `/healthz` and the forwarded HTTPS scheme to nginx, creates the first admin, then runs supervisord and exits non-zero if it stops on its own.
- `railway/bootstrap.py`: creates the first admin account, once.

Licence: An Otter Wiki is MIT licensed. This wrapper is provided under the same licence.
