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
#include <pqc_scriptscolorprofiles.h>
#include <pqc_imagecache.h>
#include <pqc_settingscpp.h>

#include <pqc_imageplugin_qt.h>
#include <pqc_imageplugin_resvg.h>
#include <pqc_imageplugin_pdf.h>
#include <pqc_imageplugin_libraw.h>
#include <pqc_imageplugin_libarchive.h>
#include <pqc_imageplugin_libsai.h>
#include <pqc_imageplugin_video.h>
#include <pqc_imageplugin_magick.h>
#include <pqc_imageplugin_devil.h>
#include <pqc_imageplugin_libvips.h>

#include <QMimeDatabase>

PQCImageHandler::PQCImageHandler() {

    // these crash when loaded in parallel -> protect loading these with a mutex
    m_doNotThreadFormats = {"jpeg2000", "jp2", "jpc", "jpx", "jpf", "j2c", "mj2"};

    /*******************************************************/

    m_pluginOrder = QStringList()
#ifdef PQMRESVG
        << "resvg"
#endif
#if defined(PQMPOPPLER) || defined(PQMQTPDF)
        << "pdf"
#endif
        << "qt"
#ifdef PQMRAW
        << "libraw"
#endif
#ifdef PQMLIBARCHIVE
        << "libarchive"
#endif
#ifdef PQMLIBSAI
        << "libsai"
#endif
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
        << "magick"
#endif
#ifdef PQMLIBVIPS
        << "libvips"
#endif
#ifdef PQMDEVIL
        << "devil"
#endif
#if defined(PQMVIDEOQT) || defined(PQMVIDEOMPV)
        << "video"
#endif
    ;

    /*******************************************************/
    // For the SETTINGS MANAGER the order is slightly different
    m_pluginOrderForSettings = QStringList()
                    << "qt"
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
                    << "magick"
#endif
#ifdef PQMLIBVIPS
                    << "libvips"
#endif
#ifdef PQMDEVIL
                     << "devil"
#endif
#ifdef PQMRAW
                    << "libraw"
#endif
#ifdef PQMLIBARCHIVE
                    << "libarchive"
#endif
#ifdef PQMRESVG
                    << "resvg"
#endif
#if defined(PQMPOPPLER) || defined(PQMQTPDF)
                    << "pdf"
#endif
#ifdef PQMLIBSAI
                    << "libsai"
#endif
#if defined(PQMVIDEOQT) || defined(PQMVIDEOMPV)
                    << "video"
#endif
        ;

    /*******************************************************/

    m_plugins.insert("qt", new PQCImagePluginQt);
#ifdef PQMRESVG
    plugins.insert("resvg", new PQCImagePluginResvg);
#endif
#if defined(PQMPOPPLER) || defined(PQMQTPDF)
    m_plugins.insert("pdf", new PQCImagePluginPDF);
#endif
#ifdef PQMRAW
    m_plugins.insert("libraw", new PQCImagePluginLibraw);
#endif
#ifdef PQMLIBARCHIVE
    m_plugins.insert("libarchive", new PQCImagePluginLibarchive);
#endif
#ifdef PQMLIBSAI
    m_plugins.insert("libsai", new PQCImagePluginLibsai);
#endif
#if defined(PQMVIDEOQT) || defined(PQMVIDEOMPV)
    m_plugins.insert("video", new PQCImagePluginVideo);
#endif
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
    m_plugins.insert("magick", new PQCImagePluginMagick);
#endif
#ifdef PQMDEVIL
    m_plugins.insert("devil", new PQCImagePluginDevIL);
#endif
#ifdef PQMLIBVIPS
    m_plugins.insert("libvips", new PQCImagePluginLibVips);
#endif

    /*******************************************************/

    for(PQCImagePlugin *plugin : std::as_const(m_plugins)) {

        connect(plugin, &PQCImagePlugin::formatsUpdated, this, &PQCImageHandler::formatsUpdated);

        m_suffixes += plugin->getSuffixes();
        m_mimetypes += plugin->getMimetypes();
        m_writableSuffixes += plugin->getWritableSuffixes();

    }

    m_numEnabled = m_suffixes.size();

}

