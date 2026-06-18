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

#include <imageplugins/pqc_imageplugin_qt.h>
#include <imageplugins/pqc_imageplugin_resvg.h>
#include <imageplugins/pqc_imageplugin_pdf.h>
#include <imageplugins/pqc_imageplugin_libraw.h>
#include <imageplugins/pqc_imageplugin_libarchive.h>
#include <imageplugins/pqc_imageplugin_libsai.h>
#include <imageplugins/pqc_imageplugin_video.h>
#include <imageplugins/pqc_imageplugin_magick.h>
#include <imageplugins/pqc_imageplugin_devil.h>
#include <imageplugins/pqc_imageplugin_libvips.h>

#include <QMimeDatabase>

PQCImageHandler::PQCImageHandler() {

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
#ifdef PQMVIDEOQT
           << "video"
#endif
#ifdef PQMVIDEOMPV
           << "libmpv"
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
#ifdef PQMVIDEOQT
                    << "video"
#endif
#ifdef PQMVIDEOMPV
                    << "libmpv"
#endif
        ;

    /*******************************************************/

    m_plugins.insert("qt", new PQCImagePluginQt);
#ifdef PQMRESVG
    m_plugins.insert("resvg", new PQCImagePluginResvg);
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
#ifdef PQMVIDEOQT
    m_plugins.insert("video", new PQCImagePluginVideo(false));
#endif
#ifdef PQMVIDEOMPV
    m_plugins.insert("libmpv", new PQCImagePluginVideo(true));
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

        m_enabledIds += plugin->getEnabledFormats();
        m_enabledSuffixes += plugin->getEnabledSuffixes();
        m_enabledMimetypes += plugin->getEnabledMimetypes();
        m_disabledIds += plugin->getDisabledFormats();
        m_disabledSuffixes += plugin->getDisabledSuffixes();
        m_disabledMimetypes += plugin->getDisabledMimetypes();
        m_writableIds += plugin->getWritableFormats();
        m_suffix2id.insert(plugin->getSuffix2IdMapping());
        m_desc2id.insert(plugin->getDescription2IdMapping());

    }

    m_numEnabled = m_enabledSuffixes.size();

}

