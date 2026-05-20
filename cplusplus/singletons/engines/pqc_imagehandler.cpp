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

#include <pqc_imagehandler.h>
#include <pqc_configfiles.h>
#include <pqc_imageplugin_qt.h>
#include <pqc_scriptscolorprofiles.h>
#include <pqc_imagecache.h>
#include <pqc_settingscpp.h>
#include <QMimeDatabase>

PQCImageHandler::PQCImageHandler() {

    const QString setDir = PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins";

    pluginOrder = {"qt", "magick", "svg", "pdf"};

    plugins.insert("qt", new PQCImagePluginQt(setDir));
    plugins.insert("magick", new PQCImagePluginQt(setDir));

    for(PQCImagePlugin *plugin : std::as_const(plugins)) {

        connect(plugin, &PQCImagePlugin::formatsUpdated, this, &PQCImageHandler::formatsUpdated);

        m_suffixes += plugin->getSuffixes();
        m_mimetypes += plugin->getMimetypes();

    }
    m_numEnabled = m_suffixes.size();

}

QSize PQCImageHandler::getSize(QString path) {

    QFileInfo info(path);
    const QString suffix1 = info.suffix().toLower();
    const QString suffix2 = info.completeSuffix().toLower();

    for(PQCImagePlugin *plugin : std::as_const(plugins)) {

        QSet<QString> suf = plugin->getSuffixes();
        if(suf.contains(suffix1) || suf.contains(suffix2)) {

            QSize sze = plugin->getSize(path);
            if(!sze.isEmpty())
                return sze;

        }

    }

    QMimeDatabase db;
    const QString mimetype = db.mimeTypeForFile(path).name();

    for(PQCImagePlugin *plugin : std::as_const(plugins)) {

        QSet<QString> mim = plugin->getMimetypes();
        if(mim.contains(mimetype)) {

            QSize sze = plugin->getSize(path);
            if(!sze.isEmpty())
                return sze;

        }

    }

    return QSize();

}

QImage PQCImageHandler::getImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    if(path.trimmed().isEmpty())
        return QImage();

    QFileInfo info(path);

    if(info.isSymLink() && info.exists())
        path = info.symLinkTarget();

    // check image cache, we might be done right here
    QImage img;
    if(PQCImageCache::get().getCachedImage(path, PQCScriptsColorProfiles::get().getColorProfileFor(path), img)) {
        origSize = img.size();
        if(requestedSize.width() > 2 && requestedSize.height() > 2 && origSize.width() > requestedSize.width() && origSize.height() > requestedSize.height())
            return img.scaled(requestedSize, Qt::KeepAspectRatio,
                              (PQCSettingsCPP::get().getImageviewRescalingSmooth() ? Qt::SmoothTransformation : Qt::FastTransformation));
        return img;
    }

    const QString suffix1 = info.suffix().toLower();
    const QString suffix2 = info.completeSuffix().toLower();

    for(PQCImagePlugin *plugin : std::as_const(plugins)) {

        QSet<QString> suf = plugin->getSuffixes();
        if(suf.contains(suffix1) || suf.contains(suffix2)) {

            img = plugin->getImage(path, requestedSize, origSize, error);
            if(!img.isNull())
                return img;

        }

    }

    QMimeDatabase db;
    const QString mimetype = db.mimeTypeForFile(path).name();

    for(PQCImagePlugin *plugin : std::as_const(plugins)) {

        QSet<QString> mim = plugin->getMimetypes();
        if(mim.contains(mimetype)) {

            img = plugin->getImage(path, requestedSize, origSize, error);
            if(!img.isNull())
                return img;

        }

    }

    return QImage();

}

bool PQCImageHandler::canWrite(QString path) {

    for(PQCImagePlugin *plugin : std::as_const(plugins)) {

        bool ret = plugin->canWrite(path);
        if(ret) return true;

    }

    return false;

}

bool PQCImageHandler::writeImage(QImage img, QString targetPath) {

    for(PQCImagePlugin *plugin : std::as_const(plugins)) {

        bool ret = plugin->writeImage(img, targetPath);
        if(ret) return true;

    }

    return false;

}

QSet<QString> PQCImageHandler::getSuffixes(QString category) {

    if(category == "all") return m_suffixes;

    if(plugins.contains(category))
        return plugins.value(category)->getSuffixes();

    return m_suffixes;

}

QSet<QString> PQCImageHandler::getSuffixes(QStringList categories) {

    QSet<QString> ret;

    for(const QString &c : std::as_const(categories)) {
        if(plugins.contains(c))
            ret += plugins.value(c)->getSuffixes();
    }

    return ret;

}

QSet<QString> PQCImageHandler::getMimetypes(QString category) {

    if(category == "all") return m_mimetypes;

    if(plugins.contains(category))
        return plugins.value(category)->getMimetypes();

    return m_mimetypes;

}

QSet<QString> PQCImageHandler::getMimetypes(QStringList categories) {

    QSet<QString> ret;

    for(const QString &c : std::as_const(categories)) {
        if(plugins.contains(c))
            ret += plugins.value(c)->getMimetypes();
    }

    return ret;

}

QString PQCImageHandler::getDescription(QString suffix) {

    for(PQCImagePlugin *plugin : std::as_const(plugins)) {

        QString desc = plugin->getDescription(suffix);
        if(desc != "") return desc;

    }

    return "";

}
