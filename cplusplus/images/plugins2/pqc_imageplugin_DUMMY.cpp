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

#include <pqc_imageplugin_qt.h>

PQCImagePluginQt::PQCImagePluginQt(QString settingsFile) {

}

const bool PQCImagePluginQt::canWrite(QString path) {
    return false;
}

const bool PQCImagePluginQt::writeImage(QImage img, QString targetPath) {
    return false;
}

const QSize PQCImagePluginQt::getSize(QString path) {
    return QSize();
}

const QImage PQCImagePluginQt::getImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {
    return QImage();
}

void PQCImagePluginQt::setEnabled(QString suffix, QString mimetype, bool enabled) {

}

/***********************************************/

void PQCImagePluginQt::loadFormats() {

}

void PQCImagePluginQt::saveFormats() {

}
