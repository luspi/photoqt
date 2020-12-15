/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

#ifndef PQSYSTEMTRAYICON_H
#define PQSYSTEMTRAYICON_H

#include <QObject>
#include <QSystemTrayIcon>
#include <QMenu>
#include "../variables.h"
#include "../settings/settings.h"

class PQSystemTrayIcon : public QObject {

    Q_OBJECT

public:
    explicit PQSystemTrayIcon(QObject *parent = nullptr) : QObject(parent) {
        tray = new QSystemTrayIcon;
        tray->setIcon(QIcon(":/other/icon.png"));

        m_visible = true;

        menu = new QMenu;
        acToggle = new QAction("Hide/Show PhotoQt");
        connect(acToggle, &QAction::triggered, this, &PQSystemTrayIcon::toggleAction);
        menu->addAction(acToggle);
        acQuit = new QAction("Quit PhotoQt");
        connect(acQuit, &QAction::triggered, this, &PQSystemTrayIcon::quitAction);
        menu->addAction(acQuit);
        tray->setContextMenu(menu);

        connect(tray, &QSystemTrayIcon::activated, this, &PQSystemTrayIcon::toggleAction);

    }

    ~PQSystemTrayIcon() {
        delete tray;
        delete menu;
        delete acToggle;
        delete acQuit;
    }

    Q_PROPERTY(bool visible READ getVisible WRITE setVisible NOTIFY visibleChanged)
    bool getVisible() { return m_visible; }
    void setVisible(bool val) {
        if(val != m_visible) {
            m_visible = val;
            tray->setVisible(val);
            emit visibleChanged();
        }
    }

    Q_PROPERTY(int trayIconSetting READ getTrayIconSetting WRITE setTrayIconSetting)
    int getTrayIconSetting() { return acToggle->isVisible(); }
    void setTrayIconSetting(int val) {
        acToggle->setVisible(val==1);
    }

private:
    QSystemTrayIcon *tray;
    QMenu *menu;
    QAction *acToggle;
    QAction *acQuit;

    bool m_visible;
//    bool m_trayIconSetting;

signals:
    void visibleChanged();
    void toggleAction();
    void quitAction();

};

#endif // PQSYSTEMTRAYICON_H
