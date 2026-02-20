#####################
#### C++ SOURCES ####
#####################

SET(photoqt_SOURCES cplusplus/main.cpp

                    cplusplus/other/pqc_commandlineparser.cpp
                    cplusplus/other/pqc_singleinstance.cpp
                    cplusplus/other/pqc_printtabimageoptions.cpp
                    cplusplus/other/pqc_printtabimagepositiontile.cpp
                    cplusplus/other/pqc_localhttpserver.cpp
                    cplusplus/other/pqc_photosphereitem.cpp
                    cplusplus/other/pqc_photosphererenderer.cpp
                    cplusplus/other/pqc_filefoldermodelcache.cpp
                    cplusplus/other/pqc_extensionsettings.cpp
                    cplusplus/other/pqc_startuphandler.cpp

                    cplusplus/other/startuphandler/pqc_migratesettings.cpp
                    cplusplus/other/startuphandler/pqc_migrateshortcuts.cpp
                    cplusplus/other/startuphandler/pqc_validate.cpp
                    cplusplus/other/startuphandler/pqc_wizard.cpp

                    cplusplus/other/wayland-specific/pqc_xdg-output-unstable-v1-protocol.c
                    cplusplus/other/wayland-specific/pqc_get-wayland-device-pixel-ratio.cpp

                    cplusplus/header/pqc_commandlineparser.h
                    cplusplus/header/pqc_singleinstance.h
                    cplusplus/header/pqc_configfiles.h
                    cplusplus/header/pqc_startuphandler.h
                    cplusplus/header/pqc_settingscpp.h
                    cplusplus/header/pqc_migratesettings.h
                    cplusplus/header/pqc_validate.h
                    cplusplus/header/pqc_migrateshortcuts.h
                    cplusplus/header/pqc_wizard.h
                    cplusplus/header/pqc_filefoldermodelcache.h
                    cplusplus/header/pqc_providerfolderthumb.h
                    cplusplus/header/pqc_printtabimageoptions.h
                    cplusplus/header/pqc_printtabimagepositiontile.h
                    cplusplus/header/pqc_httpreplytimeout.h
                    cplusplus/header/pqc_localhttpserver.h
                    cplusplus/header/pqc_filefoldermodelCPP.h
                    cplusplus/header/pqc_imageformats.h
                    cplusplus/header/pqc_photosphereitem.h
                    cplusplus/header/pqc_photosphererenderer.h
                    cplusplus/header/pqc_resolutioncache.h
                    cplusplus/header/pqc_extensionshandler.h
                    cplusplus/header/pqc_extensioninfo.h
                    cplusplus/header/pqc_extensionsettings.h
                    cplusplus/header/pqc_extensionmethods.h
                    cplusplus/header/pqc_extensionproperties.h
                    cplusplus/header/pqc_notify_cpp.h

                    cplusplus/images/pqc_loadimage.cpp
                    cplusplus/images/pqc_imagecache.cpp

                    cplusplus/images/provider/pqc_providericon.cpp
                    cplusplus/images/provider/pqc_providertheme.cpp
                    cplusplus/images/provider/pqc_providerthumb.cpp
                    cplusplus/images/provider/pqc_providermipmap.cpp
                    cplusplus/images/provider/pqc_providertooltipthumb.cpp
                    cplusplus/images/provider/pqc_providerfolderthumb.cpp
                    cplusplus/images/provider/pqc_providerdragthumb.cpp
                    cplusplus/images/provider/pqc_providerfull.cpp
                    cplusplus/images/provider/pqc_providersvg.cpp
                    cplusplus/images/provider/pqc_providersvgcolor.cpp

                    cplusplus/images/plugins/pqc_loadimage_archive.cpp
                    cplusplus/images/plugins/pqc_loadimage_devil.cpp
                    cplusplus/images/plugins/pqc_loadimage_libvips.cpp
                    cplusplus/images/plugins/pqc_loadimage_magick.cpp
                    cplusplus/images/plugins/pqc_loadimage_poppler.cpp
                    cplusplus/images/plugins/pqc_loadimage_qt.cpp
                    cplusplus/images/plugins/pqc_loadimage_qtpdf.cpp
                    cplusplus/images/plugins/pqc_loadimage_raw.cpp
                    cplusplus/images/plugins/pqc_loadimage_unrar.cpp
                    cplusplus/images/plugins/pqc_loadimage_video.cpp
                    cplusplus/images/plugins/pqc_loadimage_xcf.cpp
                    cplusplus/images/plugins/pqc_loadimage_resvg.cpp
                    cplusplus/images/plugins/pqc_loadimage_libsai.cpp

                    cplusplus/extensions/pqc_extensionshandler.cpp
                    cplusplus/extensions/pqc_extensionmethods.cpp
                    cplusplus/extensions/pqc_extensionproperties.cpp
                    cplusplus/extensions/pqc_extensionactions.h
                    cplusplus/singletons/other/pqc_resolutioncache.cpp
                    cplusplus/singletons/engines/pqc_imageformats.cpp

                    cplusplus/singletons/scripts/pqc_scriptscolorprofiles.cpp
                    cplusplus/singletons/scripts/pqc_scriptsfilespaths.cpp
                    cplusplus/singletons/scripts/pqc_scriptsimages.cpp
                    cplusplus/singletons/scripts/pqc_scriptsmetadata.cpp
                    cplusplus/singletons/scripts/pqc_scriptscrypt.cpp
                    cplusplus/singletons/scripts/pqc_scriptslocalization.cpp
                    cplusplus/singletons/scripts/pqc_scriptsother.cpp
                    cplusplus/singletons/scripts/pqc_scriptsshortcuts.cpp
                    cplusplus/singletons/scripts/pqc_scriptsfilemanagement.cpp
                    cplusplus/singletons/scripts/pqc_scriptsfiledialog.cpp
                    cplusplus/singletons/scripts/pqc_scriptscontextmenu.cpp
                    cplusplus/singletons/scripts/pqc_scriptsconfig.cpp
                    cplusplus/singletons/scripts/pqc_scriptsclipboard.cpp
                    cplusplus/singletons/scripts/pqc_scriptschromecast.cpp

                    cplusplus/header/scripts/pqc_scriptscolorprofiles.h
                    cplusplus/header/scripts/pqc_scriptsfilespaths.h
                    cplusplus/header/scripts/pqc_scriptsimages.h
                    cplusplus/header/scripts/pqc_scriptsmetadata.h
                    cplusplus/header/scripts/pqc_scriptscrypt.h
                    cplusplus/header/scripts/pqc_scriptslocalization.h
                    cplusplus/header/scripts/pqc_scriptsother.h
                    cplusplus/header/scripts/pqc_scriptsshortcuts.h
                    cplusplus/header/scripts/pqc_scriptsfilemanagement.h
                    cplusplus/header/scripts/pqc_scriptsfiledialog.h
                    cplusplus/header/scripts/pqc_scriptscontextmenu.h
                    cplusplus/header/scripts/pqc_scriptsconfig.h
                    cplusplus/header/scripts/pqc_scriptsclipboard.h
                    cplusplus/header/scripts/pqc_scriptschromecast.h

########################################################################
########################################################################

                    cplusplus/other/pqc_photosphere.cpp
                    cplusplus/other/pqc_mpvobject.cpp

                    cplusplus/header/pqc_photosphere.h
                    cplusplus/header/pqc_mpvobject.h
                    cplusplus/header/pqc_imageformats_qml.h
                    cplusplus/header/pqc_filefoldermodel.h
                    cplusplus/header/pqc_metadata.h
                    cplusplus/header/pqc_metadata_cpp.h
                    cplusplus/header/pqc_settings.h
                    cplusplus/header/pqc_shortcuts.h
                    cplusplus/header/pqc_look.h
                    cplusplus/header/pqc_location.h
                    cplusplus/header/pqc_windowgeometry.h
                    cplusplus/header/pqc_notify.h
                    cplusplus/header/pqc_constants.h

                    cplusplus/singletons/other/pqc_filefoldermodel.cpp
                    cplusplus/singletons/other/pqc_metadata.cpp

                    cplusplus/singletons/engines/pqc_settings.cpp
                    cplusplus/singletons/engines/pqc_shortcuts.cpp
                    cplusplus/singletons/engines/pqc_look.cpp
                    cplusplus/singletons/engines/pqc_location.cpp
                    cplusplus/singletons/engines/pqc_windowgeometry.cpp

                    cplusplus/header/scripts/pqc_scriptsfilespaths_qml.h
                    cplusplus/header/scripts/pqc_scriptscolorprofiles_qml.h
                    cplusplus/header/scripts/pqc_scriptsimages_qml.h
                    cplusplus/header/scripts/pqc_scriptsmetadata_qml.h
                    cplusplus/header/scripts/pqc_scriptsfilemanagement_qml.h
                    cplusplus/header/scripts/pqc_scriptscontextmenu_qml.h
                    cplusplus/header/scripts/pqc_scriptsother_qml.h
                    cplusplus/header/scripts/pqc_scriptsshortcuts_qml.h
                    cplusplus/header/scripts/pqc_scriptsfiledialog_qml.h
                    cplusplus/header/scripts/pqc_scriptsconfig_qml.h
                    cplusplus/header/scripts/pqc_scriptslocalization_qml.h
                    cplusplus/header/scripts/pqc_scriptsclipboard_qml.h
                    cplusplus/header/scripts/pqc_scriptschromecast_qml.h)
