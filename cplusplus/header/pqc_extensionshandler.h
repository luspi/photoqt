/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

#ifndef PQCSCRIPTSEXTENSIONS_H
#define PQCSCRIPTSEXTENSIONS_H

#include <QObject>
#include <QMap>
#include "../../extensions/pqc_configtemplate.h"

class PQCExtensionsHandler : public QObject {

    Q_OBJECT

public:
    static PQCExtensionsHandler& get() {
        static PQCExtensionsHandler instance;
        return instance;
    }
    ~PQCExtensionsHandler();

    PQCExtensionsHandler(PQCExtensionsHandler const&)     = delete;
    void operator=(PQCExtensionsHandler const&) = delete;

    Q_INVOKABLE QStringList getExtensions();

    Q_INVOKABLE bool getAllowPopout(QString id);
    Q_INVOKABLE bool getIsModal(QString id);
    Q_INVOKABLE QString getQmlBaseName(QString id);

    Q_INVOKABLE QSize getDefaultPopoutSize(QString id);
    Q_INVOKABLE QSize getMinimumRequiredWindowSize(QString id);

    Q_INVOKABLE QList<QStringList> getSettings(QString id);
    Q_INVOKABLE QString getPopoutSettingName(QString id);
    Q_INVOKABLE QList<QStringList> getDoAtStartup(QString id);

    Q_INVOKABLE QMap<QString, QList<QStringList> > getMigrateSettings(QString id);
    Q_INVOKABLE QMap<QString, QList<QStringList> > getMigrateShortcuts(QString id);

    Q_INVOKABLE QStringList getShortcuts(QString id);
    Q_INVOKABLE QList<QStringList> getShortcutsActions(QString id);
    Q_INVOKABLE QStringList getAllShortcuts();
    Q_INVOKABLE QString getDescriptionForShortcut(QString sh);
    Q_INVOKABLE QString getExtensionForShortcut(QString sh);

private:
    PQCExtensionsHandler();

    QList<PQCExtensionConfig*> m_allextensions;

    // these are processed ones and then cached as they are needed often
    QStringList m_extensions;
    QMap<QString, QStringList> m_shortcuts;
    QStringList m_simpleListAllShortcuts;
    QMap<QString,QString> m_mapShortcutToExtension;

};

#endif
