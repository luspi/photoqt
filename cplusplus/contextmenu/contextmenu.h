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

#ifndef CONTEXTMENU_H
#define CONTEXTMENU_H

#include <QMenu>
#include <QtDebug>

class ContextMenu : public QObject {

    Q_OBJECT

public:
    ContextMenu(QObject *parent = 0);
    ~ContextMenu();

    // whether the contextmenu is visible or not
    Q_PROPERTY(bool opened READ getOpened WRITE setOpened NOTIFY openedChanged)
    bool getOpened() { return m_opened; }
    void setOpened(bool val) { m_opened = val; openedChanged(val); }

    // some user data that can be set (any string possible)
    Q_PROPERTY(QString userData READ getUserData WRITE setUserData NOTIFY userDataChanged)
    QString getUserData() { return m_userData; }
    void setUserData(QString val) { m_userData = val; emit userDataChanged(val); }

    // add items
    Q_INVOKABLE void addItem(QString text);
    Q_INVOKABLE void addSeparator();

    // get/set checked/checkable status
    Q_INVOKABLE void setCheckable(int index, bool checkable);
    Q_INVOKABLE void setChecked(int index, bool checked);
    Q_INVOKABLE bool isChecked(int index);
    Q_INVOKABLE void setFixedWidth(int w);
    Q_INVOKABLE void setFontSize(int fs);

    Q_INVOKABLE void setEnabled(int index, bool enabled);
    Q_INVOKABLE void popup(QPoint pos = QPoint(0,0));
    Q_INVOKABLE void clear();


private:
    // The menu
    QMenu *menu;

    // all the actions for further interaction
    QList<QAction*> allActions;

    // the Q_PROPERTY variables
    bool m_opened;
    int m_selectedIndex;
    QString m_userData;

private slots:
    void triggered(QAction *ac);
    void itemChecked(bool checked);

signals:
    void selectedIndexChanged(int index);
    void openedChanged(bool val);
    void userDataChanged(QString val);
    void checkedChanged(int index, bool checked);

};

#endif // CONTEXTMENU_H
