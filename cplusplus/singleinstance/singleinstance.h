/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#ifndef PQSINGLEINSTANCE_H
#define PQSINGLEINSTANCE_H

#include <QApplication>
#include <QLocalSocket>
#include <QLocalServer>
#include <thread>
#include <QQmlApplicationEngine>
#include <QVector>
#include "commandlineparser.h"
#include "../logger.h"
#include "../passon.h"
#include "../keypresschecker.h"
// DO NOT use PQSettings in this class!
// The right folders are not yet set up at this point
// This will cause unintended side effects
// including not loading the settings properly/resetting defaults

// Makes sure only one instance of PhotoQt is running, and enables remote communication
class PQSingleInstance : public QApplication {

    Q_OBJECT

public:
    explicit PQSingleInstance(int&, char *[]);
    ~PQSingleInstance();

    QString exportAndQuit;
    QString importAndQuit;
    bool checkConfig;
    bool resetConfig;
    bool showInfo;

    QQmlApplicationEngine *qmlEngine;
    QVector<void*> qmlWindowAddresses;

protected:
    virtual bool notify(QObject * receiver, QEvent * event) override;

Q_SIGNALS:
    // Interact with application
    void interaction(PQCommandLineResult result, QString value);

private Q_SLOTS:
    // A new application instance was started (notification to main instance)
    void newConnection();

private:
    QLocalSocket *socket;
    QLocalServer *server;

    // This one is used in main process, handling the message sent by sub-instances
    void handleMessage(QString msg);

};

#endif // PQSINGLEINSTANCE_H
