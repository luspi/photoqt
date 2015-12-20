# All the qml files
SET(d "qmlresources")
SET(photoqt_RESOURCES ${photoqt_RESOURCES} ${d}/elements.qrc)
SET(photoqt_RESOURCES ${photoqt_RESOURCES} ${d}/fadein.qrc)
SET(photoqt_RESOURCES ${photoqt_RESOURCES} ${d}/mainview.qrc)
SET(photoqt_RESOURCES ${photoqt_RESOURCES} ${d}/openfile.qrc)
SET(photoqt_RESOURCES ${photoqt_RESOURCES} ${d}/other.qrc)
SET(photoqt_RESOURCES ${photoqt_RESOURCES} ${d}/settingsmanager.qrc)
SET(photoqt_RESOURCES ${photoqt_RESOURCES} ${d}/slidein.qrc)
SET(photoqt_RESOURCES ${photoqt_RESOURCES} ${d}/globalstrings.qrc)

# Add language resource file
SET(photoqt_RESOURCES ${photoqt_RESOURCES} ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc)

# And the images
SET(photoqt_RESOURCES ${photoqt_RESOURCES} img.qrc)
