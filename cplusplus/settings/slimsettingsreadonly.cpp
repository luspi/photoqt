/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#include "slimsettingsreadonly.h"

SlimSettingsReadOnly::SlimSettingsReadOnly(QObject *parent) : QObject(parent) {

    watcher = new QFileSystemWatcher;
    connect(watcher, &QFileSystemWatcher::fileChanged, [this](QString){ readSettings(); });

    watcherAddFileTimer = new QTimer;
    watcherAddFileTimer->setInterval(500);
    watcherAddFileTimer->setSingleShot(true);
    connect(watcherAddFileTimer, &QTimer::timeout, this, &SlimSettingsReadOnly::addFileToWatcher);

    // Set default values to start out with
    setDefault();
    readSettings();

}

void SlimSettingsReadOnly::setDefault() {

    pixmapCache = 128;
    thumbnailCache = true;
    thumbnailCacheFile = true;

    metaApplyRotation = true;

    metaDimensions = true;
    metaMake = true;
    metaModel = true;
    metaSoftware = true;
    metaTimePhotoTaken = true;
    metaExposureTime = true;
    metaFlash = true;
    metaIso = true;
    metaSceneType = true;
    metaFLength = true;
    metaFNumber = true;
    metaLightSource = true;
    metaKeywords = true;
    metaLocation = true;
    metaCopyright = true;
    metaGps = true;

}

void SlimSettingsReadOnly::readSettings() {

    watcherAddFileTimer->start();

    QFile file(ConfigFiles::SETTINGS_FILE());

    if(file.exists() && !file.open(QIODevice::ReadOnly))

        LOG << CURDATE << "SlimSettingsReadOnly::readSettings() - ERROR: " << file.errorString().trimmed().toStdString() << NL;

    else if(file.exists() && file.isOpen()) {

        if(qgetenv("PHOTOQT_DEBUG") == "yes")
            LOG << CURDATE << "SlimSettingsReadOnly::readSettings() - reading settings" << NL;

        // Read file
        QTextStream in(&file);
        QStringList parts = in.readAll().split("\n");
        file.close();

        for(QString line : parts) {

            if(line.startsWith("PixmapCache="))
                pixmapCache = line.split("=").at(1).toInt();
            else if(line.startsWith("ThumbnailCache="))
                thumbnailCache = line.split("=").at(1).toInt();
            else if(line.startsWith("ThumbnailCacheFile="))
                thumbnailCacheFile = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaApplyRotation="))
                metaApplyRotation = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaDimensions="))
                metaDimensions = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaMake="))
                metaMake = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaModel="))
                metaModel = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaSoftware="))
                metaSoftware = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaTimePhotoTaken="))
                metaTimePhotoTaken = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaExposureTime="))
                metaExposureTime = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaFlash="))
                metaFlash = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaIso="))
                metaIso = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaSceneType="))
                metaSceneType = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaFLength="))
                metaFLength = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaFNumber="))
                metaFNumber = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaLightSource="))
                metaLightSource = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaGps="))
                metaGps = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaKeywords="))
                metaKeywords = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaLocation="))
                metaLocation = line.split("=").at(1).toInt();
            else if(line.startsWith("MetaCopyright="))
                metaCopyright = line.split("=").at(1).toInt();

        }

    } else
        if(qgetenv("PHOTOQT_DEBUG") == "yes")
            LOG << CURDATE << "SlimSettingsReadOnly::readSettings() - no settings to read (or file not open)" << NL;

}

void SlimSettingsReadOnly::addFileToWatcher() {
    QFileInfo info(ConfigFiles::SETTINGS_FILE());
    if(!info.exists()) {
        watcherAddFileTimer->start();
        return;
    }
    watcher->removePath(ConfigFiles::SETTINGS_FILE());
    watcher->addPath(ConfigFiles::SETTINGS_FILE());
}
