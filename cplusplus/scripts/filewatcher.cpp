#include "filewatcher.h"

PQFileWatcher::PQFileWatcher(QObject *parent) : QObject(parent) {

    userPlacesWatcher = new QFileSystemWatcher;
    connect(userPlacesWatcher, &QFileSystemWatcher::fileChanged, this, &PQFileWatcher::userPlacesChangedSLOT);
    userPlacesWatcher->addPath(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");

}

void PQFileWatcher::userPlacesChangedSLOT() {
    emit userPlacesChanged();

    QFileInfo info(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");
    for(int i = 0; i < 40; ++i) {
        if(info.exists())
            break;
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }
    if(info.exists())
        userPlacesWatcher->addPath(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");

}
