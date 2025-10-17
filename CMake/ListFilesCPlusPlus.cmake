#####################
#### C++ SOURCES ####
#####################

####################################################
#
# The sources are put into two categories:
#
# 1) Some sources are used from C++ only and are added to the executable directly.
# 2) Some sources are put into a QML module and can only be used from QML directly.
#
####################################################

SET(photoqt_CPP_SOURCES "")

SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} cplusplus/main.cpp

                                               cplusplus/cpp/other/pqc_commandlineparser.cpp
                                               cplusplus/cpp/other/pqc_singleinstance.cpp
                                               cplusplus/cpp/other/pqc_startuphandler.cpp

                                               cplusplus/cpp/other/startuphandler/pqc_migratesettings.cpp
                                               cplusplus/cpp/other/startuphandler/pqc_migrateshortcuts.cpp
                                               cplusplus/cpp/other/startuphandler/pqc_validate.cpp
                                               cplusplus/cpp/other/startuphandler/pqc_wizard.cpp

                                               cplusplus/cpp/other/wayland-specific/pqc_get-wayland-device-pixel-ratio.cpp
                                               cplusplus/cpp/other/wayland-specific/pqc_xdg-output-unstable-v1-protocol.c

                                               cplusplus/cpp/singletons/pqc_cscriptsconfig.cpp
                                               cplusplus/cpp/singletons/pqc_cscriptsimages.cpp
                                               cplusplus/cpp/singletons/pqc_cscriptslocalization.cpp
                                               cplusplus/cpp/singletons/pqc_cscriptscolorprofiles.cpp
                                               cplusplus/cpp/singletons/pqc_cscriptsfilespaths.cpp
                                               cplusplus/cpp/singletons/pqc_cscriptsshareimgur.cpp
                                               cplusplus/cpp/singletons/pqc_cscriptscrypt.cpp
                                               cplusplus/cpp/singletons/pqc_imageformats.cpp
                                               cplusplus/cpp/singletons/pqc_cdbusserver.cpp

                                               cplusplus/cpp/images/pqc_imagecache.cpp
                                               cplusplus/cpp/images/pqc_loadimage.cpp

                                               cplusplus/cpp/images/provider/pqc_providerdragthumb.cpp
                                               cplusplus/cpp/images/provider/pqc_providerfolderthumb.cpp
                                               cplusplus/cpp/images/provider/pqc_providerfull.cpp
                                               cplusplus/cpp/images/provider/pqc_providericon.cpp
                                               cplusplus/cpp/images/provider/pqc_providerimgurhistory.cpp
                                               cplusplus/cpp/images/provider/pqc_providersvg.cpp
                                               cplusplus/cpp/images/provider/pqc_providersvgcolor.cpp
                                               cplusplus/cpp/images/provider/pqc_providertheme.cpp
                                               cplusplus/cpp/images/provider/pqc_providerthumb.cpp
                                               cplusplus/cpp/images/provider/pqc_providertooltipthumb.cpp

                                               cplusplus/cpp/images/plugins/pqc_loadimage_archive.cpp
                                               cplusplus/cpp/images/plugins/pqc_loadimage_devil.cpp
                                               cplusplus/cpp/images/plugins/pqc_loadimage_freeimage.cpp
                                               cplusplus/cpp/images/plugins/pqc_loadimage_libsai.cpp
                                               cplusplus/cpp/images/plugins/pqc_loadimage_libvips.cpp
                                               cplusplus/cpp/images/plugins/pqc_loadimage_magick.cpp
                                               cplusplus/cpp/images/plugins/pqc_loadimage_poppler.cpp
                                               cplusplus/cpp/images/plugins/pqc_loadimage_qt.cpp
                                               cplusplus/cpp/images/plugins/pqc_loadimage_qtpdf.cpp
                                               cplusplus/cpp/images/plugins/pqc_loadimage_raw.cpp
                                               cplusplus/cpp/images/plugins/pqc_loadimage_resvg.cpp
                                               cplusplus/cpp/images/plugins/pqc_loadimage_unrar.cpp
                                               cplusplus/cpp/images/plugins/pqc_loadimage_video.cpp
                                               cplusplus/cpp/images/plugins/pqc_loadimage_xcf.cpp

                                               cplusplus/cpp/extensions/pqc_extensionactions.h
                                               cplusplus/cpp/extensions/pqc_extensionshandler.cpp
                                               cplusplus/cpp/extensions/pqc_extensionsettings.cpp

                                           )

SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} cplusplus/header/cpp/pqc_cppconstants.h
                                               cplusplus/header/cpp/pqc_outputhandler.h
                                               cplusplus/header/cpp/pqc_saveoutput.h
                                               cplusplus/header/cpp/pqc_commandlineparser.h
                                               cplusplus/header/cpp/pqc_singleinstance.h
                                               cplusplus/header/cpp/pqc_startuphandler.h
                                               cplusplus/header/cpp/pqc_migratesettings.h
                                               cplusplus/header/cpp/pqc_migrateshortcuts.h
                                               cplusplus/header/cpp/pqc_validate.h
                                               cplusplus/header/cpp/pqc_cdbusserver.h

                                               cplusplus/header/cpp/pqc_wizard.h
                                               cplusplus/header/cpp/pqc_xdg-output-unstable-v1-client-protocol.h

                                               cplusplus/header/cpp/pqc_cscriptsconfig.h
                                               cplusplus/header/cpp/pqc_cscriptsimages.h
                                               cplusplus/header/cpp/pqc_cscriptslocalization.h
                                               cplusplus/header/cpp/pqc_cscriptscolorprofiles.h
                                               cplusplus/header/cpp/pqc_cscriptsfilespaths.h
                                               cplusplus/header/cpp/pqc_cscriptsshareimgur.h
                                               cplusplus/header/cpp/pqc_cscriptscrypt.h
                                               cplusplus/header/cpp/pqc_httpreplytimeout.h
                                               cplusplus/header/cpp/pqc_imageformats.h

                                               cplusplus/header/cpp/pqc_imagecache.h
                                               cplusplus/header/cpp/pqc_loadimage.h

                                               cplusplus/header/cpp/pqc_providerdragthumb.h
                                               cplusplus/header/cpp/pqc_providerfolderthumb.h
                                               cplusplus/header/cpp/pqc_providerfull.h
                                               cplusplus/header/cpp/pqc_providericon.h
                                               cplusplus/header/cpp/pqc_providerimgurhistory.h
                                               cplusplus/header/cpp/pqc_providersvg.h
                                               cplusplus/header/cpp/pqc_providersvgcolor.h
                                               cplusplus/header/cpp/pqc_providertheme.h
                                               cplusplus/header/cpp/pqc_providerthumb.h
                                               cplusplus/header/cpp/pqc_providertooltipthumb.h

                                               cplusplus/header/cpp/pqc_loadimage_archive.h
                                               cplusplus/header/cpp/pqc_loadimage_devil.h
                                               cplusplus/header/cpp/pqc_loadimage_freeimage.h
                                               cplusplus/header/cpp/pqc_loadimage_libsai.h
                                               cplusplus/header/cpp/pqc_loadimage_libvips.h
                                               cplusplus/header/cpp/pqc_loadimage_magick.h
                                               cplusplus/header/cpp/pqc_loadimage_poppler.h
                                               cplusplus/header/cpp/pqc_loadimage_qt.h
                                               cplusplus/header/cpp/pqc_loadimage_qtpdf.h
                                               cplusplus/header/cpp/pqc_loadimage_raw.h
                                               cplusplus/header/cpp/pqc_loadimage_resvg.h
                                               cplusplus/header/cpp/pqc_loadimage_unrar.h
                                               cplusplus/header/cpp/pqc_loadimage_video.h
                                               cplusplus/header/cpp/pqc_loadimage_xcf.h

                                               cplusplus/header/cpp/pqc_extensionshandler.h
                                               cplusplus/header/cpp/pqc_extensionsettings.h
                                           )

# SET(d "cplusplus/singletons")
# SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} ${d}/pqc_cppscriptsimages.cpp

# SET(d "cplusplus/other")
# SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} ${d}/pqc_commandlineparser.cpp ${d}/pqc_singleinstance.cpp ${d}/pqc_startuphandler.cpp ${d}/pqc_scripts.cpp)

# SET(d "cplusplus/header")
# SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} ${d}/pqc_commandlineparser.h ${d}/pqc_singleinstance.h ${d}/pqc_scripts.h ${d}/pqc_validate.h)

# SET(d "cplusplus/other/startuphandler")
# SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} ${d}/pqc_migratesettings.cpp ${d}/pqc_migrateshortcuts.cpp ${d}/pqc_validate.cpp ${d}/pqc_wizard.cpp)

# SET(d "cplusplus/images")
# SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} ${d}/pqc_loadimage.cpp ${d}/pqc_imagecache.cpp)

# SET(d "cplusplus/images/provider")
# SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} ${d}/pqc_providericon.cpp ${d}/pqc_providertheme.cpp ${d}/pqc_providerthumb.cpp ${d}/pqc_providertooltipthumb.cpp)
# SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} ${d}/pqc_providerfolderthumb.cpp ${d}/pqc_providerdragthumb.cpp ${d}/pqc_providerfull.cpp ${d}/pqc_providerimgurhistory.cpp)
# SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} ${d}/pqc_providersvg.cpp ${d}/pqc_providersvgcolor.cpp)

