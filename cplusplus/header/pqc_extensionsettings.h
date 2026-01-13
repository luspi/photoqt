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

#include <QSettings>
#include <QQmlEngine>
#include <QQmlPropertyMap>

class QFileSystemWatcher;

class ExtensionSettings : public QQmlPropertyMap {

    Q_OBJECT
    QML_ELEMENT

public:
    ExtensionSettings(QObject *parent = nullptr);
    ExtensionSettings(QString extensionId, QObject *parent = nullptr);
    ~ExtensionSettings();

    Q_PROPERTY(QString extensionId MEMBER m_extensionId NOTIFY extensionIdChanged)
    Q_INVOKABLE QVariant getDefaultFor(const QString &key);

    Q_PROPERTY(int status MEMBER m_status NOTIFY statusChanged)
    Q_PROPERTY(int Ready READ getReady CONSTANT)
    Q_PROPERTY(int Loading READ getLoading CONSTANT)
    const int getReady() { return 1; }
    const int getLoading() { return 0; }

    QMap<QString, QVariant> defaultValues;

    void saveShortcut(const QString &sh);

private:
    QString m_extensionId;

    QSettings *set;
    QString m_setPath;
    int m_status;
    int m_Ready;
    int m_Loading;

    QFileSystemWatcher *watcher;
    void readFile();

private Q_SLOTS:
    void setup();
    void saveExtensionValue(const QString &key, const QVariant &value);

Q_SIGNALS:
    void extensionIdChanged();
    void statusChanged();

};
