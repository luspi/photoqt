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

#ifndef PQCCONSTANTS_H
#define PQCCONSTANTS_H

#include <QObject>
#include <QStandardPaths>
#include <QDir>

class PQCConstants : public QObject {

    Q_OBJECT

public:
    static PQCConstants& get() {
        static PQCConstants instance;
        return instance;
    }
    ~PQCConstants() {}

    PQCConstants(PQCConstants const&)     = delete;
    void operator=(PQCConstants const&) = delete;

    Q_PROPERTY(int windowWidth MEMBER m_windowWidth NOTIFY windowWidthChange)
    Q_PROPERTY(int windowHeight MEMBER m_windowHeight NOTIFY windowHeightChange)

    Q_PROPERTY(int howManyFiles MEMBER m_howManyFiles NOTIFY howManyFilesChanged)

private:
    PQCConstants() : QObject() {
        m_windowWidth = 0;
        m_windowHeight = 0;
        m_howManyFiles = 0;
    }

    int m_windowWidth;
    int m_windowHeight;

    int m_howManyFiles;

Q_SIGNALS:
    void windowWidthChange();
    void windowHeightChange();
    void howManyFilesChanged();

};

#endif