# SET(d "cplusplus/images/plugins")
# SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} ${d}/pqc_loadimage_archive.cpp ${d}/pqc_loadimage_devil.cpp ${d}/pqc_loadimage_freeimage.cpp)
# SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} ${d}/pqc_loadimage_libvips.cpp ${d}/pqc_loadimage_magick.cpp ${d}/pqc_loadimage_poppler.cpp)
# SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} ${d}/pqc_loadimage_qt.cpp ${d}/pqc_loadimage_qtpdf.cpp ${d}/pqc_loadimage_raw.cpp)
# SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} ${d}/pqc_loadimage_unrar.cpp ${d}/pqc_loadimage_video.cpp ${d}/pqc_loadimage_xcf.cpp)
# SET(photoqt_CPP_SOURCES ${photoqt_CPP_SOURCES} ${d}/pqc_loadimage_resvg.cpp ${d}/pqc_loadimage_libsai.cpp)

####################################
####################################

SET(photoqt_CPPQML_SOURCES "")

SET(d "cplusplus/header")
SET(photoqt_CPPQML_SOURCES ${photoqt_CPPQML_SOURCES} cplusplus/header/shared/pqc_configfiles.h
                                                     cplusplus/header/shared/pqc_csettings.h)

####################################
####################################

SET(photoqt_QML_SOURCES "")

SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} cplusplus/qml/singletons/pqc_qdbusserver.cpp
                                               cplusplus/qml/singletons/pqc_resolutioncache.cpp
                                               cplusplus/qml/singletons/pqc_scriptsimages.cpp
                                               cplusplus/qml/singletons/pqc_scriptsshortcuts.cpp
                                               cplusplus/qml/singletons/pqc_scriptsconfig.cpp
                                               cplusplus/qml/singletons/pqc_scriptsmetadata.cpp
                                               cplusplus/qml/singletons/pqc_scriptsfilespaths.cpp
                                               cplusplus/qml/singletons/pqc_filefoldermodel.cpp

                                               cplusplus/qml/qmlsingletons/pqc_look.cpp
                                               cplusplus/qml/qmlsingletons/pqc_settings.cpp
                                               cplusplus/qml/qmlsingletons/pqc_metadata.cpp

                                               cplusplus/qml/other/pqc_filefoldermodelcache.cpp

                                               cplusplus/qml/qmlitems/pqc_mpvobject.cpp
                                               cplusplus/qml/qmlitems/pqc_photosphere.cpp
                                               cplusplus/qml/qmlitems/pqc_photosphereitem.cpp
                                               cplusplus/qml/qmlitems/pqc_photosphererenderer.cpp)

SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} cplusplus/header/qml/pqc_qdbusserver.h
                                               cplusplus/header/qml/pqc_dbuslayer.h
                                               cplusplus/header/qml/pqc_look.h
                                               cplusplus/header/qml/pqc_settings.h
                                               cplusplus/header/qml/pqc_constants.h
                                               cplusplus/header/qml/pqc_notify.h
                                               cplusplus/header/qml/pqc_resolutioncache.h

                                               cplusplus/header/qml/pqc_filefoldermodel.h
                                               cplusplus/header/qml/pqc_filefoldermodelcache.h
                                               cplusplus/header/qml/pqc_metadata.h

                                               cplusplus/header/qml/pqc_scriptsimages.h
                                               cplusplus/header/qml/pqc_qscriptsimages.h
                                               cplusplus/header/qml/pqc_scriptsshortcuts.h
                                               cplusplus/header/qml/pqc_qscriptsshortcuts.h
                                               cplusplus/header/qml/pqc_scriptsconfig.h
                                               cplusplus/header/qml/pqc_qscriptsconfig.h
                                               cplusplus/header/qml/pqc_scriptsmetadata.h
                                               cplusplus/header/qml/pqc_scriptsmetadata_qml.h
                                               cplusplus/header/qml/pqc_scriptsfilespaths.h
                                               cplusplus/header/qml/pqc_scriptsfilespaths_qml.h

                                               cplusplus/header/qml/pqc_mpvobject.h
                                               cplusplus/header/qml/pqc_mpvqthelper.h
                                               cplusplus/header/qml/pqc_photosphere.h
                                               cplusplus/header/qml/pqc_photosphereitem.h
                                               cplusplus/header/qml/pqc_photosphererenderer.h)

# SET(d "cplusplus/qml/other")
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_printtabimageoptions.cpp ${d}/pqc_printtabimagepositiontile.cpp ${d}/pqc_localhttpserver.cpp)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_extensionsettings.cpp ${d}/pqc_receivemessages.cpp)

