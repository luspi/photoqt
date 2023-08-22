#####################
#### C++ SOURCES ####
#####################

SET(photoqt_SOURCES "")

SET(d "cplusplus")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/main.cpp)

SET(d "cplusplus/other")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_commandlineparser.cpp ${d}/pqc_singleinstance.cpp ${d}/pqc_startup.cpp ${d}/pqc_validate.cpp ${d}/pqc_mpvobject.cpp)

SET(d "cplusplus/singletons/other")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_notify.cpp ${d}/pqc_filefoldermodel.cpp ${d}/pqc_filefoldermodelcache.cpp ${d}/pqc_metadata.cpp)

SET(d "cplusplus/singletons/engines")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_settings.cpp ${d}/pqc_shortcuts.cpp ${d}/pqc_look.cpp ${d}/pqc_imageformats.cpp)

SET(d "cplusplus/singletons/scripts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptschromecast.cpp ${d}/pqc_scriptsclipboard.cpp ${d}/pqc_scriptsconfig.cpp ${d}/pqc_scriptscontextmenu.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptscrypt.cpp ${d}/pqc_scriptsfiledialog.cpp ${d}/pqc_scriptsfilemanagement.cpp ${d}/pqc_scriptsfilespaths.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptsimages.cpp ${d}/pqc_scriptsmetadata.cpp ${d}/pqc_scriptsother.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptsshareimgur.cpp ${d}/pqc_scriptsshortcuts.cpp ${d}/pqc_scriptswallpaper.cpp)

SET(d "cplusplus/header")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_commandlineparser.h ${d}/pqc_singleinstance.h ${d}/pqc_configfiles.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_notify.h ${d}/pqc_settings.h ${d}/pqc_shortcuts.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_validate.h ${d}/pqc_startup.h ${d}/pqc_look.h ${d}/pqc_mpvobject.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_filefoldermodel.h ${d}/pqc_filefoldermodelcache.h ${d}/pqc_imageformats.h ${d}/pqc_providerfolderthumb.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_metadata.h)

SET(d "cplusplus/header/scripts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptschromecast.h ${d}/pqc_scriptsclipboard.h ${d}/pqc_scriptsconfig.h ${d}/pqc_scriptscontextmenu.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptscrypt.h ${d}/pqc_scriptsfiledialog.h ${d}/pqc_scriptsfilemanagement.h ${d}/pqc_scriptsfilespaths.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptsimages.h ${d}/pqc_scriptsmetadata.h ${d}/pqc_scriptsother.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_scriptsshareimgur.h ${d}/pqc_scriptsshortcuts.h ${d}/pqc_scriptswallpaper.h)

SET(d "cplusplus/images")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_loadimage.cpp ${d}/pqc_imagecache.cpp)

SET(d "cplusplus/images/provider")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_providericon.cpp ${d}/pqc_providertheme.cpp ${d}/pqc_providerthumb.cpp ${d}/pqc_providertooltipthumb.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_providerfolderthumb.cpp ${d}/pqc_providerdragthumb.cpp ${d}/pqc_providerfull.cpp)

SET(d "cplusplus/images/plugins")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_loadimage_archive.cpp ${d}/pqc_loadimage_devil.cpp ${d}/pqc_loadimage_freeimage.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_loadimage_libvips.cpp ${d}/pqc_loadimage_magick.cpp ${d}/pqc_loadimage_poppler.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_loadimage_qt.cpp ${d}/pqc_loadimage_qtpdf.cpp ${d}/pqc_loadimage_raw.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_loadimage_unrar.cpp ${d}/pqc_loadimage_video.cpp ${d}/pqc_loadimage_xcf.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqc_loadimage_resvg.cpp)


#########################
# TESTING

SET(d "testing")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/main.cpp ${d}/pqc_test.cpp)


SET(d "cplusplus/other")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_commandlineparser.cpp ${d}/pqc_singleinstance.cpp ${d}/pqc_startup.cpp  ${d}/pqc_validate.cpp)

SET(d "cplusplus/singletons/other")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_notify.cpp ${d}/pqc_filefoldermodel.cpp ${d}/pqc_filefoldermodelcache.cpp)

SET(d "cplusplus/singletons/engines")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_settings.cpp ${d}/pqc_shortcuts.cpp ${d}/pqc_look.cpp ${d}/pqc_imageformats.cpp)

SET(d "cplusplus/singletons/scripts")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptschromecast.cpp ${d}/pqc_scriptsclipboard.cpp ${d}/pqc_scriptsconfig.cpp ${d}/pqc_scriptscontextmenu.cpp)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptscrypt.cpp ${d}/pqc_scriptsfiledialog.cpp ${d}/pqc_scriptsfilemanagement.cpp ${d}/pqc_scriptsfilespaths.cpp)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptsimages.cpp ${d}/pqc_scriptsmetadata.cpp ${d}/pqc_scriptsother.cpp)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptsshareimgur.cpp ${d}/pqc_scriptsshortcuts.cpp ${d}/pqc_scriptswallpaper.cpp)

SET(d "cplusplus/header")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_commandlineparser.h ${d}/pqc_singleinstance.h ${d}/pqc_configfiles.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_notify.h ${d}/pqc_settings.h ${d}/pqc_shortcuts.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_validate.h ${d}/pqc_startup.h ${d}/pqc_look.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_filefoldermodel.h ${d}/pqc_filefoldermodelcache.h ${d}/pqc_imageformats.h ${d}/pqc_providerfolderthumb.h)

SET(d "cplusplus/header/scripts")
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptschromecast.h ${d}/pqc_scriptsclipboard.h ${d}/pqc_scriptsconfig.h ${d}/pqc_scriptscontextmenu.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptscrypt.h ${d}/pqc_scriptsfiledialog.h ${d}/pqc_scriptsfilemanagement.h ${d}/pqc_scriptsfilespaths.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptsimages.h ${d}/pqc_scriptsmetadata.h ${d}/pqc_scriptsother.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${d}/pqc_scriptsshareimgur.h ${d}/pqc_scriptsshortcuts.h ${d}/pqc_scriptswallpaper.h)
