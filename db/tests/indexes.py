#!/usr/bin/env python

import pymongo

mongo = pymongo.Connection('localhost')
mongo.write_concern = {'j': True}

db = mongo['test']
collection = db['test']
collection.create_index('test', unique=True)
res = collection.insert({'test' : '1'})
print res
res = collection.insert({'test' : '1'})
print res
