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

#include <QObject>
#include <QString>
#include <QSet>
#include <QMutex>
#include <imageplugins/pqc_imageplugin.h>

/**********************************************
 *
 * THE API IS DESIGNED TO BE USED THIS WAY:
 *
 * All supported formats are identified by their description
 * Each format is associated with a bunch of plugins, suffixes and mimetypes
 * To Access the data, use these methods
 *
 * getEnabledFormats() / getDisabledFormats()
 *      -> get the list of enabled and disabled formats
 *
 * getEnabledSuffixes() / getDisabledSuffixes()
 *      -> get the list of enabled and disabled suffixes
 * getEnabledMimetypes() / getDisabledMimetypes()
 *      -> get the list of enabled and disabled mimetypes
 *
 * getWritableFormats() / getWritableSuffixes()
 *      -> get the list of formats/suffixes that can be written
 *
 **********************************************/

class PQCImageHandler : public QObject {

    Q_OBJECT

public:
    static PQCImageHandler& get() {
        static PQCImageHandler instance;
        return instance;
    }

    PQCImageHandler(PQCImageHandler const&) = delete;
    void operator=(PQCImageHandler const&) = delete;

    QSize getSize(QString path);
    QImage getImage(QString path, QSize requestedSize, QSize &origSize, QString &error);
    QImage getImageWithPlugin(QString plugin, QString path, QSize requestedSize, QSize &origSize, QString &error);

    bool canWrite(QString path);
    bool writeImage(QImage img, QString targetPath);

    int getNumFormatsEnabled() { return m_numEnabled; }

    QSet<QString> getEnabledFormats(QString category = "all");
    QSet<QString> getDisabledFormats(QString category = "all");

    QSet<QString> getEnabledSuffixes(QString category = "all");
    QSet<QString> getEnabledMimetypes(QString category = "all");
    QSet<QString> getEnabledSuffixes(QStringList categories);
    QSet<QString> getEnabledMimetypes(QStringList categories);
    QSet<QString> getDisabledSuffixes(QString category = "all");
    QSet<QString> getDisabledMimetypes(QString category = "all");

    QSet<QString> getWritableFormats(QString category = "all");
    QSet<QString> getWritableSuffixes(QString category = "all");
    QSet<QString> getWritableFormats(QStringList categories);
    QSet<QString> getWritableSuffixes(QStringList categories);

    QString getFormatName(QString suffix);

    QStringList getPluginNames();

    QSet<QString> getPluginsForFormat(QString format);
    QSet<QString> getAllSuffixesForFormat(QString format);
    QString getCategoryForFormat(QString format);

    bool isEnabled(QString plugin, QString description);
    void setEnabled(QString pluginName, QString description, bool enabled);

    const QSet<QString> getDoNotThreadFormats() { return m_doNotThreadFormats; };

    QMutex providerMutex;

private:
    PQCImageHandler();

    QStringList m_pluginOrder;
    QStringList m_pluginOrderForSettings;
    QHash<QString, PQCImagePlugin*> m_plugins;

    int m_numEnabled;

    QSet<QString> m_enabledFormats;
    QSet<QString> m_enabledSuffixes;
    QSet<QString> m_enabledMimetypes;

    QSet<QString> m_disabledFormats;
    QSet<QString> m_disabledSuffixes;
    QSet<QString> m_disabledMimetypes;

    QSet<QString> m_writableFormats;
    QSet<QString> m_writableSuffixes;

    QSet<QString> m_doNotThreadFormats;

Q_SIGNALS:
    void formatsUpdated();

};
