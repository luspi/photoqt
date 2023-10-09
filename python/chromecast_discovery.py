import pychromecast

services, browser = pychromecast.discovery.discover_chromecasts()

for s in services:
    print(services[0].friendly_name)
    print(services[0].host)

if len(services) == 0:
    print("x")
