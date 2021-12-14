#!/usr/bin/python3
import xmlrpc.client
import sys

#
# This is a very simple client that connects to the
# sample server in order to start a new sample session.
#
ip = sys.argv[1]
test = sys.argv[2]
print("{} {}".format(ip, test))
server = xmlrpc.client.ServerProxy(
    "http://{}:8000".format(ip))

try:
    print(server.currentTime.getCurrentTime())
except xmlrpc.client.Error as v:
    print("ERROR", v)

multi = xmlrpc.client.MultiCall(server)
multi.start_sample("", test)
try:
    for response in multi():
        print(response)
except xmlrpc.client.Error as v:
    print("ERROR", v)
