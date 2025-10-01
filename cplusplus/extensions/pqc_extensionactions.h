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
#pragma once

#include <QObject>
#include <QVariant>

class PQCExtensionActions {

public:
    virtual ~PQCExtensionActions() = default;

    /////////////////////////////////////////

    // do something, but the actual image is not needed
    virtual QVariant action1(QString filepath, QVariant additional = QVariant()) = 0;
    virtual QVariant action2(QString filepath, QVariant additional = QVariant()) = 0;

    // do something and also provide me with the image
    virtual QVariant actionWithImage1(QString filepath, QImage &img, QVariant additional = QVariant()) = 0;
    virtual QVariant actionWithImage2(QString filepath, QImage &img, QVariant additional = QVariant()) = 0;


};

#define PhotoQt_IID "org.photoqt.PhotoQt"
Q_DECLARE_INTERFACE(PQCExtensionActions, PhotoQt_IID)
