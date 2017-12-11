#####################
#### C++ SOURCES ####
#####################

SET(d "cplusplus")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/main.cpp ${d}/mainwindow.cpp ${d}/logger.h ${d}/configfiles.h)

SET(d "cplusplus/imageprovider")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imageproviderempty.h ${d}/imageproviderfull.cpp ${d}/imageproviderthumbnail.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imageproviderhistogram.h ${d}/imageprovidericon.h ${d}/pixmapcache.h)

SET(d "cplusplus/imageprovider/loader")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/errorimage.h ${d}/loadimage_gm.h ${d}/loadimage_qt.h ${d}/loadimage_raw.h ${d}/loadimage_xcf.h)

SET(d "cplusplus/settings")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/colour.h ${d}/fileformats.h ${d}/fileformatsavailable.h ${d}/fileformatsdefaultenabled.h ${d}/settings.h ${d}/settingssession.h)
