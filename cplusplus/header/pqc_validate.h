/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

#ifndef PQCVALIDATE_H
#define PQCVALIDATE_H

#include <QObject>

class PQCValidate : public QObject {

    Q_OBJECT

public:
    PQCValidate(QObject *parent = nullptr);

    bool validate();

    bool validateContextMenuDatabase();
    bool validateImageFormatsDatabase();
    bool validateSettingsDatabase();
    bool validateShortcutsDatabase();
    bool validateSettingsValues();
    bool validateDirectories(QString thumb_cache_basedir);
    bool validateLocationDatabase();
    bool validateImgurHistoryDatabase();

};

#endif // PQVALIDATE_H
