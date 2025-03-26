SET(photoqt_SOURCES ${photoqt_SOURCES} extensions/pqc_extensionshandler.cpp extensions/pqc_configtemplate.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/header/pqc_extensionshandler.h)

# LIST ALL EXTENSIONS HERE
SET(EXT "QuickActions" "FloatingNavigation" "Histogram" "MapCurrent")
SET(EXT ${EXT} "ScaleImage" "CropImage")

foreach(qmlfile ${EXT})

    STRING(TOLOWER ${qmlfile} folder)

    SET(d "extensions/${folder}")
    SET(photoqt_QML ${photoqt_QML} ${d}/PQ${qmlfile}.qml ${d}/PQ${qmlfile}Popout.qml ${d}/PQ${qmlfile}Settings.qml)
    SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/config.h)

endforeach()
