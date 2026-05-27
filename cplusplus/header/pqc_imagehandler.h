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
#include <pqc_imageplugin.h>

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
    QSet<QString> getSuffixes(QString category = "all");
    QSet<QString> getMimetypes(QString category = "all");
    QSet<QString> getSuffixes(QStringList categories);
    QSet<QString> getMimetypes(QStringList categories);
    QSet<QString> getWritableSuffixes(QString category = "all");
    QSet<QString> getWritableSuffixes(QStringList categories);
    QString getDescription(QString suffix);

    QStringList getPluginNames();
    QStringList getAllDescriptions();
    QStringList getPluginsForFormatByDescription(QString description);
    QStringList getAllSuffixesForFormatByDescription(QString description);
    QString getCategoryForFormatByDescription(QString description);

    bool isEnabled(QString plugin, QString description);
    void setEnabled(QString pluginName, QString description, bool enabled);

    const QSet<QString> getDoNotThreadFormats() { return m_doNotThreadFormats; };

    QMutex providerMutex;

private:
    PQCImageHandler();

    QStringList pluginOrder;
    QHash<QString, PQCImagePlugin*> plugins;

    int m_numEnabled;
    QSet<QString> m_suffixes;
    QSet<QString> m_mimetypes;
    QSet<QString> m_writableSuffixes;

    bool m_composedWritableSuffixes;

    QSet<QString> m_doNotThreadFormats;

Q_SIGNALS:
    void formatsUpdated();

};
