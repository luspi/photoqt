SET(photoqt_SOURCES ${photoqt_SOURCES} extensions/pqc_extensionshandler.cpp extensions/pqc_configtemplate.h)
SET(photoqt_SOURCES ${photoqt_SOURCES} cplusplus/header/pqc_extensionshandler.h)

SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} extensions/pqc_extensionshandler.cpp extensions/pqc_configtemplate.h)
SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} cplusplus/header/pqc_extensionshandler.h)

# LIST ALL EXTENSIONS HERE
SET(EXT "Histogram" "MapCurrent" "QuickActions" "ScaleImage" "ExportImage" "CropImage" "FloatingNavigation" "Wallpaper" "ImgurCom")

foreach(qmlfile ${EXT})

    STRING(TOLOWER ${qmlfile} folder)

    SET(d "extensions/${folder}")
    SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/config.h)
    SET(d "extensions/${folder}/modern")
    SET(photoqt_QML ${photoqt_QML} ${d}/PQ${qmlfile}.qml ${d}/PQ${qmlfile}Popout.qml ${d}/PQ${qmlfile}Settings.qml)

endforeach()

SET(d "extensions/wallpaper/modern/wallpaperparts")
SET(photoqt_QML ${photoqt_QML} ${d}/PQEnlightenment.qml ${d}/PQGnome.qml ${d}/PQOther.qml ${d}/PQPlasma.qml ${d}/PQWindows.qml ${d}/PQXfce.qml)
