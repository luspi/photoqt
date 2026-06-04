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
    void setData(const QHash<QString, QList<QSet<QString> > > dat, const QString settingsPrefix,
                 QSet<QString> defaultDisabledSuffixes = {}, QSet<QString> defaultDisabledMimetypes = {});

    /****************************************************/
    /****************************************************/

    const QSet<QString> getEnabledFormats()    { return m_enabledFormats; }
    const QSet<QString> getDisabledFormats()   { return m_disabledFormats; }
    const QSet<QString> getEnabledSuffixes()   { return m_enabledSuffixes; }
    const QSet<QString> getDisabledSuffixes()  { return m_disabledSuffixes; }
    const QSet<QString> getEnabledMimetypes()  { return m_enabledMimetypes; }
    const QSet<QString> getDisabledMimetypes() { return m_disabledMimetypes; }

    void setEnabledFormats(const QSet<QString> val)    { m_enabledFormats = val; }
    void setDisabledFormats(const QSet<QString> val)   { m_disabledFormats = val; }
    void setEnabledSuffixes(const QSet<QString> val)   { m_enabledSuffixes = val; }
    void setDisabledSuffixes(const QSet<QString> val)  { m_disabledSuffixes = val; }
    void setEnabledMimetypes(const QSet<QString> val)  { m_enabledMimetypes = val; }
    void setDisabledMimetypes(const QSet<QString> val) { m_disabledMimetypes = val; }

    void insertIntoEnabledFormats(const QString format)  { m_enabledFormats.insert(format); };
    void insertIntoDisabledFormats(const QString format) { m_disabledFormats.insert(format); };
    void insertIntoEnabledSuffixes(const QString suf)    { m_enabledSuffixes.insert(suf); };
    void insertIntoDisabledSuffixes(const QString suf)   { m_disabledSuffixes.insert(suf); };
    void insertIntoEnabledMimetypes(const QString mime)  { m_enabledMimetypes.insert(mime); };
    void insertIntoDisabledMimetypes(const QString mime) { m_disabledMimetypes.insert(mime); };

    void clearEnabledFormats()    { m_enabledFormats.clear(); }
    void clearDisabledFormats()   { m_disabledFormats.clear(); }
    void clearEnabledSuffixes()   { m_enabledSuffixes.clear(); }
    void clearDisabledSuffixes()  { m_disabledSuffixes.clear(); }
    void clearEnabledMimetypes()  { m_enabledMimetypes.clear(); }
    void clearDisabledMimetypes() { m_disabledMimetypes.clear(); }

    /****************************************************/
    /****************************************************/

    void setWritableFormats(const QSet<QString> formats);
    QSet<QString> getWritableFormats() { return m_writableFormats; }
    QSet<QString> getWritableSuffixes() { return m_writableSuffixes; }


    /****************************************************/
    /****************************************************/

    // the format for a suffix
    const QString getFormat(QString suffix) { return m_suffix2format.value(suffix, ""); }
    const QStringList getAllFormats() { return m_format2data.keys(); }

    /****************************************************/
    /****************************************************/
    // the suffixes for a format

    const QSet<QString> getSuffixesForFormat(QString format) {
        if(m_format2data.contains(format))
            return m_format2data[format][0];
        return {};
    }

    /****************************************************/
    /****************************************************/

    // whether this plugin supports the format based on its format
    const bool supportsFormat(QString format) {
        return m_format2data.contains(format);
    }

    /****************************************************/
    /****************************************************/

    // whether this format is supported and enabled based on its format
    const bool isEnabled(QString format) {
        if(!m_format2data.contains(format))
            return false;
        return m_enabledSuffixes.contains(*m_format2data[format][0].begin());
    }

    /****************************************************/
    /****************************************************/

    // toggle the enabled status of the specified formats
    void setEnabled(QString format, bool enabled);

    /****************************************************/
    /****************************************************/

    void loadSetttingsFromFiles();

    /****************************************************/
    /****************************************************/

private:
    QHash<QString, QList<QSet<QString>> > m_format2data;
    QHash<QString,QString> m_suffix2format;

    QSet<QString> m_enabledFormats;
    QSet<QString> m_disabledFormats;

    QSet<QString> m_enabledSuffixes;
    QSet<QString> m_disabledSuffixes;

    QSet<QString> m_enabledMimetypes;
    QSet<QString> m_disabledMimetypes;

    QSet<QString> m_defaultDisabledSuffixes;
    QSet<QString> m_defaultDisabledMimetypes;

    QSet<QString> m_writableFormats;
    QSet<QString> m_writableSuffixes;

    QString m_settingsPrefix;

    QTimer *m_delayWriteToFile;

Q_SIGNALS:
    void formatsUpdated();

};
