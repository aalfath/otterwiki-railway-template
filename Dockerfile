# An Otter Wiki on Railway: a thin wrapper around the official image (redimp/otterwiki).
# Bump the version and digest together; every merge to main notifies deployers.
FROM redimp/otterwiki:2.27.0@sha256:9cf1d76c6bff097ff924404aa5a149b235b15aaa05553870e96504cd1d92752b

# Safe first-start defaults (upstream allows anonymous reading and editing and
# open registration). The admin can change all of them later under
# Settings > Permissions and Registration: saved settings override these.
ENV READ_ACCESS=APPROVED \
    WRITE_ACCESS=APPROVED \
    ATTACHMENT_ACCESS=APPROVED \
    AUTO_APPROVAL=false \
    DISABLE_REGISTRATION=true \
    SESSION_COOKIE_SECURE=true \
    ROBOTS_TXT=disallow \
    NGINX_MAX_UPLOAD=64M

COPY railway/ /railway/

# Railway's edge terminates TLS; pass its X-Forwarded-Proto to the app as the
# URL scheme so links in feeds and the sitemap use https.
RUN set -eux; \
    chmod 0755 /railway /railway/entrypoint.sh /railway/start.sh; \
    chmod 0644 /railway/bootstrap.py; \
    printf 'map $http_x_forwarded_proto $railway_scheme {\n    default $http_x_forwarded_proto;\n    "" $scheme;\n}\n' > /etc/nginx/conf.d/railway-scheme.conf; \
    grep -q 'include /etc/nginx/conf.d/\*.conf' /etc/nginx/nginx.conf; \
    test -x /usr/sbin/runuser

EXPOSE 8080
ENTRYPOINT ["/railway/entrypoint.sh"]
CMD ["/railway/start.sh"]
