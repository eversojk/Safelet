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

@view_config(renderer='json')
def create_user(request):
    coll = db['users']
    response = {
        'response'  : u'',
        'error'     : u'',
    }


    json_obj = {}
    try:
        json_obj = request.json_body
    except ValueError:
        response['error'] = u'No body included'

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

    pprint(response)
    return response

if __name__ == '__main__':
    config = Configurator()
    config.add_route('api', '/api/{name}')
    config.add_view(create_user, route_name='api', renderer='json')
    app = config.make_wsgi_app()
    server = make_server('0.0.0.0', 8080, app)
    server.serve_forever()
