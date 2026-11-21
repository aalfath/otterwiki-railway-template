#!/usr/bin/env bash
# Runs after the upstream entrypoint (as root, /app-data prepared and owned by www-data).
set -uo pipefail

SITE=/etc/nginx/sites-enabled/default
if ! grep -q railway_scheme "$SITE"; then
    # Use Railway's forwarded scheme for the app (see Dockerfile).
    sed -i 's|include uwsgi_params;|include uwsgi_params;\n        uwsgi_param UWSGI_SCHEME $railway_scheme;|' "$SITE"
    # Railway's health check path can't contain "/-/": serve the app's
    # /-/healthz (storage and database check) as /healthz too.
    sed -i 's|    location / {|    location = /healthz {\n        rewrite ^ /-/healthz last;\n    }\n    location / {|' "$SITE"
fi
nginx -t -q || exit 1

# Create the first admin once (no-op when an admin already exists).
HOME=/app-data /usr/sbin/runuser -u www-data -- /opt/venv/bin/python /railway/bootstrap.py || {
    echo "railway: admin bootstrap failed, exiting so Railway restarts the service" >&2
    exit 1
}
unset OTTERWIKI_ADMIN_PASSWORD

# Upstream's supervisord stops (exit 0) when nginx or uWSGI dies. Exit non-zero
# then, so Railway's ON_FAILURE restart policy brings the wiki back.
stopping=0
trap 'stopping=1; kill -TERM "$pid" 2>/dev/null' TERM INT
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf &
pid=$!
while kill -0 "$pid" 2>/dev/null; do wait "$pid"; done
wait "$pid"; rc=$?
if [ "$stopping" = 1 ]; then exit 0; fi
echo "railway: supervisord stopped unexpectedly (code $rc), exiting 1" >&2
exit 1
