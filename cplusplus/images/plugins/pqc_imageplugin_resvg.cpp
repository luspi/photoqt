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
#ifdef PQMRESVG_QT
#include <ResvgQt.h>
#else
#include <resvg/resvg.h>
#endif
#endif

PQCImagePluginResvg::PQCImagePluginResvg() {

#ifdef PQMRESVG
    setData({{26112, {{"SVG: Scalable Vector Graphics"}, {"svg", "svgz"}, {"image/svg+xml"}}}},
            "resvg");
#endif

}

const QSize PQCImagePluginResvg::loadSize(QString path) {

#ifdef PQMRESVG

#ifdef PQMRESVG_QT

    ResvgOptions opt;
    ResvgRenderer renderer(path, opt);
    return renderer.defaultSize();

#else

    resvg_options *opt = resvg_options_create();

    resvg_render_tree *tree = NULL;
    if(resvg_parse_tree_from_file(path.toUtf8().constData(), opt, &tree) != RESVG_OK) {
        resvg_options_destroy(opt);
        return QSize();
    }

    resvg_size size = resvg_get_image_size(tree);

    resvg_tree_destroy(tree);
    resvg_options_destroy(opt);

    return QSize(size.width, size.height);

#endif

#endif

    return QSize();

}

const QImage PQCImagePluginResvg::loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    // we don't write output here as this plugin is also used for all ui icons and thus would produce a LOT of output

#ifdef PQMRESVG

#ifdef PQMRESVG_QT

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

#else

    resvg_options *opt = resvg_options_create();

    // Needed if the SVG contains text.
    resvg_options_load_system_fonts(opt);

    resvg_render_tree *tree = nullptr;
    if(resvg_parse_tree_from_file(path.toUtf8().constData(), opt, &tree) != RESVG_OK) {
        resvg_options_destroy(opt);
        const QString msg = "Invalid SVG encountered";
        error += msg % "\n";
        qWarning() << msg;
        return QImage();
    }

    resvg_size svgSize = resvg_get_image_size(tree);
    origSize = QSize(svgSize.width, svgSize.height);

    QImage img;

    if(requestedSize.isEmpty()) {

        img = QImage(origSize, QImage::Format_RGBA8888_Premultiplied);

        img.fill(Qt::transparent);

        resvg_render(tree, resvg_transform_identity(), img.width(), img.height(), reinterpret_cast<char *>(img.bits()));

    } else {

        img = QImage(origSize.scaled(requestedSize, Qt::KeepAspectRatio), QImage::Format_RGBA8888_Premultiplied);

        img.fill(Qt::transparent);

        resvg_size size = resvg_get_image_size(tree);

        resvg_transform t = resvg_transform_identity();
        t.a = img.width() / size.width;
        t.d = img.height() / size.height;

        resvg_render(tree, t, img.width(), img.height(), reinterpret_cast<char *>(img.bits()));

    }

    origSize = img.size();

    resvg_tree_destroy(tree);
    resvg_options_destroy(opt);

    return img;

#endif

#endif

    return QImage();

}

const bool PQCImagePluginResvg::writeImage(QImage img, QString targetPath) {
    return false;
}
