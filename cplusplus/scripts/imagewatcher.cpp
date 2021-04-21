#include "imagewatcher.h"

PQImageWatcher::PQImageWatcher(QObject *parent) : QObject(parent) {

    watcher = new QFileSystemWatcher;
    connect(watcher, &QFileSystemWatcher::fileChanged, this, &PQImageWatcher::imageChangedSLOT);

}

PQImageWatcher::~PQImageWatcher() {
    delete watcher;
}

void PQImageWatcher::imageChangedSLOT() {

    QFileInfo info(m_imagePath);
    for(int i = 0; i < 5; ++i) {
        if(info.exists())
            break;
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }

    if(info.exists()) {
        emit imageChanged();
        watcher->addPath(m_imagePath);
    } else
        emit imageDeleted();

}
