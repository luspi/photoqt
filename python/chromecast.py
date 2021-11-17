import pychromecast
import time


def getAvailable():
    services, browser = pychromecast.discovery.discover_chromecasts()
    pychromecast.discovery.stop_discovery(browser)
    return [len(services), services]


def getNamesIps(services):
    names = []
    ips = []
    for s in services:
        names.append(s.friendly_name)
        ips.append(s.host)
    return [names, ips]


def connectTo(friendlyname):
    chromecasts, browser = pychromecast.get_listed_chromecasts(friendly_names=[friendlyname])
    if len(chromecasts) == 0:
        return []

    cast = chromecasts[0]
    cast.wait()

    mc = cast.media_controller

    return [cast, browser, mc]


# UNTESTED
def disconnectFrom(cast):
    cast.quit_app()


def streamOnDevice(ip, port, mc):
    mc.play_media(f"http://{ip}:{port}/{time.time()}", "image/jpg")
    mc.block_until_active()
