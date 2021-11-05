#####################
#### C++ SOURCES ####
#####################

SET(d "cplusplus")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/main.cpp ${d}/logger.h ${d}/configfiles.h ${d}/startup.h ${d}/keypresschecker.h ${d}/passon.h)

SET(d "cplusplus/settings")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/settings.cpp ${d}/imageformats.cpp ${d}/windowgeometry.cpp ${d}/shortcuts.cpp)

SET(d "cplusplus/scripts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/handlingfiledialog.cpp ${d}/localisation.h ${d}/imageproperties.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/filewatcher.cpp ${d}/handlinggeneral.cpp ${d}/handlingshortcuts.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/handlingexternal.cpp ${d}/metadata.cpp ${d}/handlingfiledir.cpp ${d}/handlingmanipulation.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/handlingshareimgur.cpp ${d}/replytimeout.h ${d}/simplecrypt.cpp ${d}/handlingwallpaper.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/handlingfacetags.cpp ${d}/handlingstreaming.cpp)

SET(d "cplusplus/imageprovider")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imageproviderfull.cpp ${d}/imageproviderthumb.cpp ${d}/imageprovidericon.cpp ${d}/imageproviderhistogram.cpp ${d}/loadimage.h)

SET(d "cplusplus/imageprovider/loader")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/errorimage.h ${d}/loadimage_qt.h ${d}/loadimage_xcf.h ${d}/loadimage_poppler.h ${d}/loadimage_raw.h ${d}/loadimage_devil.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/loadimage_freeimage.h ${d}/loadimage_archive.h ${d}/loadimage_unrar.h ${d}/loadimage_video.h ${d}/helper.h ${d}/loadimage_magick.h)

SET(d "cplusplus/singleinstance")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/commandlineparser.h ${d}/singleinstance.cpp)

SET(d "cplusplus/startup")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/startup.cpp)

SET(d "cplusplus/filefoldermodel")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/filefoldermodel.cpp ${d}/filefoldermodelcache.h)

SET(d "python")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqpy.h)
