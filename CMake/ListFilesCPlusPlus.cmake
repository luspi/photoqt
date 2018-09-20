#####################
#### C++ SOURCES ####
#####################

SET(d "cplusplus")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/main.cpp ${d}/mainhandler.cpp ${d}/logger.h ${d}/configfiles.h ${d}/hideclose.h ${d}/utilities.h)

SET(d "cplusplus/imageprovider")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imageproviderempty.cpp ${d}/imageproviderfull.cpp ${d}/imageproviderthumbnail.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imageproviderhistogram.cpp ${d}/imageprovidericon.cpp)

SET(d "cplusplus/imageprovider/loader")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/loader.h ${d}/errorimage.h ${d}/loadimage_qt.cpp ${d}/loadimage_freeimage.cpp ${d}/loadimage_archive.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/loadimage_devil.cpp ${d}/loadimage_raw.cpp ${d}/loadimage_gm.cpp ${d}/loadimage_poppler.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/loadimage_unrar.cpp ${d}/loadimage_xcf.cpp)

SET(d "cplusplus/settings")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/colour.cpp ${d}/mimetypes.cpp ${d}/imageformats.cpp ${d}/settings.cpp ${d}/slimsettingsreadonly.cpp)

SET(d "cplusplus/scripts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/getanddostuff.h ${d}/getmetadata.cpp ${d}/managepeopletags.cpp ${d}/runprocess.h ${d}/filedialog.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/thumbnailsmanagement.cpp ${d}/watcher.h ${d}/sortlist.cpp ${d}/localisation.h ${d}/integer64.h)

SET(d "cplusplus/scripts/getanddostuff")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/context.cpp ${d}/external.cpp ${d}/file.cpp ${d}/manipulation.cpp ${d}/openfile.cpp ${d}/other.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/wallpaper.cpp ${d}/listfiles.cpp)

SET(d "cplusplus/scripts/shareonline")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imgur.cpp ${d}/replytimeout.h)

SET(d "cplusplus/simplecrypt")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/simplecrypt.cpp)

SET(d "cplusplus/tooltip")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/tooltip.cpp)

SET(d "cplusplus/startup")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/startupcheck.h ${d}/exportimport.cpp ${d}/migration.cpp ${d}/screenshots.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/thumbnails.cpp ${d}/updatecheck.cpp ${d}/shortcuts.cpp ${d}/settings.cpp)

SET(d "cplusplus/singleinstance")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/commandlineparser.cpp ${d}/singleinstance.cpp)

SET(d "cplusplus/shortcuts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/shortcutsnotifier.h ${d}/shortcuts.cpp ${d}/composestring.cpp)

SET(d "cplusplus/contextmenu")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/contextmenu.cpp)
