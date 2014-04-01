#!/usr/bin/env python

from pymongo import MongoClient
from pprint import pprint

client = MongoClient()
coll = client['test']['test']

pprint(list(coll.find()))
