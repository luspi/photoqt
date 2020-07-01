import QtQuick 2.9

PQFileTypeTile {

    title: "Qt plugins"

    available: PQImageFormats.getAvailableEndingsWithDescriptionQt()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsQt()
    currentlyEnabled: PQImageFormats.enabledFileformatsQt
    projectWebpage: ["qt", "https://doc.qt.io/qt-5/qtimageformats-index.html",
                     "kde", "https://api.kde.org/frameworks/kimageformats/html/index.html",
                     "libqpsd", "https://github.com/roniemartinez/libqpsd",
                     "avif", "https://github.com/novomesk/qt-avif-image-plugin"]
    description: "These are all the image formats either natively supported by Qt or through an image formats plugins: <b>qt5-imageformats, kimageformats, libqpsd, avif</b>"

    iconsource: "/settingsmanager/filetypes/qt.png"

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            resetChecked()
        }

        onSaveAllSettings: {
            var c = []
            for(var key in checkedItems) {
                if(checkedItems[key])
                    c.push(key)
            }
            PQImageFormats.enabledFileformatsQt = c
        }

    }

    Component.onCompleted: {
        resetChecked()
    }
}
