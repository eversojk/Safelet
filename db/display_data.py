#!/usr/bin/env python

from pymongo import MongoClient
from pprint import pprint

client = MongoClient()
coll = client['safelet']['log']
pprint(list(coll.find()))
