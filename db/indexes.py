#!/usr/bin/env python

import pymongo

mongo = pymongo.Connection('localhost')
db = mongo['safelet']

db['users'].ensure_index('user', unique=True)

db['cookies'].ensure_index('user', unique=True)
