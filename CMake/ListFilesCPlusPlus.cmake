#####################
#### C++ SOURCES ####
#####################

SET(d "cplusplus")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/main.cpp ${d}/mainwindow.cpp ${d}/variables.h ${d}/logger.h)

SET(d "cplusplus/startup")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/migration.h ${d}/updatecheck.h ${d}/startintray.h ${d}/localisation.h ${d}/thumbnails.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/fileformats.h ${d}/screenshots.h ${d}/shortcuts.h ${d}/exportimport.h)

SET(d "cplusplus/handlefiles")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/loaddir.cpp)

SET(d "cplusplus/imageprovider")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imageproviderfull.cpp ${d}/imageproviderthumbnail.cpp ${d}/imageprovidericon.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pixmapcache.h ${d}/imageproviderempty.h ${d}/imageproviderhistogram.h)

SET(d "cplusplus/imageprovider/loader")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/loadimage_qt.h ${d}/loadimage_gm.h ${d}/loadimage_xcf.h ${d}/loadimage_raw.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/errorimage.h)

SET(d "cplusplus/shortcuts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/shortcutsnotifier.h ${d}/keyhandler.cpp ${d}/mousebutton.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/mousehandler.cpp ${d}/touchhandler.cpp ${d}/keymodifier.h)

SET(d "cplusplus/scripts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/getanddostuff.h ${d}/getmetadata.cpp ${d}/runprocess.h ${d}/thumbnailsmanagement.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/gmimagemagick.h ${d}/imagewatch.h)
SET(d "cplusplus/scripts/getanddostuff")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/context.cpp ${d}/external.cpp ${d}/manipulation.cpp ${d}/file.cpp ${d}/other.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/shortcuts.cpp ${d}/wallpaper.cpp ${d}/openfile.cpp ${d}/imageinfo.cpp)

SET(d "cplusplus/settings")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/settings.h ${d}/settingssession.h ${d}/fileformats.h ${d}/colour.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/fileformatsavailable.h ${d}/fileformatsdefaultenabled.h)

SET(d "cplusplus/singleinstance")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/singleinstance.cpp ${d}/commandlineparser.h)

SET(d "cplusplus/tooltip")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/tooltip.cpp)

SET(d "cplusplus/zip")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/zip.cpp ${d}/zipreader.h ${d}/zipwriter.h)


####################
#### C++ HEADER ####
####################

SET(d "cplusplus")
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/mainwindow.h ${d}/variables.h ${d}/logger.h)

SET(d "cplusplus/startup")
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/migration.h ${d}/updatecheck.h ${d}/startintray.h ${d}/localisation.h ${d}/thumbnails.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/fileformats.h ${d}/screenshots.h ${d}/shortcuts.h ${d}/exportimport.h)

SET(d "cplusplus/handlefiles")
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/loaddir.h)

SET(d "cplusplus/imageprovider")
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/imageproviderthumbnail.h ${d}/imageproviderfull.h ${d}/imageprovidericon.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/pixmapcache.h ${d}/imageproviderempty.h ${d}/imageproviderhistogram.h)

SET(d "cplusplus/imageprovider/loader")
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/loadimage_qt.h ${d}/loadimage_gm.h ${d}/loadimage_xcf.h ${d}/loadimage_raw.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/errorimage.h)

SET(d "cplusplus/shortcuts")
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/shortcutsnotifier.h ${d}/keyhandler.h ${d}/mousebutton.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/touchhandler.h ${d}/mousehandler.h ${d}/keymodifier.h)

SET(d "cplusplus/scripts")
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/getanddostuff.h ${d}/getmetadata.h ${d}/runprocess.h ${d}/thumbnailsmanagement.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/gmimagemagick.h ${d}/imagewatch.h)
SET(d "cplusplus/scripts/getanddostuff")
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/openfile.h ${d}/context.h ${d}/external.h ${d}/manipulation.h ${d}/file.h ${d}/other.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/shortcuts.h ${d}/wallpaper.h ${d}/imageinfo.h)

SET(d "cplusplus/settings")
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/settings.h ${d}/settingssession.h ${d}/fileformats.h ${d}/colour.h)
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/fileformatsavailable.h ${d}/fileformatsdefaultenabled.h)

SET(d "cplusplus/singleinstance")
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/singleinstance.h ${d}/commandlineparser.h)

SET(d "cplusplus/tooltip")
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/tooltip.h)

SET(d "cplusplus/zip")
SET(photoqt_HEADERS ${photoqt_HEADERS} ${d}/zipreader.h ${d}/zipwriter.h)
