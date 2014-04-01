#!/usr/bin/env python

from pymongo import MongoClient
from pprint import pprint

client = MongoClient()
db = client['seniordesign']
coll = db['users']
a = {
    'test' : 'test'
}
#coll.insert(a)

pprint(coll.find_one())
