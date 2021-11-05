# All the qml files
SET(photoqt_RESOURCES ${photoqt_RESOURCES} qml/qml.qrc)

# Add language resource file
SET(photoqt_RESOURCES ${photoqt_RESOURCES} ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc)

# And the images
SET(photoqt_RESOURCES ${photoqt_RESOURCES} img/img.qrc img/filetypes.qrc)

# Any other file (e.g. default imageformats database)
SET(photoqt_RESOURCES ${photoqt_RESOURCES} misc/misc.qrc python/python.qrc)
