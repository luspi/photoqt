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

#include <pqc_imageplugin_resvg.h>
#include <pqc_settingscpp.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <pqc_imagecache.h>
#include <pqc_helper.h>

#include <QFile>
#include <QtDebug>
#ifdef PQMRESVG
#include <ResvgQt.h>
#endif

PQCImagePluginResvg::PQCImagePluginResvg(QString settingsDir) : m_settingsDir(settingsDir) {

    m_composedWritableSuffixes = false;

    loadFormats();

}

const QString PQCImagePluginResvg::getDescription(QString suffix) {
    return suffix2description.value(suffix.toLower(), "");
}

const QSet<QString> PQCImagePluginResvg::getSuffixesForFormatByDescription(QString description) {
    QSet<QString> ret;
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            ret.insert(suf);
    }
    return ret;
}

const bool PQCImagePluginResvg::supportsFormatByDescription(QString description) {
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            return true;
    }
    return false;
}

const bool PQCImagePluginResvg::isEnabled(QString description) {
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            return m_suffixes.contains(suf);
    }
    return false;
}

const QSet<QString> PQCImagePluginResvg::getWritableSuffixes() {

    return {};

}

const bool PQCImagePluginResvg::writeImage(QImage img, QString targetPath) {
    return false;
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

void PQCImagePluginResvg::setEnabled(QString description, bool enabled) {

    // first find all the suffixes and mimetypes for this format description
    QSet<QString> suffixes, mimetypes;
    for(const auto &[key, value] : std::as_const(suffix2description).asKeyValueRange()) {
        if(value == description)
            suffixes.insert(key);
    }
    for(const auto &[key, value] : std::as_const(mimetype2description).asKeyValueRange()) {
        if(value == description)
            mimetypes.insert(key);
    }

    // then find the ones stored as toggled
    QSet<QString> storedSuffixes, storedMimetypes;

    const QString suffixFilename = m_settingsDir % "/resvg_suffixes";
    QFile suffixFile(suffixFilename);
    if(suffixFile.exists()) {
        if(!suffixFile.open(QIODevice::ReadOnly|QIODevice::Text)) {
            qWarning() << "Failed to open settings file at:" << suffixFilename;
            return;
        } else {
            QTextStream suffixIn(&suffixFile);
            const QStringList tmp = suffixIn.readAll().split("\n", Qt::SkipEmptyParts);
            storedSuffixes = QSet<QString>(tmp.begin(), tmp.end());
            suffixFile.close();
        }
    }

    const QString mimeFilename = m_settingsDir % "/resvg_mimetypes";
    QFile mimeFile(mimeFilename);
    if(mimeFile.exists()) {
        if(!mimeFile.open(QIODevice::ReadOnly|QIODevice::Text)) {
            qWarning() << "Failed to open settings file at:" << mimeFilename;
            return;
        } else {
            QTextStream mimeIn(&mimeFile);
            const QStringList tmp = mimeIn.readAll().split("\n", Qt::SkipEmptyParts);
            storedMimetypes = QSet<QString>(tmp.begin(), tmp.end());
            mimeFile.close();
        }
    }

    // if we toggle this format then we only need to make sure they are added to the list, nothing else
    if((enabledByDefault() && !enabled) || (!enabledByDefault() && enabled)) {

        storedSuffixes += suffixes;
        storedMimetypes += mimetypes;

        // otherwise we need to make sure that no suffix is part of the list
    } else {

        QSet<QString> newsetSuffixes, newsetMime;

        for(const QString &s : std::as_const(storedSuffixes)) {
            if(!suffixes.contains(s))
                newsetSuffixes.insert(s);
        }
        for(const QString &m : std::as_const(storedMimetypes)) {
            if(!mimetypes.contains(m))
                newsetMime.insert(m);
        }

        storedSuffixes = newsetSuffixes;
        storedMimetypes = newsetMime;

    }

    QFile outSuffixFile(suffixFilename);
    if(!outSuffixFile.open(QIODevice::WriteOnly|QIODevice::Text|QIODevice::Truncate)) {
        qDebug() << "Failed to open settings file at:" << suffixFilename;
    } else {
        QTextStream suffixOut(&outSuffixFile);
        suffixOut << PQCHelper::setJoin(storedSuffixes, "\n");
        outSuffixFile.close();
    }

    QFile outMimeFile(mimeFilename);
    if(!outMimeFile.open(QIODevice::WriteOnly|QIODevice::Text|QIODevice::Truncate)) {
        qDebug() << "Failed to open settings file at:" << mimeFilename;
    } else {
        QTextStream mimeOut(&outMimeFile);
        mimeOut << PQCHelper::setJoin(storedMimetypes, "\n");
        outMimeFile.close();
    }

}

/***********************************************/

void PQCImagePluginResvg::loadFormats() {

    m_suffixes.clear();
    m_toggledSuffixes.clear();
    m_allSuffixes.clear();

    // first we read the toggled suffixes from the settings file
    const QString suffixFilename = m_settingsDir % "/resvg_suffixes";
    QFile suffixFile(suffixFilename);
    if(!suffixFile.open(QIODevice::ReadOnly|QIODevice::Text)) {

        qDebug() << "Failed to open settings file at:" << suffixFilename;

    } else {

        QTextStream suffixIn(&suffixFile);
        const QStringList tmp = suffixIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_toggledSuffixes = QSet<QString>(tmp.begin(), tmp.end());
        suffixFile.close();

    }

    // then we store ALL supported suffixes
    m_allSuffixes = {"svg", "svgz"};

    // these are the currently enabled ones
    m_suffixes = m_allSuffixes - m_toggledSuffixes;

    suffix2description = {
        {"svg",  "SVG: Scalable Vector Graphics"},
        {"svgz", "SVG: Scalable Vector Graphics"}
    };

    /********************************/

    m_mimetypes.clear();
    m_toggledMimetypes.clear();
    m_allMimetypes.clear();

    const QString mimeFilename = m_settingsDir % "/resvg_mimetypes";
    QFile mimeFile(mimeFilename);
    if(!mimeFile.open(QIODevice::ReadOnly|QIODevice::Text)) {
        qDebug() << "Failed to open settings file at:" << mimeFilename;
    } else {
        QTextStream mimeIn(&mimeFile);
        const QStringList tmp = mimeIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_toggledMimetypes = QSet<QString>(tmp.begin(), tmp.end());
        mimeFile.close();
    }

    // then we store ALL supported mimetypes
    m_allMimetypes = {"image/svg+xml"};

    // these are the currently enabled ones
    m_mimetypes = m_allMimetypes - m_toggledMimetypes;

    mimetype2description = {
        {"image/svg+xml", "SVG: Scalable Vector Graphics"}
    };

    Q_EMIT formatsUpdated();

}
