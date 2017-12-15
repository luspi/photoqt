#####################
#### C++ SOURCES ####
#####################

SET(d "cplusplus")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/main.cpp ${d}/mainhandler.cpp ${d}/logger.h ${d}/configfiles.h ${d}/variables.h)

SET(d "cplusplus/imageprovider")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imageproviderempty.h ${d}/imageproviderfull.cpp ${d}/imageproviderthumbnail.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imageproviderhistogram.h ${d}/imageprovidericon.h ${d}/pixmapcache.h)

SET(d "cplusplus/imageprovider/loader")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/errorimage.h ${d}/loadimage_gm.h ${d}/loadimage_qt.h ${d}/loadimage_raw.h ${d}/loadimage_xcf.h)

SET(d "cplusplus/settings")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/colour.h ${d}/fileformats.h ${d}/fileformatsavailable.h ${d}/fileformatsdefaultenabled.h ${d}/settings.h ${d}/settingssession.h)

SET(d "cplusplus/scripts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/getanddostuff.h ${d}/getmetadata.cpp ${d}/gmimagemagick.h ${d}/imagewatch.h ${d}/runprocess.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/thumbnailsmanagement.cpp)

SET(d "cplusplus/scripts/getanddostuff")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/context.cpp ${d}/external.cpp ${d}/file.cpp ${d}/imageinfo.cpp ${d}/manipulation.cpp ${d}/openfile.cpp ${d}/other.cpp ${d}/wallpaper.cpp)

SET(d "cplusplus/scripts/shareonline")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imgur.cpp ${d}/replytimeout.h)

SET(d "cplusplus/zip")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/zip.cpp ${d}/zipreader.h ${d}/zipwriter.h)

SET(d "cplusplus/handlefiles")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/loaddir.cpp)

SET(d "cplusplus/simplecrypt")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/simplecrypt.cpp)

SET(d "cplusplus/clipboard")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/clipboard.cpp)

SET(d "cplusplus/tooltip")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/tooltip.cpp)

SET(d "cplusplus/startup")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/exportimport.h ${d}/fileformats.h ${d}/localisation.h ${d}/migration.h ${d}/screenshots.h ${d}/startintray.h ${d}/thumbnails.h ${d}/updatecheck.h)

SET(d "cplusplus/singleinstance")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/commandlineparser.h ${d}/singleinstance.cpp)

SET(d "cplusplus/shortcuts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/shortcutsnotifier.h)
