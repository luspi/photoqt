/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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
#pragma once

#include <imageplugins/pqc_imageplugin.h>
#include <QSet>
#include <QMutex>

class PQCImagePluginDevIL : public PQCImagePlugin {

public:
    PQCImagePluginDevIL();

    const QString name() override { return "DevIL"; }
    const QString category() override { return "image"; }
    const bool canPreload() override { return true; }

    const QSize loadSize(QString path) override;
    const QImage loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) override;
    const bool writeImage(QImage img, QString targetPath) override;

private:
#ifdef PQMDEVIL
    // DevIL is not threadsafe -> this ensures only one image is loaded at a time
    mutable QMutex devilMutex;
#endif

#ifdef PQMDEVIL
    static QString checkForError();
#endif

};
