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

#include <imageplugins/pqc_imageplugin.h>
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
        if(!outSuffixFile.open(QIODevice::WriteOnly)) {
            qDebug() << "Failed to open settings file at:" << suffixFilename;
            qDebug() << outSuffixFile.errorString();
        } else {
            QTextStream suffixOut(&outSuffixFile);
            suffixOut << PQCHelper::setJoin(m_disabledSuffixes, "\n");
            outSuffixFile.close();
        }

        const QString mimeFilename = PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins/" % m_settingsPrefix % "_mimetypes";
        QFile outMimeFile(mimeFilename);
        if(!outMimeFile.open(QIODevice::WriteOnly)) {
            qDebug() << "Failed to open settings file at:" << mimeFilename;
            qDebug() << outMimeFile.errorString();
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
    m_format2data = dat;
    m_defaultDisabledSuffixes = defaultDisabledSuffixes;
    m_defaultDisabledMimetypes = defaultDisabledMimetypes;

    // this is VERY cheap and will make looking up a description much faster
    for(const auto &[key, value] : std::as_const(m_format2data).asKeyValueRange()) {
        for(const QString &suffix : value[0])
            m_suffix2format.insert(suffix, key);
    }

    loadSetttingsFromFiles();

}

void PQCImagePlugin::setWritableFormats(const QSet<QString> formats)  {
    m_writableFormats = formats;
    for(const QString &f : formats) {
        const QList<QSet<QString> > cur = m_format2data.value(f);
        m_writableSuffixes += cur[0];
    }
}

void PQCImagePlugin::setEnabled(QString format, bool enabled) {

    QHash<QString, QList<QSet<QString> > >::Iterator iter = m_format2data.find(format);
    if(iter == m_format2data.end())
        return;

    m_delayWriteToFile->stop();

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

        while(!suffixIn.atEnd()) {
            QString line = suffixIn.readLine().trimmed();
            if(!line.isEmpty())
                m_disabledSuffixes.insert(line);
        }

        suffixFile.close();

    }

    /********************************/

    const QString mimeFilename = PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins/" % m_settingsPrefix % "_mimetypes";
    QFile mimeFile(mimeFilename);
    if(!mimeFile.open(QIODevice::ReadOnly|QIODevice::Text)) {

        qDebug() << "Failed to open settings file at:" << mimeFilename;

        // these are the ones DISABLED BY DEFAULT
        m_disabledMimetypes = m_defaultDisabledMimetypes;

    } else {

        QTextStream mimeIn(&mimeFile);

        while(!mimeIn.atEnd()) {
            QString line = mimeIn.readLine().trimmed();
            if(!line.isEmpty())
                m_disabledMimetypes.insert(line);
        }

        mimeFile.close();

    }


    // these are the currently enabled ones
    for(const auto &[key, value] : std::as_const(m_format2data).asKeyValueRange()) {
        const QList<QSet<QString> > lst = value.toList();
        if(m_disabledSuffixes.contains(*(lst.value(0).begin()))) {
            m_disabledFormats.insert(key);
        } else {
            m_enabledFormats.insert(key);
            m_enabledSuffixes += lst.value(0);
            m_enabledMimetypes += lst.value(1);
        }
    }

    Q_EMIT formatsUpdated();

}
