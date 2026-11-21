"""Create the first An Otter Wiki admin from OTTERWIKI_ADMIN_EMAIL and
OTTERWIKI_ADMIN_PASSWORD, once. When any admin exists it does nothing, so
changes made in the wiki (email, password) are kept across redeploys.
The password is never printed."""
import os
import sys
from datetime import datetime

from werkzeug.security import generate_password_hash

from otterwiki.server import app, db
from otterwiki.models import User
from otterwiki.util import is_valid_email

with app.app_context():
    if User.query.filter_by(is_admin=True).count() > 0:
        print("railway: admin account exists, nothing to do", file=sys.stderr)
        sys.exit(0)
    email = os.environ.get("OTTERWIKI_ADMIN_EMAIL", "").strip().lower()
    password = os.environ.get("OTTERWIKI_ADMIN_PASSWORD", "")
    minlen = int(app.config.get("PASSWORD_MIN_LENGTH", 8))
    if not is_valid_email(email):
        sys.exit("railway: OTTERWIKI_ADMIN_EMAIL is missing or not a valid email address")
    if len(password) < minlen:
        sys.exit(f"railway: OTTERWIKI_ADMIN_PASSWORD must be at least {minlen} characters")
    user = User.query.filter_by(email=email).first()
    now = datetime.now()
    if user is None:
        user = User(name="Admin", email=email, first_seen=now)
    user.last_seen = now
    user.password_hash = generate_password_hash(password, method="scrypt")
    for flag in ("is_admin", "is_approved", "email_confirmed",
                 "allow_read", "allow_write", "allow_upload"):
        setattr(user, flag, True)
    db.session.add(user)
    db.session.commit()
    print(f"railway: created admin account {email}", file=sys.stderr)