# SET(d "cplusplus/header")
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_startuphandler.h ${d}/pqc_receivemessages.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_settingscpp.h ${d}/pqc_migratesettings.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_migrateshortcuts.h ${d}/pqc_wizard.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_filefoldermodelcache.h ${d}/pqc_providerfolderthumb.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_printtabimageoptions.h ${d}/pqc_printtabimagepositiontile.h ${d}/pqc_httpreplytimeout.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_localhttpserver.h ${d}/pqc_filefoldermodelCPP.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_extensionshandler.h ${d}/pqc_extensionsettings.h ${d}/pqc_notify_cpp.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_photosphere.h ${d}/pqc_mpvobject.h ${d}/pqc_imageformats_qml.h ${d}/pqc_filefoldermodel.h ${d}/pqc_metadata.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_settings.h ${d}/pqc_shortcuts.h ${d}/pqc_look.h ${d}/pqc_imageformats.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_location.h ${d}/pqc_windowgeometry.h ${d}/pqc_notify.h ${d}/pqc_constants.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_photosphereitem.h ${d}/pqc_photosphererenderer.h ${d}/pqc_resolutioncache.h)

# SET(d "cplusplus/qml/extensions")
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_extensionshandler.cpp ${d}/pqc_extensionactions.h)

# SET(d "cplusplus/qml/other")
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_photosphere.cpp ${d}/pqc_mpvobject.cpp ${d}/pqc_photosphereitem.cpp ${d}/pqc_photosphererenderer.cpp)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_filefoldermodelcache.cpp)

# SET(d "cplusplus/qml/other/wayland-specific")
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_xdg-output-unstable-v1-protocol.c ${d}/pqc_get-wayland-device-pixel-ratio.cpp)

# SET(d "cplusplus/qml/singletons/other")
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_filefoldermodel.cpp ${d}/pqc_metadata.cpp)

# SET(d "cplusplus/qml/singletons/engines")
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_settings.cpp ${d}/pqc_shortcuts.cpp ${d}/pqc_look.cpp)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_location.cpp ${d}/pqc_windowgeometry.cpp)

# SET(d "cplusplus/header/scripts/")
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptsfilespaths_qml.h ${d}/pqc_scriptscolorprofiles_qml.h ${d}/pqc_scriptsimages_qml.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptsmetadata_qml.h ${d}/pqc_scriptsfilemanagement_qml.h ${d}/pqc_scriptscontextmenu_qml.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptsother_qml.h ${d}/pqc_scriptsshortcuts_qml.h ${d}/pqc_scriptsfiledialog_qml.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptsconfig_qml.h ${d}/pqc_scriptslocalization_qml.h ${d}/pqc_scriptsclipboard_qml.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptschromecast_qml.h)

# SET(d "cplusplus/header/scripts/qmlcpp")
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptsshareimgur.h ${d}/pqc_scriptswallpaper.h)

# SET(d "cplusplus/qml/singletons/scripts")
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptscolorprofiles.cpp ${d}/pqc_scriptsfilespaths.cpp ${d}/pqc_scriptsimages.cpp)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptsmetadata.cpp ${d}/pqc_scriptscrypt.cpp ${d}/pqc_scriptslocalization.cpp)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptsother.cpp ${d}/pqc_scriptsshortcuts.cpp ${d}/pqc_scriptsfilemanagement.cpp)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptsfiledialog.cpp ${d}/pqc_scriptscontextmenu.cpp)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptsconfig.cpp ${d}/pqc_scriptsclipboard.cpp)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptschromecast.cpp)

# SET(d "cplusplus/qml/singletons/scripts/qmlcpp")
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptsshareimgur.cpp ${d}/pqc_scriptswallpaper.cpp)

# SET(d "cplusplus/header/scripts/")
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptscolorprofiles.h ${d}/pqc_scriptsfilespaths.h ${d}/pqc_scriptsimages.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptsmetadata.h ${d}/pqc_scriptscrypt.h ${d}/pqc_scriptslocalization.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptsother.h ${d}/pqc_scriptsshortcuts.h ${d}/pqc_scriptsfilemanagement.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptsfiledialog.h ${d}/pqc_scriptscontextmenu.h)
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_scriptsconfig.h ${d}/pqc_scriptsclipboard.h ${d}/pqc_scriptschromecast.h)

# SET(d "cplusplus/qml/singletons/other")
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_resolutioncache.cpp)

# SET(d "cplusplus/qml/singletons/engines")
# SET(photoqt_QML_SOURCES ${photoqt_QML_SOURCES} ${d}/pqc_imageformats.cpp)
