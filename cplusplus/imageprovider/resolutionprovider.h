/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

#ifndef RESOLUTIONPROVIDER_H
#define RESOLUTIONPROVIDER_H

#include <QObject>
#include <QMap>
#include <QSize>
#include <QCryptographicHash>

class PQResolutionProvider : public QObject {

    Q_OBJECT

public:
    static PQResolutionProvider& get() {
        static PQResolutionProvider instance;
        return instance;
    }

    PQResolutionProvider(PQResolutionProvider const&)     = delete;
    void operator=(PQResolutionProvider const&) = delete;

    void saveResolution(QString filename, QSize res);
    QSize getResolution(QString filename);

private:
    PQResolutionProvider();

    QString getKey(QString filename);

    QMap<QString,QSize> resolution;

};

#endif // RESOLUTIONPROVIDER_H