QSize PQCImageHandler::getSize(QString path) {

    QFileInfo info(path);
    const QString suffix1 = info.suffix().toLower();
    const QString suffix2 = info.completeSuffix().toLower();

    for(const QString &name : std::as_const(m_pluginOrder)) {

        if(!m_plugins.contains(name)) continue;

        PQCImagePlugin *plugin = m_plugins[name];

        QSet<QString> suf = plugin->getEnabledSuffixes();
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

        QSet<QString> mim = plugin->getEnabledMimetypes();
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

    const bool doNotThread = m_doNotThreadFormats.contains(m_suffix2id.value(suffix1, m_suffix2id.value(suffix2, -1)));
    if(doNotThread) providerMutex.lock();

    for(const QString &name : std::as_const(m_pluginOrder)) {

        if(!m_plugins.contains(name)) continue;

        PQCImagePlugin *plugin = m_plugins[name];

        QSet<QString> suf = plugin->getEnabledSuffixes();
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

        QSet<QString> mim = plugin->getEnabledMimetypes();
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

QSet<int> PQCImageHandler::getEnabledFormats(QString category) {

    if(category == "all") return m_enabledIds;

    if(m_plugins.contains(category))
        return m_plugins.value(category)->getEnabledFormats();

    return {};

}

QSet<int> PQCImageHandler::getDisabledFormats(QString category) {

    if(category == "all") return m_disabledIds;

    if(m_plugins.contains(category))
        return m_plugins.value(category)->getDisabledFormats();

    return {};

}

QSet<QString> PQCImageHandler::getEnabledSuffixes(QString category) {

    if(category == "all") return m_enabledSuffixes;

    if(m_plugins.contains(category))
        return m_plugins.value(category)->getEnabledSuffixes();

    return {};

}

QSet<QString> PQCImageHandler::getEnabledSuffixes(QStringList categories) {

    QSet<QString> ret;

    for(const QString &c : std::as_const(categories)) {
        if(m_plugins.contains(c))
            ret += m_plugins.value(c)->getEnabledSuffixes();
    }

    return ret;

}

QSet<QString> PQCImageHandler::getEnabledMimetypes(QString category) {

    if(category == "all") return m_enabledMimetypes;

    if(m_plugins.contains(category))
        return m_plugins.value(category)->getEnabledMimetypes();

    return {};

}

QSet<QString> PQCImageHandler::getEnabledMimetypes(QStringList categories) {

    QSet<QString> ret;

    for(const QString &c : std::as_const(categories)) {
        if(m_plugins.contains(c))
            ret += m_plugins.value(c)->getEnabledMimetypes();
    }

    return ret;

}

QSet<QString> PQCImageHandler::getDisabledSuffixes(QString category) {

    if(category == "all") return m_disabledSuffixes;

    if(m_plugins.contains(category))
        return m_plugins.value(category)->getDisabledSuffixes();

    return {};

}

QSet<QString> PQCImageHandler::getDisabledMimetypes(QString category) {

    if(category == "all") return m_disabledMimetypes;

    if(m_plugins.contains(category))
        return m_plugins.value(category)->getDisabledMimetypes();

    return {};

}

QSet<int> PQCImageHandler::getWritableFormats(QString category) {

    if(category == "all") return m_writableIds;

    if(m_plugins.contains(category))
        return m_plugins.value(category)->getWritableFormats();

    return {};

}

QSet<int> PQCImageHandler::getWritableFormats(QStringList categories) {

    QSet<int> ret;

    for(const QString &c : std::as_const(categories)) {
        if(m_plugins.contains(c))
            ret += m_plugins.value(c)->getWritableFormats();
    }

    return ret;

}

QString PQCImageHandler::getFormatName(int format) {

    for(PQCImagePlugin *plugin : std::as_const(m_plugins)) {

        QString desc = plugin->getDescription(format);
        if(desc != "") return desc;

    }

    return "";

}

QString PQCImageHandler::getFormatName(QString file) {

    QFileInfo info(file);
    const QString suf1 = info.suffix().toLower();
    const QString suf2 = info.completeSuffix().toLower();

    for(PQCImagePlugin *plugin : std::as_const(m_plugins)) {

        QString desc = plugin->getDescription(m_suffix2id.value(suf1, m_suffix2id.value(suf2, -1)));
        if(desc != "") return desc;

    }

    return "";

}

int PQCImageHandler::getFormatIdFromName(QString name) {
    return m_desc2id.value(name, -1);
}

QStringList PQCImageHandler::getPluginNames() {
    QStringList ret;
    for(const QString &plugin: std::as_const(m_pluginOrderForSettings))
        ret.append(m_plugins[plugin]->name());
    return ret;
}

QStringList PQCImageHandler::getPluginsForFormat(int format) {

    QStringList ret;
    for(const QString &plugin: std::as_const(m_pluginOrder)) {
        if(m_plugins[plugin]->supportsFormat(format)) {
            const QString name = m_plugins[plugin]->name();
            if(!ret.contains(name))
                ret.append(name);
        }
    }
    return ret;

}

QStringList PQCImageHandler::getAllSuffixesForFormat(int format) {

    QStringList ret;
    for(const QString &plugin: std::as_const(m_pluginOrder)) {
        if(m_plugins[plugin]->supportsFormat(format)) {
            const QStringList lst = m_plugins[plugin]->getSuffixesForFormat(format);
            for(const QString &l : lst) {
                if(!ret.contains(l))
                    ret.append(l);
            }
        }
    }
    return ret;

}

QStringList PQCImageHandler::getAllMimetypesForFormat(int format) {

    QStringList ret;
    for(const QString &plugin: std::as_const(m_pluginOrder)) {
        if(m_plugins[plugin]->supportsFormat(format)) {
            const QStringList lst = m_plugins[plugin]->getMimetypesForFormat(format);
            for(const QString &l : lst) {
                if(!ret.contains(l))
                    ret.append(l);
            }
        }
    }
    return ret;

}

QString PQCImageHandler::getCategoryForFormat(int format) {
    for(const QString &plugin: std::as_const(m_pluginOrder)) {
        if(m_plugins[plugin]->supportsFormat(format))
            return m_plugins[plugin]->category();
    }
    return "";
}

bool PQCImageHandler::isEnabled(QString plugin, int format) {
    for(const QString &name : std::as_const(m_pluginOrder)) {
        if(name == plugin || m_plugins[name]->name() == plugin)
            return m_plugins[name]->isEnabled(format);
    }
    return false;
}

void PQCImageHandler::setEnabled(QString pluginName, int format, bool enabled) {

    for(PQCImagePlugin *plugin : std::as_const(m_plugins)) {
        if(plugin->name() == pluginName)
            plugin->setEnabled(format, enabled);
    }

}

void PQCImageHandler::setAllEnabled(int format, bool enabled) {

    qDebug() << "args: format =" << format;
    qDebug() << "args: enabled =" << enabled;

    for(PQCImagePlugin *plugin : std::as_const(m_plugins)) {
        plugin->setEnabled(format, enabled);
    }

}

void PQCImageHandler::resetAllToDefaultEnabled() {

    QDir dir(PQCConfigFiles::get().IMAGEPLUGINS_SETTINGS_DIR());
    if(!dir.exists())
        return;

    dir.removeRecursively();
    dir.mkpath(PQCConfigFiles::get().IMAGEPLUGINS_SETTINGS_DIR());

}
