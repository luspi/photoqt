#####################
#### C++ SOURCES ####
#####################

SET(d "cplusplus")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/main.cpp ${d}/logger.h ${d}/configfiles.h)

SET(d "cplusplus/settings")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/settings.cpp)

SET(d "cplusplus/scripts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/handlingfiledialog.cpp ${d}/localisation.h ${d}/imageformats.cpp ${d}/imageproperties.cpp ${d}/filewatcher.cpp ${d}/handlinggeneral.cpp ${d}/filefoldermodel.cpp)

SET(d "cplusplus/imageprovider")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imageproviderfull.cpp ${d}/imageproviderthumb.cpp ${d}/imageprovidericon.cpp)

SET(d "cplusplus/imageprovider/loader")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/errorimage.h ${d}/loadimage_qt.h)
