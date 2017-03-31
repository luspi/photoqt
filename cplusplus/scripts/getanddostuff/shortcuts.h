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

#ifndef GETANDDOSTUFFSHORTCUTS_H
#define GETANDDOSTUFFSHORTCUTS_H

#include <iostream>
#include <thread>
#include <QObject>
#include <QVariantMap>
#include <QFile>
#include <QDir>
#include <QTextStream>
#include <QTime>
#include <QFileSystemWatcher>
#include <QTimer>
#include "../../logger.h"
#include <QtDebug>
#include <QTouchDevice>
#include <QKeySequence>

class GetAndDoStuffShortcuts : public QObject {

    Q_OBJECT

public:
    explicit GetAndDoStuffShortcuts(bool usedAtStartup = false, QObject *parent = 0);
    ~GetAndDoStuffShortcuts();

    QVariantMap getKeyShortcuts();
    QVariantMap getMouseShortcuts();
    QVariantMap getTouchShortcuts();
    QVariantMap getAllShortcuts();
    void saveShortcuts(QVariantMap l);
    QVariantMap getDefaultKeyShortcuts();
    QVariantMap getDefaultMouseShortcuts();
    QVariantMap getDefaultTouchShortcuts();
    QString getKeyShortcutFile();
    QString filterOutShortcutCommand(QString combo, QString file);
    bool isTouchScreenAvailable();
    QString convertQKeyToQString(int keycode);

private:
    QFileSystemWatcher *watcher;

private slots:
    void fileChanged(QString filename);
    void setFilesToWatcher();

signals:
    void keyShortcutFileChanged(int);
    void mouseShortcutFileChanged(int);

};

#endif // GETANDDOSTUFFSHORTCUTS_H
