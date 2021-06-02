/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

#include "imageproperties.h"

PQImageProperties::PQImageProperties(QObject *parent) : QObject(parent) { }


bool PQImageProperties::isAnimated(QString path) {

    DBG << CURDATE << "PQImageProperties::isAnimated()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QImageReader reader(path);

    return (reader.supportsAnimation()&&reader.imageCount()>1);


}

bool PQImageProperties::isPopplerDocument(QString path) {

    DBG << CURDATE << "PQImageProperties::isPopplerDocument()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QString suf = QFileInfo(path).suffix().toLower();
    const QStringList tmp = PQImageFormats::get().getEnabledFormatsPoppler();
    foreach(QString f, tmp) {
        if(f == suf)
            return true;
    }
    return false;

}

bool PQImageProperties::isArchive(QString path) {

    DBG << CURDATE << "PQImageProperties::isArchive()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QString suf = QFileInfo(path).suffix().toLower();
    const QStringList tmp = PQImageFormats::get().getEnabledFormatsLibArchive();
    foreach(QString f, tmp) {
        if(f == suf)
            return true;
    }
    return false;

}

int PQImageProperties::getDocumentPages(QString path) {

    DBG << CURDATE << "PQImageProperties::getDocumentPages()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    if(path.trimmed().isEmpty())
        return 0;

    if(path.contains("::PQT::"))
        path = path.split("::PQT::").at(1);

#ifdef POPPLER
    Poppler::Document* document = Poppler::Document::load(path);
    if(document && !document->isLocked())
        return document->numPages();
#endif
    return 0;

}
