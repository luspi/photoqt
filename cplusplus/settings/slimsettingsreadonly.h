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

#ifndef SLIMSETTINGSREADONLY_H
#define SLIMSETTINGSREADONLY_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QTimer>
#include <QFileInfo>

#include "../logger.h"
#include "../configfiles.h"

class SlimSettingsReadOnly : public QObject {

    Q_OBJECT

public:
    SlimSettingsReadOnly(QObject *parent = 0);

    int pixmapCache;
    bool thumbnailCache;
    bool thumbnailCacheFile;

    bool metaApplyRotation;

    bool metaDimensions;
    bool metaMake;
    bool metaModel;
    bool metaSoftware;
    bool metaTimePhotoTaken;
    bool metaExposureTime;
    bool metaFlash;
    bool metaIso;
    bool metaSceneType;
    bool metaFLength;
    bool metaFNumber;
    bool metaLightSource;
    bool metaKeywords;
    bool metaLocation;
    bool metaCopyright;
    bool metaGps;

    void setDefault();
    void readSettings();

private:
    QFileSystemWatcher *watcher;
    QTimer *watcherAddFileTimer;

private slots:
    void addFileToWatcher();

};

#endif // SLIMSETTINGSREADONLY_H
