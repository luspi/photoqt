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

        const QString filename = PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins/" % m_settingsPrefix;
        QFile outFile(filename);
        if(!outFile.open(QIODevice::WriteOnly)) {
            qDebug() << "Failed to open settings file at:" << filename;
            qDebug() << outFile.errorString();
        } else {
            QTextStream out(&outFile);
            out << PQCHelper::setJoin(m_disabledIds, "\n");
            outFile.close();
        }

    });

}

PQCImagePlugin::~PQCImagePlugin() {
    m_delayWriteToFile->deleteLater();
}

void PQCImagePlugin::setData(const QHash<int, QList<QStringList > > dat, const QString settingsPrefix,
             QSet<int> defaultDisabledFormats) {

    m_settingsPrefix = settingsPrefix;
    m_id2data = dat;
    m_defaultDisabledIds = defaultDisabledFormats;

    // this is VERY cheap and will make looking up a description much faster
    for(const auto &[key, value] : std::as_const(m_id2data).asKeyValueRange()) {
        m_desc2id.insert(value[0][0], key);
        m_enabledIds.insert(key);
        for(const QString &suffix : value[1]) {
            m_suffix2id.insert(suffix, key);
            m_enabledSuffixes.insert(suffix);
        }
        for(const QString &mime : value[2]) {
            m_mime2id.insert(mime, key);
            m_enabledMimetypes.insert(mime);
        }
    }

    loadSetttingsFromFiles();

}

void PQCImagePlugin::setWritableFormats(const QSet<int> formats)  {
    m_writableIds = formats;
    for(const int &f : formats) {
        const QList<QStringList > cur = m_id2data.value(f);
        for(const QString &s : cur[1])
            m_writableSuffixes.insert(s);
    }
}

void PQCImagePlugin::setEnabled(int format, bool enabled) {

    QHash<int, QList<QStringList> >::Iterator iter = m_id2data.find(format);
    if(iter == m_id2data.end())
        return;

    m_delayWriteToFile->stop();

    const QList<QStringList > &cur = iter.value();

    // if we toggle this format then we only need to make sure they are added to the list, nothing else
    if(!enabled) {

        m_disabledIds.insert(format);
        m_enabledIds.remove(format);

        for(const QString &s : cur[1]) {
            m_disabledSuffixes.insert(s);
            m_enabledSuffixes.remove(s);
        }
        for(const QString &m : cur[2]) {
            m_disabledMimetypes .insert(m);
            m_enabledMimetypes .remove(m);
        }

        // otherwise we need to make sure that no suffix is part of the list
    } else {

        m_disabledIds.remove(format);
        m_enabledIds.insert(format);

        for(const QString &s : cur[1]) {
            m_disabledSuffixes.remove(s);
            m_enabledSuffixes.insert(s);
        }
        for(const QString &m : cur[2]) {
            m_disabledMimetypes.remove(m);
            m_enabledMimetypes.insert(m);
        }

    }

    m_delayWriteToFile->start();

}

void PQCImagePlugin::loadSetttingsFromFiles() {

    /********************************/

    // first we read the toggled suffixes from the settings file
    const QString suffixFilename = PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins/" % m_settingsPrefix;
    QFile suffixFile(suffixFilename);
    if(!suffixFile.open(QIODevice::ReadOnly|QIODevice::Text)) {

        qDebug() << "Failed to open settings file at:" << suffixFilename;

        // these are the ones DISABLED BY DEFAULT
        m_disabledIds = m_defaultDisabledIds;
        for(const int &id : std::as_const(m_defaultDisabledIds)) {
            m_enabledIds.remove(id);
            const QList<QStringList> tmp = m_id2data.value(id, {{},{},{}});
            const QStringList &tmp1 = tmp[1];
            for(const QString &suf : tmp1) {
                m_disabledSuffixes.insert(suf);
                m_enabledSuffixes.remove(suf);
            }
            const QStringList &tmp2 = tmp[2];
            for(const QString &mime : tmp2) {
                m_disabledMimetypes.insert(mime);
                m_enabledMimetypes.remove(mime);
            }
        }

    } else {

        QTextStream suffixIn(&suffixFile);

        while(!suffixIn.atEnd()) {
            QString line = suffixIn.readLine().trimmed();
            if(!line.isEmpty()) {
                const int id = line.toInt();
                m_disabledIds.insert(id);
                m_enabledIds.remove(id);
                const QList<QStringList> tmp = m_id2data.value(id, {{},{},{}});
                const QStringList tmp1 = tmp[1];
                for(const QString &suf : tmp1) {
                    m_disabledSuffixes.insert(suf);
                    m_enabledSuffixes.remove(suf);
                }
                const QStringList tmp2 = tmp[2];
                for(const QString &mime : tmp2) {
                    m_disabledMimetypes.insert(mime);
                    m_enabledMimetypes.remove(mime);
                }
            }
        }

        suffixFile.close();

    }

    Q_EMIT formatsUpdated();

}
