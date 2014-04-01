#!/usr/bin/env python

from wsgiref.simple_server import make_server
from pyramid.config import Configurator
from pyramid.response import Response

from pprint import pprint
from pymongo import MongoClient

client = MongoClient()
db = client['seniordesign']

def create_user(request):
    coll = db['users']
    coll.insert(request.json)
    return Response('Hello %(name)s!' % request.matchdict)

if __name__ == '__main__':
    config = Configurator()
    config.add_route('api', '/api/{name}')
    config.add_view(create_user, route_name='api')
    app = config.make_wsgi_app()
    server = make_server('0.0.0.0', 8080, app)
    server.serve_forever()
