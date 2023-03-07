##########################################################################
##                                                                      ##
## Copyright (C) 2011-2023 Lukas Spies                                  ##
## Contact: https://photoqt.org                                         ##
##                                                                      ##
## This file is part of PhotoQt.                                        ##
##                                                                      ##
## PhotoQt is free software: you can redistribute it and/or modify      ##
## it under the terms of the GNU General Public License as published by ##
## the Free Software Foundation, either version 2 of the License, or    ##
## (at your option) any later version.                                  ##
##                                                                      ##
## PhotoQt is distributed in the hope that it will be useful,           ##
## but WITHOUT ANY WARRANTY; without even the implied warranty of       ##
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        ##
## GNU General Public License for more details.                         ##
##                                                                      ##
## You should have received a copy of the GNU General Public License    ##
## along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      ##
##                                                                      ##
##########################################################################

import pychromecast
import time


def getAvailable():
    services, browser = pychromecast.discovery.discover_chromecasts()
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
def disconnectFrom(cast, browser):
    cast.quit_app()
    pychromecast.discovery.stop_discovery(browser)


def streamOnDevice(ip, port, mc):
    mc.play_media(f"http://{ip}:{port}/{time.time()}", "image/jpg")
    mc.block_until_active()
