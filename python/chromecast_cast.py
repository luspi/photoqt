import pychromecast
import sys
import time

name = sys.argv[1]
ip = sys.argv[2]
port = sys.argv[3]

chromecasts, browser = pychromecast.get_listed_chromecasts(friendly_names=[name])
cast = chromecasts[0]
cast.wait()

mc = cast.media_controller
mc.play_media(f"http://{ip}:{port}/{time.time()}", "image/jpg")
mc.block_until_active()
