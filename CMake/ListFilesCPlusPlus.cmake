#####################
#### C++ SOURCES ####
#####################

SET(d "cplusplus")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/main.cpp ${d}/logger.h ${d}/configfiles.h ${d}/variables.h ${d}/startup.h)

SET(d "cplusplus/settings")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/settings.cpp ${d}/imageformats.cpp ${d}/windowgeometry.cpp)

SET(d "cplusplus/scripts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/handlingfiledialog.cpp ${d}/localisation.h ${d}/imageproperties.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/filewatcher.cpp ${d}/handlinggeneral.cpp ${d}/filefoldermodel.cpp ${d}/handlingshortcuts.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/handlingexternal.cpp ${d}/metadata.cpp ${d}/handlingfilemanagement.cpp)

SET(d "cplusplus/imageprovider")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imageproviderfull.cpp ${d}/imageproviderthumb.cpp ${d}/imageprovidericon.cpp ${d}/pixmapcache.h ${d}/imageproviderhistogram.cpp ${d}/loadimage.h)

SET(d "cplusplus/imageprovider/loader")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/errorimage.h ${d}/loadimage_qt.h ${d}/loadimage_gm.h ${d}/loadimage_xcf.h ${d}/loadimage_poppler.h ${d}/loadimage_raw.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/loadimage_devil.h ${d}/loadimage_freeimage.h ${d}/loadimage_archive.h ${d}/loadimage_unrar.h ${d}/helper.h)

SET(d "cplusplus/singleinstance")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/commandlineparser.h ${d}/singleinstance.cpp)

SET(d "cplusplus/startup")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/screenshots.h ${d}/exportimport.h)
