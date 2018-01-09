# All the qml files
SET(d "qmlresources")
SET(photoqt_RESOURCES ${photoqt_RESOURCES} ${d}/elements.qrc ${d}/mainview.qrc ${d}/openfile.qrc ${d}/other.qrc ${d}/shortcuts.qrc ${d}/vars.qrc)
SET(photoqt_RESOURCES ${photoqt_RESOURCES} ${d}/settingsmanager.qrc ${d}/slideshow.qrc ${d}/filemanagement.qrc ${d}/wallpaper.qrc)

# Add language resource file
SET(photoqt_RESOURCES ${photoqt_RESOURCES} ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc)

# And the images
SET(photoqt_RESOURCES ${photoqt_RESOURCES} img.qrc)
