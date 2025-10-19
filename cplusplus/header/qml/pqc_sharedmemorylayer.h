/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 ** Adapted from: https://github.com/mpv-player/mpv-examples/            **
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

#include <shared/pqc_sharedconstants.h>

#include <QObject>
#include <QQmlEngine>

class PQSharedMemoryLayer : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit PQSharedMemoryLayer() {}

    Q_INVOKABLE QStringList getImageFormats(QString cat) { return PQCSharedMemory::get().getImageFormats(cat); }
    Q_INVOKABLE QStringList getImageFormatsMimeTypes(QString cat) { return PQCSharedMemory::get().getImageFormatsMimeTypes(cat); }
    Q_INVOKABLE QVariantList getImageFormatsAllFormats() { return PQCSharedMemory::get().getImageFormatsAllFormats(); }

};
