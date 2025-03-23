# LIST LL EXTENSIONS HERE
SET(EXT "QuickActions" "FloatingNavigation" "Histogram")

foreach(qmlfile ${EXT})

    STRING(TOLOWER ${qmlfile} folder)

    SET(d "extensions/${folder}")
    SET(photoqt_QML ${photoqt_QML} ${d}/PQ${qmlfile}.qml ${d}/PQ${qmlfile}Popout.qml ${d}/PQ${qmlfile}Settings.qml)
    SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/config.h)

endforeach()
