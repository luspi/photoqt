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

#include <pqc_imageplugin_video.h>
#include <pqc_settingscpp.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <pqc_imagecache.h>

#include <QFile>
#include <QtDebug>

PQCImagePluginVideo::PQCImagePluginVideo(QString settingsDir) : m_settingsDir(settingsDir) {

    m_composedWritableSuffixes = false;

    loadFormats();

}

const QString PQCImagePluginVideo::getDescription(QString suffix) {
    return suffix2description.value(suffix, "");
}

const QSet<QString> PQCImagePluginVideo::getWritableSuffixes() {

    return {};

}

const bool PQCImagePluginVideo::writeImage(QImage img, QString targetPath) {
    return false;
}

const QSize PQCImagePluginVideo::loadSize(QString path) {

    return QSize();

}

const QImage PQCImagePluginVideo::loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    return QImage();

}

void PQCImagePluginVideo::setEnabled(QString suffix, QString mimetype, bool enabled) {

}

/***********************************************/

void PQCImagePluginVideo::loadFormats() {

    m_suffixes.clear();
    m_toggledSuffixes.clear();
    m_allSuffixes.clear();

    // first we read the toggled suffixes from the settings file
    const QString suffixFilename = m_settingsDir % "/video_suffixes";
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
    m_allSuffixes = {"amv", "asf", "avi", "flv", "f4v", "mkv", "mov", "qt",
                     "ogg", "ogv", "vob", "webm", "mp4", "m4v", "mpg", "mp2",
                     "mpeg", "mpe", "mpv", "m2v", "3gp", "3g2", "wmv"};

    // these are the currently enabled ones
    m_suffixes = m_allSuffixes - m_toggledSuffixes;

    suffix2description = {
        {"amv", "AMV video format"},
        {"asf", "Advanced Systems Format"},
        {"avi", "Audio Video Interleave"},
        {"flv", "Flash Video"},
        {"f4v", "Flash Video"},
        {"mkv", "Matroska Video"},
        {"mov", "QuickTime File Format"},
        {"qt",  "QuickTime File Format"},
        {"ogg", "Theora"},
        {"ogv", "Theora"},
        {"vob", "Video Object"},
        {"webm", "WebM"},
        {"mp4", "MP4: MPEG-4 Part 14"},
        {"m4v", "MP4: MPEG-4 Part 14"},
        {"mpg",  "MPEG: Moving Picture Experts Group"},
        {"mp2",  "MPEG: Moving Picture Experts Group"},
        {"mpeg", "MPEG: Moving Picture Experts Group"},
        {"mpe",  "MPEG: Moving Picture Experts Group"},
        {"mpv",  "MPEG: Moving Picture Experts Group"},
        {"m2v",  "MPEG: Moving Picture Experts Group"},
        {"3gp", "3GP: 3rd Generation Partnership Project"},
        {"3g2", "3GP: 3rd Generation Partnership Project"},
        {"wmv", "Windows Media Video"}
    };

    /********************************/

    m_mimetypes.clear();
    m_toggledMimetypes.clear();
    m_allMimetypes.clear();

    const QString mimeFilename = m_settingsDir % "/video_mimetypes";
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
    m_allMimetypes = {"video/x-ms-asf", "application/vnd.ms-asf", "video/vnd.avi",
                      "video/avi", "video/msvideo", "video/x-msvideo", "video/x-flv",
                      "video/x-matroska", "video/quicktime", "video/webm", "video/mp4",
                      "video/mpeg", "video/3gpp", "video/3gpp2", "video/x-ms-wmv"};

    // these are the currently enabled ones
    m_mimetypes = m_allMimetypes - m_toggledMimetypes;

    Q_EMIT formatsUpdated();

}

void PQCImagePluginVideo::saveFormats() {

    // TODO

}
