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

void PQCImagePluginResvg::saveFormats() {

    // TODO

}
