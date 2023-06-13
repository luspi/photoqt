/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#include "loadimage_qtpdf.h"
#include "../../logger.h"
#include "../../settings/settings.h"

PQLoadImageQtPDF::PQLoadImageQtPDF() {
    errormsg = "";
}

QSize PQLoadImageQtPDF::loadSize(QString filename) {

    QSize s;
    load(filename, QSize(), s, true);
    return s;

}

QImage PQLoadImageQtPDF::load(QString filename, QSize maxSize, QSize &origSize, bool stopAfterSize) {

    DBG << CURDATE << "PQLoadImageQtPDF::load()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL
        << CURDATE << "** maxSize = " << maxSize.width() << "x" << maxSize.height() << NL
        << CURDATE << "** stopAfterSize = " << stopAfterSize << NL;

#ifdef QTPDF

    errormsg = "";

    // extract page and totalpage value from filename (prepended to filename (after filepath))
    int page = 0;
    if(filename.contains("::PQT::")) {
        page = filename.split("::PQT::").at(0).toInt();
        filename = filename.split("::PQT::").at(1);
    }

    QPdfDocument doc;
    doc.load(filename);

    QPdfDocument::Status err = doc.status();
    if(err == QPdfDocument::Error) {
        errormsg = QString("Error occured loading PDF: %1").arg(err);
        LOG << CURDATE << "PQLoadImageQtPDF::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    QSizeF _pageSize = (doc.pageSize(page)/72.0*qApp->primaryScreen()->physicalDotsPerInch())*(PQSettings::get()["filetypesPDFQuality"].toDouble()/72.0);
    origSize = QSize(_pageSize.width(), _pageSize.height());

    if(stopAfterSize)
        return QImage();

    QImage p = doc.render(page, origSize);

    if(p.isNull()) {
        errormsg = QString("Unable to read page %1").arg(page);
        LOG << CURDATE << "PQLoadImageQtPDF::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // some pdfs don't specify a background
    // in that case the resulting image will have a transparent background
    // to "fix" this we simply draw the image on top of a white image
    QImage ret(p.size(), p.format());
    ret.fill(Qt::white);
    QPainter paint(&ret);
    paint.drawImage(QRect(QPoint(0,0),ret.size()), p);
    paint.end();

    return ret;

#endif

    origSize = QSize(-1,-1);
    errormsg = "Failed to load image, QtPDF not supported by this build of PhotoQt!";
    LOG << CURDATE << "PQLoadImageQtPDF::load(): " << errormsg.toStdString() << NL;
    return QImage();

}
