#####################
#### C++ SOURCES ####
#####################

SET(photoqt_SOURCES "")

SET(d "cplusplus")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/main.cpp)

SET(d "cplusplus/other")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_commandlineparser.cpp ${d}/pqc_singleinstance.cpp ${d}/pqc_startup.cpp ${d}/pqc_validate.cpp ${d}/pqc_mpvobject.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_printtabimageoptions.cpp ${d}/pqc_printtabimagepositiontile.cpp ${d}/pqc_localhttpserver.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_photosphere.cpp ${d}/pqc_photosphereitem.cpp ${d}/pqc_photosphererenderer.cpp ${d}/pqc_filefoldermodelcache.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_extensionsettings.cpp)

SET(d "cplusplus/other/wayland-specific")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_xdg-output-unstable-v1-protocol.c ${d}/pqc_get-wayland-device-pixel-ratio.cpp)

SET(d "cplusplus/header")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_commandlineparser.h ${d}/pqc_singleinstance.h ${d}/pqc_configfiles.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_settingscpp.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_validate.h ${d}/pqc_startup.h ${d}/pqc_mpvobject.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_filefoldermodelcache.h ${d}/pqc_providerfolderthumb.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_printtabimageoptions.h ${d}/pqc_printtabimagepositiontile.h ${d}/pqc_httpreplytimeout.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_localhttpserver.h ${d}/pqc_filefoldermodelCPP.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_photosphere.h ${d}/pqc_photosphereitem.h ${d}/pqc_photosphererenderer.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_extensionshandler.h ${d}/pqc_extensionsettings.h ${d}/pqc_notify_cpp.h)

SET(d "cplusplus/images")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_loadimage.cpp ${d}/pqc_imagecache.cpp)

SET(d "cplusplus/images/provider")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_providericon.cpp ${d}/pqc_providertheme.cpp ${d}/pqc_providerthumb.cpp ${d}/pqc_providertooltipthumb.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_providerfolderthumb.cpp ${d}/pqc_providerdragthumb.cpp ${d}/pqc_providerfull.cpp ${d}/pqc_providerimgurhistory.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_providersvg.cpp ${d}/pqc_providersvgcolor.cpp)

SET(d "cplusplus/images/plugins")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_loadimage_archive.cpp ${d}/pqc_loadimage_devil.cpp ${d}/pqc_loadimage_freeimage.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_loadimage_libvips.cpp ${d}/pqc_loadimage_magick.cpp ${d}/pqc_loadimage_poppler.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_loadimage_qt.cpp ${d}/pqc_loadimage_qtpdf.cpp ${d}/pqc_loadimage_raw.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_loadimage_unrar.cpp ${d}/pqc_loadimage_video.cpp ${d}/pqc_loadimage_xcf.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_loadimage_resvg.cpp)

SET(d "cplusplus/extensions")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_extensionshandler.cpp ${d}/pqc_extensionactions.h)
