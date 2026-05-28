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
#pragma once

#include <pqc_configfiles.h>
#include <pqc_helper.h>
#include <QObject>
#include <QSet>

// Every image plugin has to inherit this class and implement all its methods

class PQCImagePlugin : public QObject {

    Q_OBJECT

public:
    virtual ~PQCImagePlugin() = default;

    // the printable name of this plugin
    virtual const QString name() = 0;

    // which category this falls under
    virtual const QString category() = 0;
    \
    // is this plugin suitable for preloading?
    virtual const bool canPreload() = 0;

    // LOAD the size (resolution) of the image at the specified path
    virtual const QSize loadSize(QString path) = 0;

    // LOAD the image from the specified path at its requested Size
    // > origSize is set to the original size of the image (before scaling)
    // > error holding any potential error message
    virtual const QImage loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) = 0;

    // write the image to the target path
    virtual const bool writeImage(QImage img, QString targetPath) = 0;

    /****************************************************/
    /****************************************************/

    // sets the data for this plugin
    // if there are any writable suffixes they need to be set separately with the appropriate member function
    void setData(const QHash<QString, QList<QSet<QString> > > dat,
                 QSet<QString> allSuffixes, QSet<QString> allMimetypes,
                 QSet<QString> defaultDisabledSuffixes, QSet<QString> defaultDisabledMimetypes,
                 const QString settingsPrefix) {

        m_settingsPrefix = settingsPrefix;
        m_description2data = dat;
        m_allSuffixes = allSuffixes;
        m_allMimetypes = allMimetypes;
        m_defaultDisabledSuffixes = defaultDisabledSuffixes;
        m_defaultDisabledMimetypes = defaultDisabledMimetypes;

        loadData();

    }

    /****************************************************/
    /****************************************************/

    // get the formats and mime types that are supported for READING
    const QSet<QString> getSuffixes() { return m_suffixes; }
    const QSet<QString> getMimetypes() { return m_mimetypes; }
    const QSet<QString> getToggledSuffixes()  { return m_toggledSuffixes; }
    const QSet<QString> getToggledMimetypes() { return m_toggledMimetypes; }
    const QSet<QString> getAllSuffixes()  { return m_allSuffixes; }
    const QSet<QString> getAllMimetypes() { return m_allMimetypes; }
    void setSuffixes(const QSet<QString> val) { m_suffixes = val; }
    void setMimetypes(const QSet<QString> val) { m_mimetypes = val; }
    void setToggledSuffixes(const QSet<QString> val) { m_toggledSuffixes = val; }
    void setToggledMimetypes(const QSet<QString> val) { m_toggledMimetypes = val; }
    void setAllSuffixes(const QSet<QString> val) { m_allSuffixes = val; }
    void setAllMimetypes(const QSet<QString> val) { m_allMimetypes = val; }
    void insertIntoSuffixes(const QString suf) { m_suffixes.insert(suf); };
    void insertIntoMimetypes(const QString suf) { m_mimetypes.insert(suf); };
    void insertIntoToggledSuffixes(const QString suf) { m_toggledSuffixes.insert(suf); };
    void insertIntoToggledMimetypes(const QString suf) { m_toggledMimetypes.insert(suf); };
    void insertIntoAllSuffixes(const QString suf) { m_allSuffixes.insert(suf); };
    void insertIntoAllMimetypes(const QString suf) { m_allMimetypes.insert(suf); };
    void clearSuffixes() { m_suffixes.clear(); }
    void clearMimetypes() { m_mimetypes.clear(); }
    void clearToggledSuffixes() { m_toggledSuffixes.clear(); }
    void clearToggledMimetypes() { m_toggledMimetypes.clear(); }
    void clearAllSuffixes() { m_allSuffixes.clear(); }
    void clearAllMimetypes() { m_allMimetypes.clear(); }

    /****************************************************/
    /****************************************************/

    void setWritableSuffixes(QSet<QString> val) { m_writableSuffixes = val; }
    // all formats that can be written
    QSet<QString> getWritableSuffixes() { return m_writableSuffixes; }


    /****************************************************/
    /****************************************************/

    // the description for a suffix
    const QString getDescription(QString suffix) {
        const QString _s = suffix.toLower();
        for(const auto &[key, value] : std::as_const(m_description2data).asKeyValueRange()) {
            for(const QString &s : value[0]) {
                if(s == _s) return key;
            }
        }
        return "";
    }
    const QStringList getAllDescriptions() {
        return m_description2data.keys();
    }

    /****************************************************/
    /****************************************************/
    // the suffixes for a description

    const QSet<QString> getSuffixesForFormatByDescription(QString description) {
        if(m_description2data.contains(description))
            return m_description2data[description][0];
        return {};
    }

    /****************************************************/
    /****************************************************/

    // whether this plugin supports the format based on its description
    const bool supportsFormatByDescription(QString description) {
        return m_description2data.contains(description);
    }

    /****************************************************/
    /****************************************************/

    // whether this format is supported and enabled based on its description
    const bool isEnabled(QString description) {
        if(!m_description2data.contains(description)) return false;
        return m_suffixes.contains(*m_description2data[description][0].begin());
    }

    /****************************************************/
    /****************************************************/

    // toggle the enabled status of the specified formats
    void setEnabled(QString description, bool enabled) {

        QHash<QString, QList<QSet<QString> > >::Iterator iter = m_description2data.find(description);
        if(iter == m_description2data.end())
            return;

        const QList<QSet<QString> > cur = iter.value();

        // then find the ones stored as toggled
        QSet<QString> storedSuffixes, storedMimetypes;

        const QString suffixFilename = PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins/" % m_settingsPrefix % "_suffixes";
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

        const QString mimeFilename = PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins/" % m_settingsPrefix % "_mimetypes";
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
        if(!enabled) {

            storedSuffixes += cur[0];
            storedMimetypes += cur[1];

        // otherwise we need to make sure that no suffix is part of the list
        } else {

            QSet<QString> newsetSuffixes, newsetMime;

            for(const QString &s : std::as_const(storedSuffixes)) {
                if(!cur[0].contains(s))
                    newsetSuffixes.insert(s);
            }
            for(const QString &m : std::as_const(storedMimetypes)) {
                if(!cur[1].contains(m))
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

    /****************************************************/
    /****************************************************/

    void loadData() {

        /********************************/

        // first we read the toggled suffixes from the settings file
        const QString suffixFilename = PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins/" % m_settingsPrefix % "_suffixes";
        QFile suffixFile(suffixFilename);
        if(!suffixFile.open(QIODevice::ReadOnly|QIODevice::Text)) {

            qDebug() << "Failed to open settings file at:" << suffixFilename;

            // these are the ones DISABLED BY DEFAULT
            m_toggledSuffixes = m_defaultDisabledSuffixes;

        } else {

            QTextStream suffixIn(&suffixFile);
            const QStringList tmp = suffixIn.readAll().split("\n", Qt::SkipEmptyParts);
            m_toggledSuffixes = QSet<QString>(tmp.begin(), tmp.end());
            suffixFile.close();

        }

        // these are the currently enabled ones
        m_suffixes = m_allSuffixes - m_toggledSuffixes;

        /********************************/

        const QString mimeFilename = PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins/" % m_settingsPrefix % "_mimetypes";
        QFile mimeFile(mimeFilename);
        if(!mimeFile.open(QIODevice::ReadOnly|QIODevice::Text)) {

            qDebug() << "Failed to open settings file at:" << mimeFilename;

            // these are the ones DISABLED BY DEFAULT
            m_toggledMimetypes = m_defaultDisabledMimetypes;

        } else {
            QTextStream mimeIn(&mimeFile);
            const QStringList tmp = mimeIn.readAll().split("\n", Qt::SkipEmptyParts);
            m_toggledMimetypes = QSet<QString>(tmp.begin(), tmp.end());
            mimeFile.close();
        }

        // these are the currently enabled ones
        m_mimetypes = m_allMimetypes - m_toggledMimetypes;

        Q_EMIT formatsUpdated();

    }

    /****************************************************/
    /****************************************************/

private:
    QHash<QString, QList<QSet<QString>> > m_description2data;

    QSet<QString> m_suffixes;
    QSet<QString> m_mimetypes;
    QSet<QString> m_toggledSuffixes;
    QSet<QString> m_toggledMimetypes;
    QSet<QString> m_allSuffixes;
    QSet<QString> m_allMimetypes;

    QSet<QString> m_defaultDisabledSuffixes;
    QSet<QString> m_defaultDisabledMimetypes;

    QSet<QString> m_writableSuffixes;

    QString m_settingsPrefix;

Q_SIGNALS:
    void formatsUpdated();

};
