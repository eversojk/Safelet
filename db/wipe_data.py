#!/usr/bin/env python

from pymongo import MongoClient
from pprint import pprint

client = MongoClient()
coll = client['safelet']['users']
coll.remove()
coll = client['safelet']['cookies']
coll.remove()
