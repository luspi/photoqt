#####################
#### C++ SOURCES ####
#####################

SET(photoqt_SOURCES "")

SET(d "cplusplus")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/main.cpp)

SET(d "cplusplus/other")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_commandlineparser.cpp ${d}/pqc_singleinstance.cpp ${d}/pqc_mpvobject.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_printtabimageoptions.cpp ${d}/pqc_printtabimagepositiontile.cpp ${d}/pqc_localhttpserver.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_photosphere.cpp ${d}/pqc_photosphereitem.cpp ${d}/pqc_photosphererenderer.cpp ${d}/pqc_filefoldermodelcache.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_extensionsettings.cpp ${d}/pqc_startuphandler.cpp)

SET(d "cplusplus/other/startuphandler")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_migratesettings.cpp ${d}/pqc_migrateshortcuts.cpp ${d}/pqc_validate.cpp ${d}/pqc_wizard.cpp)

SET(d "cplusplus/other/wayland-specific")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_xdg-output-unstable-v1-protocol.c ${d}/pqc_get-wayland-device-pixel-ratio.cpp)

SET(d "cplusplus/header")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_commandlineparser.h ${d}/pqc_singleinstance.h ${d}/pqc_configfiles.h ${d}/pqc_startuphandler.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_settingscpp.h ${d}/pqc_notify.h ${d}/pqc_constants.h ${d}/pqc_migratesettings.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_validate.h ${d}/pqc_mpvobject.h ${d}/pqc_migrateshortcuts.h ${d}/pqc_wizard.h)
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
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_loadimage_resvg.cpp ${d}/pqc_loadimage_libsai.cpp)

SET(d "cplusplus/extensions")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_extensionshandler.cpp ${d}/pqc_extensionactions.h)

SET(d "cplusplus/singletons/other")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_filefoldermodel.cpp ${d}/pqc_metadata.cpp ${d}/pqc_resolutioncache.cpp)

SET(d "cplusplus/singletons/engines")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_settings.cpp ${d}/pqc_shortcuts.cpp ${d}/pqc_look.cpp ${d}/pqc_imageformats.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_location.cpp ${d}/pqc_windowgeometry.cpp)

SET(d "cplusplus/singletons/scripts/cpp")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptscolorprofiles.cpp ${d}/pqc_scriptsfilespaths.cpp ${d}/pqc_scriptsimages.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptsmetadata.cpp ${d}/pqc_scriptscrypt.cpp ${d}/pqc_scriptslocalization.cpp)

SET(d "cplusplus/singletons/scripts/qml")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptschromecast.cpp ${d}/pqc_scriptsclipboard.cpp ${d}/pqc_scriptsfiledialog.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptsfilemanagement.cpp ${d}/pqc_scriptsother.cpp ${d}/pqc_scriptsshortcuts.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptscontextmenu.cpp ${d}/pqc_scriptsconfig.cpp)

SET(d "cplusplus/singletons/scripts/qmlcpp")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptsshareimgur.cpp ${d}/pqc_scriptswallpaper.cpp)

SET(d "cplusplus/header/scripts/cpp")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptscolorprofiles.h ${d}/pqc_scriptsfilespaths.h ${d}/pqc_scriptsimages.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptsmetadata.h ${d}/pqc_scriptscrypt.h ${d}/pqc_scriptslocalization.h)

SET(d "cplusplus/header/scripts/qmlcpp")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptsshareimgur.h ${d}/pqc_scriptswallpaper.h)

SET(d "cplusplus/header/scripts/qml")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptschromecast.h ${d}/pqc_scriptsclipboard.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptsconfig.h ${d}/pqc_scriptscontextmenu.h ${d}/pqc_scriptsfiledialog.h ${d}/pqc_scriptsfilemanagement.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptsother.h ${d}/pqc_scriptsshortcuts.h)

SET(d "cplusplus/header/scripts/qmlwrapper")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptsfilespaths_qml.h ${d}/pqc_scriptscolorprofiles_qml.h ${d}/pqc_scriptsimages_qml.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptsmetadata_qml.h)

SET(d "cplusplus/header")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_filefoldermodel.h ${d}/pqc_metadata.h ${d}/pqc_resolutioncache.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_settings.h ${d}/pqc_shortcuts.h ${d}/pqc_look.h ${d}/pqc_imageformats.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_location.h ${d}/pqc_windowgeometry.h)
