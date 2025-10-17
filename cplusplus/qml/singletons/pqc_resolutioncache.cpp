/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

#include <qml/pqc_resolutioncache.h>

#include <QFileInfo>
#include <QCryptographicHash>
#include <QSize>

PQCResolutionCache::PQCResolutionCache(QObject *parent) : QObject(parent) {}
PQCResolutionCache::~PQCResolutionCache() {}

void PQCResolutionCache::saveResolution(QString filename, QSize res) {
    qDebug() << "args: filename =" << filename;
    qDebug() << "args: res =" << res;
    resolution[getKey(filename)] = res;
}

QSize PQCResolutionCache::getResolution(QString filename) {
    return resolution[getKey(filename)];
}

QString PQCResolutionCache::getKey(QString filename) {
    QFileInfo info(filename);
    return QCryptographicHash::hash(QString("%1%2").arg(filename).arg(info.size()).toUtf8(),QCryptographicHash::Md5).toHex();
}
