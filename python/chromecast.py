import pychromecast

def getAvailable():
    services, browser = pychromecast.discovery.discover_chromecasts()
    pychromecast.discovery.stop_discovery(browser)
    return [services, browser]

def getNames(services):
    ret = []
    for s in services:
        ret.append(s.friendly_name)
    return ret;

def getIps(services):
    ret = []
    for s in services:
        ret.append(s.host)
    return ret;
