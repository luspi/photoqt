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

#include <imageplugins/pqc_imageplugin_resvg.h>
#include <pqc_settingscpp.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <pqc_imagecache.h>
#include <pqc_helper.h>

#include <QFile>
#include <QtDebug>
#ifdef PQMRESVG
#include <ResvgQt.h>
#endif

PQCImagePluginResvg::PQCImagePluginResvg() {

    setData({{"SVG: Scalable Vector Graphics",
                    {{"svg", "svgz"}, {"image/svg+xml"}}}},
            "resvg");

}

const QSize PQCImagePluginResvg::loadSize(QString path) {

#ifdef PQMRESVG

    ResvgOptions opt;
    ResvgRenderer renderer(path, opt);
    return renderer.defaultSize();

#endif

    return QSize();

}

const QImage PQCImagePluginResvg::loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: requestedSize =" << requestedSize;

#ifdef PQMRESVG

    ResvgOptions opt;
    ResvgRenderer renderer(path, opt);

    if(!renderer.isValid()) {
        const QString msg = "Invalid SVG encountered";
        error += msg % "\n";
        qWarning() << msg;
        return QImage();
    }

    QImage img;

    if(requestedSize.isValid()) {
        QSize defaultSize = renderer.defaultSize();
        if(defaultSize.isEmpty()) defaultSize = requestedSize;
        img = renderer.renderToImage(defaultSize.scaled(requestedSize, Qt::KeepAspectRatio));
    } else
        img = renderer.renderToImage();

    origSize = img.size();

    return img;

#endif

    return QImage();

}

const bool PQCImagePluginResvg::writeImage(QImage img, QString targetPath) {
    return false;
}
