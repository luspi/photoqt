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

#ifndef TABIMAGEPOSITIONTILE_H
#define TABIMAGEPOSITIONTILE_H

#include <QLabel>

class PQCPrintTabImagePositionTile : public QLabel {

    Q_OBJECT

public:
    PQCPrintTabImagePositionTile(int id, bool selected);

    void setHovered();
    void setNotHovered();
    void setSelected();

    QString getBorder();

public Q_SLOTS:
    void checkIfIAmStillSelected(int newid);

private:
    int id;
    bool selected;

protected:
    void enterEvent(QEvent *) {
        setHovered();
    }
    void leaveEvent(QEvent *) {
        setNotHovered();
    }
    void mousePressEvent(QMouseEvent *) {
        setSelected();
    }

Q_SIGNALS:
    void newPosSelected(int id);

};

#endif // TABIMAGEPOSITIONTILE_H
