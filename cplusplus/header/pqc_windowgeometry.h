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

#ifndef PQCPOPUPGEOMETRY_H
#define PQCPOPUPGEOMETRY_H

#include <QQmlPropertyMap>
#include <QRect>
#include <QtQmlIntegration>

class QSettings;
class QTimer;

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton CANNOT be used from C++.
//            It can ONLY be used from QML.
//
/*************************************************************/
/*************************************************************/

class PQCWindowGeometry : public QQmlPropertyMap {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCWindowGeometry();
    ~PQCWindowGeometry();

    QSettings *settings;
    void load();

private Q_SLOTS:
    void save();
    void computeSmallSizeBehavior();

private:

    QTimer *saveDelay;

    QVariantList allElements;

};

#endif
