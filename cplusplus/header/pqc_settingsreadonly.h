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

#ifndef PQCREADONLYSETTINGS_H
#define PQCREADONLYSETTINGS_H

#include <QObject>
#include <QtSql>
#include <QQmlPropertyMap>

/**********************************************************/
// NOTE: These is a slimmed-down interface for some settings
//       They are read-only!
/**********************************************************/

class PQCSettingsReadOnly : public QQmlPropertyMap {

    Q_OBJECT

public:
    static PQCSettingsReadOnly& get() {
        static PQCSettingsReadOnly instance;
        return instance;
    }
    ~PQCSettingsReadOnly();

    PQCSettingsReadOnly(PQCSettingsReadOnly const&) = delete;
    void operator=(PQCSettingsReadOnly const&) = delete;

private:
    PQCSettingsReadOnly(QObject *parent = nullptr);

    bool imageviewFitInWindow;
    int imageviewCache;
    bool imageviewColorSpaceEnable;
    bool imageviewColorSpaceLoadEmbedded;
    QString imageviewColorSpaceDefault;
    QString imageviewAdvancedSortCriteria;
    bool imageviewAdvancedSortAscending;
    QString imageviewAdvancedSortQuality;
    QStringList imageviewAdvancedSortDateCriteria;

    bool filedialogDevicesShowTmpfs;

    QString interfaceAccentColor;
    int interfaceFontNormalWeight;
    int interfaceFontBoldWeight;
    bool interfacePopoutWhenWindowIsSmall;

    QString thumbnailsExcludeDropBox;
    QString thumbnailsExcludeNextcloud;
    QString thumbnailsExcludeOwnCloud;
    QStringList thumbnailsExcludeFolders;
    bool thumbnailsExcludeNetworkShares;
    bool thumbnailsCacheBaseDirDefault;
    QString thumbnailsCacheBaseDirLocation;

};

#endif
