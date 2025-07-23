######################
#### TEST SOURCES ####
######################

set(photoqt_testscripts_SOURCES "")

if(WITH_TESTING)

SET(d "../../cplusplus/other")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_commandlineparser.cpp ${d}/pqc_singleinstance.cpp ${d}/pqc_startup.cpp  ${d}/pqc_validate.cpp)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_printtabimageoptions.cpp ${d}/pqc_printtabimagepositiontile.cpp ${d}/pqc_localhttpserver.cpp)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_filefoldermodelcache.cpp ${d}/pqc_extensionsettings.cpp)

SET(d "../../cplusplus/images")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_loadimage.cpp ${d}/pqc_imagecache.cpp)

SET(d "../../cplusplus/images/plugins")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_loadimage_archive.cpp ${d}/pqc_loadimage_devil.cpp ${d}/pqc_loadimage_freeimage.cpp)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_loadimage_libvips.cpp ${d}/pqc_loadimage_magick.cpp ${d}/pqc_loadimage_poppler.cpp)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_loadimage_qt.cpp ${d}/pqc_loadimage_qtpdf.cpp ${d}/pqc_loadimage_raw.cpp)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_loadimage_unrar.cpp ${d}/pqc_loadimage_video.cpp ${d}/pqc_loadimage_xcf.cpp)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_loadimage_resvg.cpp)

SET(d "../../cplusplus/extensions")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_extensionshandler.cpp ${d}/pqc_extensionactions.h)

SET(d "../../cplusplus/singletons/other")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_filefoldermodel.cpp ${d}/pqc_resolutioncache.cpp)

SET(d "../../cplusplus/singletons/engines")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_settings.cpp ${d}/pqc_shortcuts.cpp ${d}/pqc_imageformats.cpp)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_location.cpp)

SET(d "../../cplusplus/singletons/scripts/cpp")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptscolorprofiles.cpp ${d}/pqc_scriptscrypt.cpp ${d}/pqc_scriptsfilespaths.cpp)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptsimages.cpp ${d}/pqc_scriptsmetadata.cpp)

SET(d "../../cplusplus/singletons/scripts/qml")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptschromecast.cpp ${d}/pqc_scriptsclipboard.cpp ${d}/pqc_scriptsconfig.cpp ${d}/pqc_scriptscontextmenu.cpp)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptsfiledialog.cpp ${d}/pqc_scriptsfilemanagement.cpp ${d}/pqc_scriptsother.cpp ${d}/pqc_scriptsshortcuts.cpp)

SET(d "../../cplusplus/singletons/scripts/qmlcpp")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptsshareimgur.cpp ${d}/pqc_scriptswallpaper.cpp)

SET(d "../../cplusplus/header")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_commandlineparser.h ${d}/pqc_singleinstance.h ${d}/pqc_configfiles.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_notify.h ${d}/pqc_settings.h ${d}/pqc_shortcuts.h ${d}/pqc_settingscpp.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_validate.h ${d}/pqc_startup.h ${d}/pqc_extensionsettings.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_filefoldermodel.h ${d}/pqc_filefoldermodelcache.h ${d}/pqc_imageformats.h ${d}/pqc_providerfolderthumb.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_printtabimageoptions.h ${d}/pqc_printtabimagepositiontile.h ${d}/pqc_httpreplytimeout.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_localhttpserver.h ${d}/pqc_resolutioncache.h ${d}/pqc_constants.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_location.h ${d}/pqc_notify_cpp.h ${d}/pqc_filefoldermodelCPP.h ${d}/pqc_extensionshandler.h)

SET(d "../../cplusplus/header/scripts/cpp")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptscolorprofiles.h ${d}/pqc_scriptscrypt.h ${d}/pqc_scriptsfilespaths.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptsimages.h ${d}/pqc_scriptsmetadata.h)

SET(d "../../cplusplus/header/scripts/qml")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptschromecast.h ${d}/pqc_scriptsclipboard.h ${d}/pqc_scriptsconfig.h ${d}/pqc_scriptscontextmenu.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptsfiledialog.h ${d}/pqc_scriptsfilemanagement.h ${d}/pqc_scriptsother.h ${d}/pqc_scriptsshortcuts.h)

SET(d "../../cplusplus/header/scripts/qmlcpp/")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptsshareimgur.h ${d}/pqc_scriptswallpaper.h)

endif()
