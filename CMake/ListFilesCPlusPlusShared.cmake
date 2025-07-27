#####################
#### C++ SOURCES ####
#####################

SET(photoqt_shared_SOURCES "")

SET(d "cplusplus/header")
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_notify.h ${d}/pqc_constants.h)

SET(d "cplusplus/singletons/other")
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_filefoldermodel.cpp ${d}/pqc_metadata.cpp ${d}/pqc_resolutioncache.cpp)

SET(d "cplusplus/singletons/engines")
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_settings.cpp ${d}/pqc_shortcuts.cpp ${d}/pqc_look.cpp ${d}/pqc_imageformats.cpp)
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_location.cpp ${d}/pqc_windowgeometry.cpp)

SET(d "cplusplus/singletons/scripts/cpp")
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_scriptscolorprofiles.cpp ${d}/pqc_scriptsfilespaths.cpp ${d}/pqc_scriptsimages.cpp)
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_scriptsmetadata.cpp ${d}/pqc_scriptscrypt.cpp)

SET(d "cplusplus/singletons/scripts/qml")
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_scriptschromecast.cpp ${d}/pqc_scriptsclipboard.cpp ${d}/pqc_scriptsfiledialog.cpp)
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_scriptsfilemanagement.cpp ${d}/pqc_scriptsother.cpp ${d}/pqc_scriptsshortcuts.cpp)
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_scriptscontextmenu.cpp ${d}/pqc_scriptsconfig.cpp)

SET(d "cplusplus/singletons/scripts/qmlcpp")
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_scriptsshareimgur.cpp ${d}/pqc_scriptswallpaper.cpp)

SET(d "cplusplus/header/scripts/cpp")
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_scriptscolorprofiles.h ${d}/pqc_scriptsfilespaths.h ${d}/pqc_scriptsimages.h)
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_scriptsmetadata.h ${d}/pqc_scriptscrypt.h)

SET(d "cplusplus/header/scripts/qmlcpp")
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_scriptsshareimgur.h ${d}/pqc_scriptswallpaper.h)

SET(d "cplusplus/header/scripts/qml")
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_scriptschromecast.h ${d}/pqc_scriptsclipboard.h)
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_scriptsconfig.h ${d}/pqc_scriptscontextmenu.h ${d}/pqc_scriptsfiledialog.h ${d}/pqc_scriptsfilemanagement.h)
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_scriptsother.h ${d}/pqc_scriptsshortcuts.h)

SET(d "cplusplus/header/scripts/qmlwrapper")
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_scriptsfilespaths_qml.h ${d}/pqc_scriptscolorprofiles_qml.h ${d}/pqc_scriptsimages_qml.h)
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_scriptsmetadata_qml.h)

SET(d "cplusplus/header")
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_filefoldermodel.h ${d}/pqc_metadata.h ${d}/pqc_resolutioncache.h)
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_settings.h ${d}/pqc_shortcuts.h ${d}/pqc_look.h ${d}/pqc_imageformats.h)
SET(photoqt_shared_SOURCES ${photoqt_shared_SOURCES} ${d}/pqc_location.h ${d}/pqc_windowgeometry.h)
