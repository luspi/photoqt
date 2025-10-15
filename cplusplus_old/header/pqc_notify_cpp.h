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
#include <QMutex>
#include <QMap>

class PQCNotifyCPP : public QObject {

    Q_OBJECT

public:
    static PQCNotifyCPP &get() {
        static PQCNotifyCPP instance;
        return instance;
    }

    PQCNotifyCPP(PQCNotifyCPP const&)     = delete;
    void operator=(PQCNotifyCPP const&) = delete;

    /******************************************************/

    // Some startup properties.
    // These might be set before PQCConstants is set up from QML.
    // Thus we cache them here so that we can initialize them properly
    // in its constructor.

    void setFilePath(QString val) { m_filepath = val; Q_EMIT filePathChanged(val); }
    void setHaveScreenshots(bool val) { m_haveScreenshots = val; Q_EMIT haveScreenshotsChanged(val); }

    QString getFilePath() { return m_filepath; }
    bool getHaveScreenshots() { return m_haveScreenshots; }

    /******************************************************/

private:
    PQCNotifyCPP(QObject *parent = 0) : QObject(parent) {
        m_filepath = "";
        m_haveScreenshots = false;
    }

    /******************************************************/

    // Some startup properties.
    // These might be set before PQCConstants is set up from QML.
    // Thus we cache them here so that we can initialize them properly
    // in its constructor.

    QString m_filepath;
    bool m_haveScreenshots;

    /******************************************************/

Q_SIGNALS:

    // reset current session to free up as much memory as possible
    // NOTE: THIS ONE IS PASSED ON FROM PQCNotifyQML
    void resetSessionData();

    /*************************************************************/
    // these cached startup property signals are picked up in PQCConstants

    void filePathChanged(QString val);
    void haveScreenshotsChanged(bool val);

    void setColorProfileFor(QString path, QString val);

    /*************************************************************/
    // these are signals from C++ to C++, no QML interaction

    void disableColorSpaceSupport();

    /*************************************************************/
    // this are picked up by PQCNotifyQML and passed on to QML

    // key/shortcuts related
    void keyPress(int key, int modifiers);
    void keyRelease(int key, int modifiers);

    void mouseWindowExit();
    void mouseWindowEnter();

    void showNotificationMessage(QString title, QString msg);

    void storeLocationToDatabase(QString path, QPointF location);

};
