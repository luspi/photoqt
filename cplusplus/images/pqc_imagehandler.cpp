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

    const QString setDir = PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins";

    // these crash when loaded in parallel -> protect loading these with a mutex
    m_doNotThreadFormats = {"jpeg2000", "jp2", "jpc", "jpx", "jpf", "j2c", "mj2"};

    pluginOrder = QStringList()
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

    plugins.insert("qt", new PQCImagePluginQt(setDir));
#ifdef PQMRESVG
    plugins.insert("resvg", new PQCImagePluginResvg(setDir));
#endif
#if defined(PQMPOPPLER) || defined(PQMQTPDF)
    plugins.insert("pdf", new PQCImagePluginPDF(setDir));
#endif
#ifdef PQMRAW
    plugins.insert("libraw", new PQCImagePluginLibraw(setDir));
#endif
#ifdef PQMLIBARCHIVE
    plugins.insert("libarchive", new PQCImagePluginLibarchive(setDir));
#endif
#ifdef PQMLIBSAI
    plugins.insert("libsai", new PQCImagePluginLibsai(setDir));
#endif
#if defined(PQMVIDEOQT) || defined(PQMVIDEOMPV)
    plugins.insert("video", new PQCImagePluginVideo(setDir));
#endif
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
    plugins.insert("magick", new PQCImagePluginMagick(setDir));
#endif
#ifdef PQMDEVIL
    plugins.insert("devil", new PQCImagePluginDevIL(setDir));
#endif
#ifdef PQMLIBVIPS
    plugins.insert("libvips", new PQCImagePluginLibVips(setDir));
#endif

    for(PQCImagePlugin *plugin : std::as_const(plugins)) {

        connect(plugin, &PQCImagePlugin::formatsUpdated, this, &PQCImageHandler::formatsUpdated);

        m_suffixes += plugin->getSuffixes();
        m_mimetypes += plugin->getMimetypes();

    }
    m_numEnabled = m_suffixes.size();

    m_composedWritableSuffixes = false;

}

