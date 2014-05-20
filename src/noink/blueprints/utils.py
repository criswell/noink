from functools import wraps
from flask import request, redirect, url_for

from flask.ext.login import current_user

from noink import mainApp

def check_login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if mainApp.config['REQUIRE_LOGIN_FOR_DYNAMIC']:
            if not current_user.is_authenticated() or not \
                    current_user.is_active():
                return redirect(url_for('login', next=request.url))
        return f(*args, **kwargs)
    return decorated_function
