#!/usr/bin/env python

from pymongo import MongoClient
from pprint import pprint

client = MongoClient()
coll = client['safelet']['users']
pprint(list(coll.find()))