QSize PQCImageHandler::getSize(QString path) {

    QFileInfo info(path);
    const QString suffix1 = info.suffix().toLower();
    const QString suffix2 = info.completeSuffix().toLower();

    for(const QString &name : std::as_const(pluginOrder)) {

        if(!plugins.contains(name)) continue;

        PQCImagePlugin *plugin = plugins[name];

        QSet<QString> suf = plugin->getSuffixes();
        if(suf.contains(suffix1) || suf.contains(suffix2)) {

            QSize sze = plugin->loadSize(path);
            if(!sze.isEmpty())
                return sze;

        }

    }

    QMimeDatabase db;
    const QString mimetype = db.mimeTypeForFile(path).name();

    for(const QString &name : std::as_const(pluginOrder)) {

        if(!plugins.contains(name)) continue;

        PQCImagePlugin *plugin = plugins[name];

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

    for(const QString &name : std::as_const(pluginOrder)) {

        if(!plugins.contains(name)) continue;

        PQCImagePlugin *plugin = plugins[name];

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

    for(const QString &name : std::as_const(pluginOrder)) {

        if(!plugins.contains(name)) continue;

        PQCImagePlugin *plugin = plugins[name];

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

    img = plugins["magick"]->loadImage(path, requestedSize, origSize, error);
    if(doNotThread) providerMutex.unlock();
    return img;

#endif

    if(doNotThread) providerMutex.unlock();

    return QImage();

}

QImage PQCImageHandler::getImageWithPlugin(QString plugin, QString path, QSize requestedSize, QSize &origSize, QString &error) {

    if(!pluginOrder.contains(plugin)) {
        qWarning() << "Requested plugin" << plugin << "not found.";
        return QImage();
    }

    return plugins.value(plugin)->loadImage(path, requestedSize, origSize, error);

}

bool PQCImageHandler::canWrite(QString path) {

    QFileInfo info(path);

    return (m_writableSuffixes.contains(info.suffix().toLower()) || m_writableSuffixes.contains(info.completeSuffix().toLower()));

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

QSet<QString> PQCImageHandler::getWritableSuffixes(QString category) {

    if(!m_composedWritableSuffixes) {
        for(PQCImagePlugin *plugin : std::as_const(plugins)) {
            m_writableSuffixes += plugin->getWritableSuffixes();
        }
        m_composedWritableSuffixes = true;
    }

    if(category == "all") return m_writableSuffixes;

    if(plugins.contains(category))
        return plugins.value(category)->getWritableSuffixes();

    return m_writableSuffixes;

}

QSet<QString> PQCImageHandler::getWritableSuffixes(QStringList categories) {

    QSet<QString> ret;

    for(const QString &c : std::as_const(categories)) {
        if(plugins.contains(c))
            ret += plugins.value(c)->getWritableSuffixes();
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

QStringList PQCImageHandler::getPluginNames() {
    QStringList ret;
    for(const QString &plugin: std::as_const(pluginOrder))
        ret.append(plugins[plugin]->name());
    return ret;
}

QStringList PQCImageHandler::getPluginsForFormatByDescription(QString description) {

    QStringList ret;
    for(const QString &plugin: std::as_const(pluginOrder)) {
        if(plugins[plugin]->supportsFormatByDescription(description))
            ret << plugins[plugin]->name();
    }
    return ret;

}

QStringList PQCImageHandler::getAllDescriptions() {

    QStringList ret;

    for(const QString &name : std::as_const(pluginOrder)) {
        PQCImagePlugin *plugin = plugins[name];
        QStringList allSuffixes = plugin->getSuffixes().values();
        allSuffixes.sort(Qt::CaseInsensitive);
        for(const QString &suf : std::as_const(allSuffixes)) {
            const QString dsc = plugin->getDescription(suf);
            if(!ret.contains(dsc))
                ret.append(dsc);
        }
    }

    return ret;

}


//     // description => suffixes,
//     QMap<QString, QMap<QString,QVariantList> > ret;

//     for(PQCImagePlugin *plugin : std::as_const(plugins)) {

//         const QString name = plugin->name();

//         QSet<QString> allSuffixes = plugin->getAllSuffixes();
//         QSet<QString> allMimetypes = plugin->getAllMimetypes();

//         QSet<QString> enabledSuffixes = plugin->getSuffixes();
//         QSet<QString> enabledMimetypes = plugin->getMimetypes();


//         for(const QString &s : allSuffixes) {

//             const QString desc = plugin->getDescription(s);
//             QMap<QString, QVariantList> dat;
//             if(ret.contains(desc)) {
//                 dat = ret.value(desc);
//             } else {
//                 QVariantList sL;
//                 QVariantList mL;
//                 QVariantList sm = {sL, mL};
//                 QVariantMap smMap;
//                 dat.insert(name, sm);
//             }

//             QVariantList curList = dat.value(name).toList().value(0).toList();
//             curList.append(s);
//             curList.append(enabledSuffixes.contains(s) ? 1 : 0);

//             QVariantList mimList = dat.value(name).toList().value(1).toList();

//             QVariantList sm = {curList, mimList};
//             dat.insert(name, sm);
//             ret.insert(desc, dat);

//         }

//         // for(const QString &m : allMimetypes) {

//         //     const QString desc = plugin->getDescription(m);
//         //     QVariantMap dat;
//         //     if(ret.contains(desc)) {
//         //         dat = ret.value(desc);
//         //     } else {
//         //         QVariantList sL;
//         //         QVariantList mL;
//         //         QVariantList sm = {sL, mL};
//         //         QVariantMap smMap;
//         //         smMap.insert(name, sm);
//         //         dat = smMap;
//         //     }

//         //     QVariantList curList = dat.value(name).toList().value(1).toList();
//         //     curList.append(m);
//         //     curList.append(enabledMimetypes.contains(m) ? 1 : 0);

//         //     ret.insert(desc, dat);

//         // }


//     }

//     QVariantList lst;
//     const QStringList dscs = ret.keys();
//     for(const QString &dsc : dscs) {
//         lst << dsc;

//         QVariantList l;
//         QMap<QString, QVariantList> dat = ret.value(dsc);
//         const QStringList plugins = dat.keys();
//         for(const QString &plugin : plugins) {
//             l << plugin << dat.value(plugin);
//         }

//         lst << ret.value(key).;
//         // lst << l;
//     }

//     return lst;

// }

bool PQCImageHandler::isEnabled(QString plugin, QString description) {
    for(const QString &name : std::as_const(pluginOrder)) {
        if(name == plugin || plugins[name]->name() == plugin)
            return plugins[name]->supportsFormatByDescription(description);
    }
    return false;
}
