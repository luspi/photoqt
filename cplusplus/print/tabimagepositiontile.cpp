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

#include "tabimagepositiontile.h"

PQTabImagePositionTile::PQTabImagePositionTile(int id, bool selected) : QLabel() {
    this->setFixedSize(40,40);
    this->id = id;
    this->selected = selected;
    if(selected)
        setSelected();
    else
        setNotHovered();
}

void PQTabImagePositionTile::setHovered() {
    if(!selected)
        this->setStyleSheet(getBorder()+";background: rgba(175,175,175,0.5);");
}

void PQTabImagePositionTile::setNotHovered() {
    if(!selected)
        this->setStyleSheet(getBorder()+";background: white;");
}

void PQTabImagePositionTile::setSelected() {
    this->setStyleSheet(getBorder()+";background: rgb(125,125,125);");
    selected = true;
    newPosSelected(id);
}

QString PQTabImagePositionTile::getBorder() {
    QString ret = "border: 1px solid rgb(200,200,200)";
    if(id <= 2)
        ret += ";border-top: 1px solid black";
    if(id > 5)
        ret += ";border-bottom: 1px solid black";
    if((id+1)%3 == 0)
        ret += ";border-right: 1px solid black";
    if(id%3 == 0)
        ret += ";border-left: 1px solid black";
    return ret;
}

void PQTabImagePositionTile::checkIfIAmStillSelected(int newid) {
    if(newid != id) {
        selected = false;
        setNotHovered();
    }
}
