import QtQuick 2.9

PQFileTypeTile {

    title: "Qt plugins"

    available: PQImageFormats.getAvailableEndingsWithDescriptionQt()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsQt()
    currentlyEnabled: PQImageFormats.enabledFileformatsQt
    projectWebpage: ["doc.qt.io", "https://doc.qt.io/qt-5/qtimageformats-index.html",
                     "api.kde.org", "https://api.kde.org/frameworks/kimageformats/html/index.html"]

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
}
