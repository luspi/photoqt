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

    // get the formats and mime types that are supported for READING
    const QSet<QString> getSuffixes() { return m_suffixes; }
    const QSet<QString> getMimetypes() { return m_mimetypes; }
    const QSet<QString> getToggledSuffixes()  { return m_disabledSuffixes; }
    const QSet<QString> getToggledMimetypes() { return m_disabledMimetypes; }
    const QSet<QString> getAllSuffixes()  { return m_allSuffixes; }
    const QSet<QString> getAllMimetypes() { return m_allMimetypes; }
    void setSuffixes(const QSet<QString> val) { m_suffixes = val; }
    void setMimetypes(const QSet<QString> val) { m_mimetypes = val; }
    void setToggledSuffixes(const QSet<QString> val) { m_disabledSuffixes = val; }
    void setToggledMimetypes(const QSet<QString> val) { m_disabledMimetypes = val; }
    void setAllSuffixes(const QSet<QString> val) { m_allSuffixes = val; }
    void setAllMimetypes(const QSet<QString> val) { m_allMimetypes = val; }
    void insertIntoSuffixes(const QString suf) { m_suffixes.insert(suf); };
    void insertIntoMimetypes(const QString suf) { m_mimetypes.insert(suf); };
    void insertIntoToggledSuffixes(const QString suf) { m_disabledSuffixes.insert(suf); };
    void insertIntoToggledMimetypes(const QString suf) { m_disabledMimetypes.insert(suf); };
    void insertIntoAllSuffixes(const QString suf) { m_allSuffixes.insert(suf); };
    void insertIntoAllMimetypes(const QString suf) { m_allMimetypes.insert(suf); };
    void clearSuffixes() { m_suffixes.clear(); }
    void clearMimetypes() { m_mimetypes.clear(); }
    void clearToggledSuffixes() { m_disabledSuffixes.clear(); }
    void clearToggledMimetypes() { m_disabledMimetypes.clear(); }
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
    const QString getDescription(QString suffix) { return m_suffix2description.value(suffix, ""); }
    const QStringList getAllDescriptions() { return m_description2data.keys(); }

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
        if(!m_description2data.contains(description))
            return false;
        return m_suffixes.contains(*m_description2data[description][0].begin());
    }

    /****************************************************/
    /****************************************************/

    // toggle the enabled status of the specified formats
    void setEnabled(QString description, bool enabled);

    /****************************************************/
    /****************************************************/

    void loadSetttingsFromFiles();

    /****************************************************/
    /****************************************************/

private:
    QHash<QString, QList<QSet<QString>> > m_description2data;
    QHash<QString,QString> m_suffix2description;

    QSet<QString> m_suffixes;
    QSet<QString> m_mimetypes;
    QSet<QString> m_disabledSuffixes;
    QSet<QString> m_disabledMimetypes;
    QSet<QString> m_allSuffixes;
    QSet<QString> m_allMimetypes;

    QSet<QString> m_defaultDisabledSuffixes;
    QSet<QString> m_defaultDisabledMimetypes;

    QSet<QString> m_writableSuffixes;

    QString m_settingsPrefix;

    QTimer *m_delayWriteToFile;

Q_SIGNALS:
    void formatsUpdated();

};
