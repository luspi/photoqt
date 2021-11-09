import pychromecast
import time


def getAvailable():
    services, browser = pychromecast.discovery.discover_chromecasts()
    pychromecast.discovery.stop_discovery(browser)
    return [len(services), services]


def getNames(services):
    ret = []
    for s in services:
        ret.append(s.friendly_name)
    return ret


def getIps(services):
    ret = []
    for s in services:
        ret.append(s.host)
    return ret


def connectTo(friendlyname):
    chromecasts, browser = pychromecast.get_listed_chromecasts(friendly_names=[friendlyname])
    if len(chromecasts) == 0:
        return []

    cast = chromecasts[0]
    cast.wait()

    mc = cast.media_controller

    return [browser, mc]


def streamOnDevice(ip, port, mc):
    mc.play_media(f"http://{ip}:{port}/{time.time()}", "image/jpg")
    mc.block_until_active()
