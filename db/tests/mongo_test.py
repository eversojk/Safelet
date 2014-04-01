#!/usr/bin/env python

from pymongo import MongoClient
from pprint import pprint

client = MongoClient()
db = client['safelet']
coll = db['users']
a = {
    'test' : 'test'
}
pprint(coll.find_one())
