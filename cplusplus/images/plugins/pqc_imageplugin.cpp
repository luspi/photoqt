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

#include <pqc_imageplugin.h>
#include <QTimer>

PQCImagePlugin::PQCImagePlugin(QObject *parent) : QObject(parent) {

    m_delayWriteToFile = new QTimer;
    m_delayWriteToFile->setInterval(500);
    m_delayWriteToFile->setSingleShot(true);

#if __cplusplus >= 202002L
    connect(m_delayWriteToFile, &QTimer::timeout, this, [=, this]() {
#else
    connect(m_delayWriteToFile, &QTimer::timeout, this, [=]() {
#endif

        const QString suffixFilename = PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins/" % m_settingsPrefix % "_suffixes";
        QFile outSuffixFile(suffixFilename);
        if(!outSuffixFile.open(QIODevice::WriteOnly|QIODevice::Text|QIODevice::Truncate)) {
            qDebug() << "Failed to open settings file at:" << suffixFilename;
        } else {
            QTextStream suffixOut(&outSuffixFile);
            suffixOut << PQCHelper::setJoin(m_disabledSuffixes, "\n");
            outSuffixFile.close();
        }

        const QString mimeFilename = PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins/" % m_settingsPrefix % "_mimetypes";
        QFile outMimeFile(mimeFilename);
        if(!outMimeFile.open(QIODevice::WriteOnly|QIODevice::Text|QIODevice::Truncate)) {
            qDebug() << "Failed to open settings file at:" << mimeFilename;
        } else {
            QTextStream mimeOut(&outMimeFile);
            mimeOut << PQCHelper::setJoin(m_disabledMimetypes, "\n");
            outMimeFile.close();
        }

    });

}

PQCImagePlugin::~PQCImagePlugin() {
    m_delayWriteToFile->deleteLater();
}

void PQCImagePlugin::setData(const QHash<QString, QList<QSet<QString> > > dat, const QString settingsPrefix,
             QSet<QString> defaultDisabledSuffixes, QSet<QString> defaultDisabledMimetypes) {

    m_settingsPrefix = settingsPrefix;
    m_description2data = dat;
    m_defaultDisabledSuffixes = defaultDisabledSuffixes;
    m_defaultDisabledMimetypes = defaultDisabledMimetypes;

    // this is VERY cheap and will make looking up a description much faster
    for(const auto &[key, value] : std::as_const(m_description2data).asKeyValueRange()) {
        for(const QString &suffix : value[0])
            m_suffix2description.insert(suffix, key);
        m_allSuffixes += value[0];
        m_allMimetypes += value[1];
    }

    loadSetttingsFromFiles();

}

void PQCImagePlugin::setEnabled(QString description, bool enabled) {

    m_delayWriteToFile->stop();

    QHash<QString, QList<QSet<QString> > >::Iterator iter = m_description2data.find(description);
    if(iter == m_description2data.end())
        return;

    const QList<QSet<QString> > &cur = iter.value();

    // if we toggle this format then we only need to make sure they are added to the list, nothing else
    if(!enabled) {

        m_disabledSuffixes += cur[0];
        m_disabledMimetypes += cur[1];

        // otherwise we need to make sure that no suffix is part of the list
    } else {

        m_disabledSuffixes.subtract(cur[0]);
        m_disabledMimetypes.subtract(cur[1]);

    }

    m_delayWriteToFile->start();

}

void PQCImagePlugin::loadSetttingsFromFiles() {

    /********************************/

    // first we read the toggled suffixes from the settings file
    const QString suffixFilename = PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins/" % m_settingsPrefix % "_suffixes";
    QFile suffixFile(suffixFilename);
    if(!suffixFile.open(QIODevice::ReadOnly|QIODevice::Text)) {

        qDebug() << "Failed to open settings file at:" << suffixFilename;

        // these are the ones DISABLED BY DEFAULT
        m_disabledSuffixes = m_defaultDisabledSuffixes;

    } else {

        QTextStream suffixIn(&suffixFile);
        const QStringList tmp = suffixIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_disabledSuffixes = QSet<QString>(tmp.begin(), tmp.end());
        suffixFile.close();

    }

    // these are the currently enabled ones
    m_suffixes = m_allSuffixes - m_disabledSuffixes;

    /********************************/

    const QString mimeFilename = PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins/" % m_settingsPrefix % "_mimetypes";
    QFile mimeFile(mimeFilename);
    if(!mimeFile.open(QIODevice::ReadOnly|QIODevice::Text)) {

        qDebug() << "Failed to open settings file at:" << mimeFilename;

        // these are the ones DISABLED BY DEFAULT
        m_disabledMimetypes = m_defaultDisabledMimetypes;

    } else {
        QTextStream mimeIn(&mimeFile);
        const QStringList tmp = mimeIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_disabledMimetypes = QSet<QString>(tmp.begin(), tmp.end());
        mimeFile.close();
    }

    // these are the currently enabled ones
    m_mimetypes = m_allMimetypes - m_disabledMimetypes;

    Q_EMIT formatsUpdated();

}
