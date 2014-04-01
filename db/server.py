#!/usr/bin/env python

from wsgiref.simple_server import make_server
from pyramid.config import Configurator
from pyramid.response import Response
from pyramid.view import view_config

from pprint import pprint
from pymongo import MongoClient

client = MongoClient()
db = client['seniordesign']

@view_config(renderer='json')
def create_user(request):
    response = {
        'response'  : u'',
        'error'     : u'',
    }

    json_obj = request.get('json', {})
    pprint(json_obj)
    if json_obj:
        coll = db['users']
        coll.insert(request.json)
        response['response'] = u'User was added successfully'
    else:
        response['error'] = u'No body included'

    return response

if __name__ == '__main__':
    config = Configurator()
    config.add_route('api', '/api/{name}')
    config.add_view(create_user, route_name='api', renderer='json')
    app = config.make_wsgi_app()
    server = make_server('0.0.0.0', 8080, app)
    server.serve_forever()
