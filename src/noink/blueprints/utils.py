from functools import wraps
from flask import request, redirect, url_for

from flask.ext.login import current_user

from noink import mainApp
from noink.state import get_state

def check_login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        s = get_state()
        if mainApp.config['REQUIRE_LOGIN_FOR_DYNAMIC'] and not s.icebox:
            if not current_user.is_authenticated() or not \
                    current_user.is_active():
                return redirect(url_for('login.login_page', next=request.url))
        return f(*args, **kwargs)
    return decorated_function
