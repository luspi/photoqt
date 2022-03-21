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
    if(id <= 3)
        ret += ";border-top: 1px solid black";
    if(id > 6)
        ret += ";border-bottom: 1px solid black";
    if(id%3 == 0)
        ret += ";border-right: 1px solid black";
    if((id-1)%3 == 0)
        ret += ";border-left: 1px solid black";
    return ret;
}

void PQTabImagePositionTile::checkIfIAmStillSelected(int newid) {
    if(newid != id) {
        selected = false;
        setNotHovered();
    }
}
