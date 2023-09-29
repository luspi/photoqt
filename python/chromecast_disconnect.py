import pychromecast
import sys
import time

name = sys.argv[1]
ip = sys.argv[2]
port = sys.argv[3]

chromecasts, browser = pychromecast.get_listed_chromecasts(friendly_names=[name])
cast = chromecasts[0]
cast.wait()

cast.quit_app()
pychromecast.discovery.stop_discovery(browser)
