/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

#include "contextmenu.h"

ContextMenu::ContextMenu(QObject *parent) : QObject(parent) {

    // this is the menu that will popup
    menu = new QMenu;

    // The styling of the menu
    QString css = // the frame
                  "QMenu {"
                      "background-color: #0f0f0f;"
                      "border: 1px solid #99969696;"
                  "}"
                  // the individual items, not hovered
                  "QMenu::item {"
                      "background-color: transparent;"
                      "color: #ffffff;"
                  "}"
                  // the individual items, not hovered, disabled
                  "QMenu::item:disabled {"
                      "background-color: transparent;"
                      "color: #aa808080;"
                  "}"
                  "QMenu::separator {"
                        "background-color: white;"
                        "height: 1px;"
                        "margin: 5px 0px 5px 0px;"
                  "}"
                  // the individual items, hovered
                  "QMenu::item:selected {"
                      "background-color: #4f4f4f;"
                  "}"
                  // the indicator, unchecked
                  "QMenu::indicator {"
                      "image: url(:/img/contextmenu/unchecked.png);"
                  "}"
                  // the indicator, unchecked, disabled
                  "QMenu::indicator:disabled {"
                      "image: url(:/img/contextmenu/unchecked_disabled.png);"
                  "}"
                  // the indicator, checked
                  "QMenu::indicator:checked {"
                      "image: url(:/img/contextmenu/checked.png);"
                  "}"
                  // the indicator, checked, disabled
                  "QMenu::indicator:checked:disabled {"
                      "image: url(:/img/contextmenu/checked_disabled.png);"
                  "}";
    menu->setStyleSheet(css);

    m_opened = false;
    m_selectedIndex = -1;
    m_userData = "";

    connect(menu, &QMenu::triggered, this, &ContextMenu::triggered);
    connect(menu, &QMenu::aboutToShow, [this](){ setOpened(true); });
    connect(menu, &QMenu::aboutToHide, [this](){ setOpened(false); });

}

// delete all actions
ContextMenu::~ContextMenu() {
    for(QAction *ac : allActions)
        delete ac;
}

// add a new item to the menu
void ContextMenu::addItem(QString text, bool bold) {
    QAction *ac = new QAction(text, 0);
    if(bold) {
        QFont font = ac->font();
        font.setBold(true);
        ac->setFont(font);
    }
    allActions.append(ac);
    menu->addAction(ac);
    connect(ac, &QAction::toggled, this, &ContextMenu::itemChecked);
}

// add a seperator line to the menu
void ContextMenu::addSeparator() {
    menu->addSeparator();
}

void ContextMenu::setFixedWidth(int w) {
    menu->setFixedWidth(w);
}

void ContextMenu::setFontSize(int fs) {
    QFont f = menu->font();
    f.setPointSize(fs);
    menu->setFont(f);
}

// popup menu. If no position is specified, it will popup under mouse cursor
void ContextMenu::popup(QPoint pos) {
    if(pos.isNull())
        pos = QCursor::pos();
    menu->popup(pos, nullptr);
}

// clear the menu contents
void ContextMenu::clear() {
    for(QAction *ac : allActions)
        delete ac;
    allActions.clear();
    menu->clear();
}

// set some checked/checkable properties
void ContextMenu::setCheckable(int index, bool checkable) {
    allActions.at(index)->setCheckable(checkable);
}
void ContextMenu::setChecked(int index, bool checked) {
    allActions.at(index)->setChecked(checked);
}
bool ContextMenu::isChecked(int index) {
    return allActions.at(index)->isChecked();
}
void ContextMenu::itemChecked(bool) {
    QAction *ac = (QAction*)sender();
    emit checkedChanged(allActions.indexOf(ac), ac->isChecked());
}

// specify whether item is visible
void ContextMenu::setEnabled(int index, bool enabled) {
    if(index < allActions.length())
        allActions.at(index)->setEnabled(enabled);
}

// slot called when user clicks on item
void ContextMenu::triggered(QAction *ac) {
    emit selectedIndexChanged(allActions.indexOf(ac));
}

int ContextMenu::height() {
    return menu->sizeHint().height();
}
