#####################
#### C++ SOURCES ####
#####################

SET(d "cplusplus")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/main.cpp ${d}/mainhandler.cpp ${d}/logger.h ${d}/configfiles.h ${d}/hideclose.h)

SET(d "cplusplus/imageprovider")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imageproviderempty.cpp ${d}/imageproviderfull.cpp ${d}/imageproviderthumbnail.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imageproviderhistogram.cpp ${d}/imageprovidericon.cpp)

SET(d "cplusplus/imageprovider/loader")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/errorimage.h ${d}/loadimage_gm.h ${d}/loadimage_qt.h ${d}/loadimage_raw.h ${d}/loadimage_xcf.h ${d}/loadimage_devil.h ${d}/loadimage_freeimage.h ${d}/loadimage_poppler.h ${d}/loadimage_archive.h ${d}/loadimage_unrar.h)

SET(d "cplusplus/settings")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/colour.cpp ${d}/mimetypes.cpp ${d}/imageformats.cpp ${d}/settings.cpp ${d}/slimsettingsreadonly.cpp)

SET(d "cplusplus/scripts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/getanddostuff.h ${d}/getmetadata.cpp ${d}/managepeopletags.cpp ${d}/runprocess.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/thumbnailsmanagement.cpp ${d}/filedialog.h ${d}/watcher.h ${d}/sortlist.h ${d}/localisation.h)

SET(d "cplusplus/scripts/getanddostuff")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/context.cpp ${d}/external.cpp ${d}/file.cpp ${d}/manipulation.cpp ${d}/openfile.cpp ${d}/other.cpp ${d}/wallpaper.cpp ${d}/listfiles.cpp)

SET(d "cplusplus/scripts/shareonline")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imgur.cpp ${d}/replytimeout.h)

SET(d "cplusplus/simplecrypt")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/simplecrypt.cpp)

SET(d "cplusplus/tooltip")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/tooltip.cpp)

SET(d "cplusplus/startup")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/exportimport.h ${d}/migration.h ${d}/screenshots.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/thumbnails.h ${d}/updatecheck.h ${d}/shortcuts.h ${d}/settings.h)

SET(d "cplusplus/singleinstance")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/commandlineparser.cpp ${d}/singleinstance.cpp)

SET(d "cplusplus/shortcuts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/shortcutsnotifier.h ${d}/shortcuts.cpp ${d}/composestring.h)

SET(d "cplusplus/contextmenu")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/contextmenu.cpp)
