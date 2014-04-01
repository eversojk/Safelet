#!/usr/bin/env python

import datetime
import uuid

from pyramid.config import Configurator
from pyramid.response import Response
from pyramid.view import view_config
from wsgiref.simple_server import make_server

from pprint import pprint
from pymongo import MongoClient

client = MongoClient()
# set it to check errors
client.write_concern = {'j': True}
db = client['safelet']

def get_json_body(request):
    json_obj = {}
    error = ''
    try:
        json_obj = request.json_body
    except ValueError:
        error = u'No body included'
        json_obj = {}

    return json_obj, error

@view_config(renderer='json')
def create_user(request):
    coll = db['users']
    response = {
        'response'  : u'',
        'error'     : u'',
    }

    json_obj, response['error'] = get_json_body(request)

    if json_obj:
        try:
            result = coll.insert(json_obj)
            cookie = str(uuid.uuid4())
            db['cookies'].insert({
                'user'      : json_obj['user'],
                'cookie'    : cookie,
                'expires'   : datetime.datetime.now() + datetime.timedelta(hours=48),
            })
            response['cookie'] = cookie
            print 'added'
        except pymongo.errors.DuplicateKeyError:
            response['error'] = u'User already exists'

    print 'login'
    pprint(response)
    return response

@view_config(renderer='json')
def login_user(request):
    coll = db['users']

    response = {
        'response'  : u'',
        'error'     : u'',
    }

    json_obj, response['error'] = get_json_body(request)

    if json_obj:
        user = coll.find_one({'user' : json_obj['user']})
        if user:
            if json_obj['pass'] != user['pass']:
                response['error'] = 'Incorrect login info'
            else:
                # generate new user cookie
                cookie = str(uuid.uuid4())
                update = {
                    'cookie'    : cookie,
                    'expires'   : datetime.datetime.now() + datetime.timedelta(hours=48),
                }
                db['cookies'].update({'user' : user['user']}, {'$set' : update})
                response['cookie'] = cookie
        else:
            response['error'] = 'Incorrect login info'

    print 'login'
    pprint(response)
    return response

@view_config(renderer='json')
def login_cookie(request):
    coll = db['cookies']

    response = {
        'response'  : u'',
        'error'     : u'',
    }

    json_obj, response['error'] = get_json_body(request)

    if json_obj:
        user = coll.find_one({'user' : json_obj['user']})
        if user:
            if json_obj['cookie'] != user['cookie']:
                response['error'] = 'Bad cookie'
            else:
                if user['expires'] < datetime.datetime.now():
                    # generate new user cookie
                    cookie = str(uuid.uuid4())
                    update = {
                        'cookie'    : cookie,
                        'expires'   : datetime.datetime.now() + datetime.timedelta(hours=48),
                    }
                    db['cookies'].update({'user' : user['user']}, {'$set' : update})
                    response['cookie'] = cookie
        else:
            response['error'] = 'Incorrect login info'

    print 'cookie'
    pprint(response)
    return response

if __name__ == '__main__':
    config = Configurator()
    config.add_route('api', '/api/{name}')

    config.add_view(view=create_user, name="create_user", route_name='api', renderer='json')
    config.add_view(view=login_user, name="login_user", route_name='api', renderer='json')
    config.add_view(view=login_cookie, name="login_cookie", route_name='api', renderer='json')

    app = config.make_wsgi_app()
    server = make_server('0.0.0.0', 8080, app)
    server.serve_forever()
