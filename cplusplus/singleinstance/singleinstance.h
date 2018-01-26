/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef SINGLEINSTANCE_H
#define SINGLEINSTANCE_H

#include "../logger.h"
#include <thread>
#include <QApplication>
#include <QLocalSocket>
#include <QLocalServer>
#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QDate>
#include "commandlineparser.h"

// Makes sure only one instance of PhotoQt is running, and enables remote communication
class SingleInstance : public QApplication {
    Q_OBJECT
public:
    explicit SingleInstance(int&, char *[]);
    ~SingleInstance();

    bool open;
    bool nothumbs;
    bool thumbs;
    bool toggle;
    bool show;
    bool hide;
    bool startintray;
    QString filename;

    // dont start photoqt but quit now (e.g., after exporting config)
    QString exportAndQuitNow;
    QString importAndQuitNow;

signals:
    // Interact with application
    void interaction(QString exec);

private slots:
    // A new application instance was started (notification to main instance)
    void newConnection();

private:
    QLocalSocket *socket;
    QLocalServer *server;

    // This one is used in main process, handling the message sent by sub-instances
    void handleResponse(QString msg);

};

#endif // SINGLEINSTANCE_H
