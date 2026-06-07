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

class QTimer;

// Every image plugin has to inherit this class and implement all its methods

class PQCImagePlugin : public QObject {

    Q_OBJECT

public:
    explicit PQCImagePlugin(QObject *parent = nullptr);
    ~PQCImagePlugin();

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
    void setData(const QHash<QString, QList<QStringList> > dat, const QString settingsPrefix,
                 QSet<QString> defaultDisabledSuffixes = {}, QSet<QString> defaultDisabledMimetypes = {}) {};
    void setData(const QHash<int, QList<QStringList> > dat, const QString settingsPrefix,
                 QSet<int> defaultDisabledFormats = {});

    /****************************************************/
    /****************************************************/

    const QSet<int> getEnabledFormats()    { return m_enabledIds; }
    const QSet<int> getDisabledFormats()   { return m_disabledIds; }
    const QSet<QString> getEnabledSuffixes()   { return m_enabledSuffixes; }
    const QSet<QString> getDisabledSuffixes()  { return m_disabledSuffixes; }
    const QSet<QString> getEnabledMimetypes()  { return m_enabledMimetypes; }
    const QSet<QString> getDisabledMimetypes() { return m_disabledMimetypes; }

    /****************************************************/
    /****************************************************/

    void setWritableFormats(const QSet<int> formats);
    QSet<int> getWritableFormats() { return m_writableIds; }


    /****************************************************/
    /****************************************************/

    // the format for a suffix
    const int getFormat(QString suffix) { return m_suffix2id.value(suffix, -1); }
    const int getFormatFromDescription(QString desc) { return m_desc2id.value(desc, -1); }
    const QString getDescription(int id) { return m_id2data.value(id, {{""}})[0][0]; }
    const QList<int> getAllFormats() { return m_id2data.keys(); }

    /****************************************************/
    /****************************************************/
    // the suffixes/mimetypes for a format

    const QHash<QString,int> getSuffix2IdMapping() {
        return m_suffix2id;
    }

    const QHash<QString,int> getDescription2IdMapping() {
        return m_desc2id;
    }

    const QHash<QString,int> getMimetypes2IdMapping() {
        return m_mime2id;
    }

    const QStringList getSuffixesForFormat(const int id) {
        if(m_id2data.contains(id))
            return m_id2data[id][1];
        return {};
    }

    const QStringList getMimetypesForFormat(const int id) {
        if(m_id2data.contains(id))
            return m_id2data[id][2];
        return {};
    }

    /****************************************************/
    /****************************************************/

    // whether this plugin supports the format based on its format
    const bool supportsFormat(const int id) {
        return m_id2data.contains(id);
    }

    /****************************************************/
    /****************************************************/

    // whether this format is supported and enabled based on its format
    const bool isEnabled(const int id) {
        if(!m_id2data.contains(id))
            return false;
        return m_enabledIds.contains(id);
    }

    /****************************************************/
    /****************************************************/

    // toggle the enabled status of the specified formats
    void setEnabled(int format, bool enabled);

    /****************************************************/
    /****************************************************/

    void loadSetttingsFromFiles();

    /****************************************************/
    /****************************************************/

private:
    QHash<int, QList<QStringList> > m_id2data;
    QHash<QString,int> m_suffix2id;
    QHash<QString,int> m_mime2id;
    QHash<QString,int> m_desc2id;
    QSet<int> m_defaultDisabledIds;

    QSet<int> m_enabledIds;
    QSet<int> m_disabledIds;

    QSet<QString> m_enabledSuffixes;
    QSet<QString> m_disabledSuffixes;

    QSet<QString> m_enabledMimetypes;
    QSet<QString> m_disabledMimetypes;

    QSet<int> m_writableIds;
    QSet<QString> m_writableSuffixes;

    QString m_settingsPrefix;

    QTimer *m_delayWriteToFile;

Q_SIGNALS:
    void formatsUpdated();

};
