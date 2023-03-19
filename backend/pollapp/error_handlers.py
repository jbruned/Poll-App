# from flask import current_app as app
from flask import jsonify
from werkzeug.exceptions import HTTPException, default_exceptions


def register_handlers(flask_app):
    """
    Function that registers all the error handlers in this file for the given app
    @param flask_app:
    """
    flask_app.register_error_handler(400, invalid_request)
    flask_app.register_error_handler(401, unauthorized)
    flask_app.register_error_handler(404, page_not_found)
    flask_app.register_error_handler(409, conflict)
    flask_app.register_error_handler(Exception, generic_error_handler)


# @app.errorhandler(Exception)
def generic_error_handler(e, custom_message=None):
    """
    Generic error handler for any exception
    """
    code = 500
    if isinstance(e, HTTPException):
        code = e.code
    message = str(e)
    if custom_message is not None:
        message = custom_message
    return jsonify(error=message), code


def invalid_request(e):
    return jsonify(error=str(e)), 400


def unauthorized(e):
    return jsonify(error=str(e)), 401


# @app.errorhandler(404)
def page_not_found(e):
    return jsonify(error=str(e)), 404


def conflict(e):
    return jsonify(error=str(e)), 409


def override_default_exceptions(flask_app):
    """
    Override the default HTML exceptions from Flask so that they return JSON instead of HTML
    """
    for ex in default_exceptions:
        flask_app.register_error_handler(ex, generic_error_handler)