QSize PQCImageHandler::getSize(QString path) {

    QFileInfo info(path);
    const QString suffix1 = info.suffix().toLower();
    const QString suffix2 = info.completeSuffix().toLower();

    for(const QString &name : std::as_const(m_pluginOrder)) {

        if(!m_plugins.contains(name)) continue;

        PQCImagePlugin *plugin = m_plugins[name];

        QSet<QString> suf = plugin->getSuffixes();
        if(suf.contains(suffix1) || suf.contains(suffix2)) {

            QSize sze = plugin->loadSize(path);
            if(!sze.isEmpty())
                return sze;

        }

    }

    QMimeDatabase db;
    const QString mimetype = db.mimeTypeForFile(path).name();

    for(const QString &name : std::as_const(m_pluginOrder)) {

        if(!m_plugins.contains(name)) continue;

        PQCImagePlugin *plugin = m_plugins[name];

        QSet<QString> mim = plugin->getMimetypes();
        if(mim.contains(mimetype)) {

            QSize sze = plugin->loadSize(path);
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

    const bool doNotThread = m_doNotThreadFormats.contains(suffix1);
    if(doNotThread) providerMutex.lock();

    for(const QString &name : std::as_const(m_pluginOrder)) {

        if(!m_plugins.contains(name)) continue;

        PQCImagePlugin *plugin = m_plugins[name];

        QSet<QString> suf = plugin->getSuffixes();
        if(suf.contains(suffix1) || suf.contains(suffix2)) {

            img = plugin->loadImage(path, requestedSize, origSize, error);
            if(!img.isNull()) {
                if(doNotThread) providerMutex.unlock();
                return img;
            }

        }

    }

    QMimeDatabase db;
    const QString mimetype = db.mimeTypeForFile(path).name();

    for(const QString &name : std::as_const(m_pluginOrder)) {

        if(!m_plugins.contains(name)) continue;

        PQCImagePlugin *plugin = m_plugins[name];

        QSet<QString> mim = plugin->getMimetypes();
        if(mim.contains(mimetype)) {

            img = plugin->loadImage(path, requestedSize, origSize, error);
            if(!img.isNull()) {
                if(doNotThread) providerMutex.unlock();
                return img;
            }

        }

    }

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)

    img = m_plugins["magick"]->loadImage(path, requestedSize, origSize, error);
    if(doNotThread) providerMutex.unlock();
    return img;

#endif

    if(doNotThread) providerMutex.unlock();

    return QImage();

}

QImage PQCImageHandler::getImageWithPlugin(QString plugin, QString path, QSize requestedSize, QSize &origSize, QString &error) {

    if(!m_pluginOrder.contains(plugin)) {
        qWarning() << "Requested plugin" << plugin << "not found.";
        return QImage();
    }

    return m_plugins.value(plugin)->loadImage(path, requestedSize, origSize, error);

}

bool PQCImageHandler::canWrite(QString path) {

    QFileInfo info(path);

    return (m_writableSuffixes.contains(info.suffix().toLower()) || m_writableSuffixes.contains(info.completeSuffix().toLower()));

}

bool PQCImageHandler::writeImage(QImage img, QString targetPath) {

    for(PQCImagePlugin *plugin : std::as_const(m_plugins)) {

        bool ret = plugin->writeImage(img, targetPath);
        if(ret) return true;

    }

    return false;

}

QSet<QString> PQCImageHandler::getSuffixes(QString category) {

    if(category == "all") return m_suffixes;

    if(m_plugins.contains(category))
        return m_plugins.value(category)->getSuffixes();

    return m_suffixes;

}

QSet<QString> PQCImageHandler::getSuffixes(QStringList categories) {

    QSet<QString> ret;

    for(const QString &c : std::as_const(categories)) {
        if(m_plugins.contains(c))
            ret += m_plugins.value(c)->getSuffixes();
    }

    return ret;

}

QSet<QString> PQCImageHandler::getMimetypes(QString category) {

    if(category == "all") return m_mimetypes;

    if(m_plugins.contains(category))
        return m_plugins.value(category)->getMimetypes();

    return m_mimetypes;

}

QSet<QString> PQCImageHandler::getMimetypes(QStringList categories) {

    QSet<QString> ret;

    for(const QString &c : std::as_const(categories)) {
        if(m_plugins.contains(c))
            ret += m_plugins.value(c)->getMimetypes();
    }

    return ret;

}

QSet<QString> PQCImageHandler::getWritableSuffixes(QString category) {

    if(category == "all") return m_writableSuffixes;

    if(m_plugins.contains(category))
        return m_plugins.value(category)->getWritableSuffixes();

    return m_writableSuffixes;

}

QSet<QString> PQCImageHandler::getWritableSuffixes(QStringList categories) {

    QSet<QString> ret;

    for(const QString &c : std::as_const(categories)) {
        if(m_plugins.contains(c))
            ret += m_plugins.value(c)->getWritableSuffixes();
    }

    return ret;

}

QString PQCImageHandler::getDescription(QString suffix) {

    for(PQCImagePlugin *plugin : std::as_const(m_plugins)) {

        QString desc = plugin->getDescription(suffix);
        if(desc != "") return desc;

    }

    return "";

}

QStringList PQCImageHandler::getPluginNames() {
    QStringList ret;
    for(const QString &plugin: std::as_const(m_pluginOrderForSettings))
        ret.append(m_plugins[plugin]->name());
    return ret;
}

QStringList PQCImageHandler::getPluginsForFormatByDescription(QString description) {

    QStringList ret;
    for(const QString &plugin: std::as_const(m_pluginOrder)) {
        if(m_plugins[plugin]->supportsFormatByDescription(description))
            ret << m_plugins[plugin]->name();
    }
    return ret;

}

QStringList PQCImageHandler::getAllSuffixesForFormatByDescription(QString description) {

    QSet<QString> ret;
    for(const QString &plugin: std::as_const(m_pluginOrder)) {
        if(m_plugins[plugin]->supportsFormatByDescription(description))
            ret += m_plugins[plugin]->getSuffixesForFormatByDescription(description);
    }
    return ret.values();

}

QString PQCImageHandler::getCategoryForFormatByDescription(QString description) {
    for(const QString &plugin: std::as_const(m_pluginOrder)) {
        if(m_plugins[plugin]->supportsFormatByDescription(description))
            return m_plugins[plugin]->category();
    }
    return "";
}

QStringList PQCImageHandler::getAllDescriptions() {

    QStringList ret;

    for(const QString &name : std::as_const(m_pluginOrder)) {
        PQCImagePlugin *plugin = m_plugins[name];
        const QStringList lst = plugin->getAllDescriptions();
        for(const QString &d : lst) {
            if(!ret.contains(d))
                ret << d;
        }
    }

    return ret;

}

bool PQCImageHandler::isEnabled(QString plugin, QString description) {
    for(const QString &name : std::as_const(m_pluginOrder)) {
        if(name == plugin || m_plugins[name]->name() == plugin)
            return m_plugins[name]->isEnabled(description);
    }
    return false;
}

void PQCImageHandler::setEnabled(QString pluginName, QString description, bool enabled) {

    for(PQCImagePlugin *plugin : std::as_const(m_plugins)) {
        if(plugin->name() == pluginName)
            plugin->setEnabled(description, enabled);
    }

}
