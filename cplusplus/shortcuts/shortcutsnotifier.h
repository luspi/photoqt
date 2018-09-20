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

#ifndef SHORTCUTSNOTIFIER_H
#define SHORTCUTSNOTIFIER_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include "../logger.h"

class ShortcutsNotifier : public QObject {

    Q_OBJECT

public:
    explicit ShortcutsNotifier(QObject *parent = nullptr) : QObject(parent) {
        hiddenareas.clear();
        file.setFileName(ConfigFiles::SHORTCUTSNOTIFIER_FILE());
        if(file.exists()) {
            if(file.open(QIODevice::ReadOnly)){
                QTextStream in(&file);
                QString line;
                do {
                    line = in.readLine();
                    hiddenareas.append(line.trimmed());
                } while(!line.isNull());
                file.close();
            } else
                LOG << CURDATE << "ShortcutsNotifier - ERROR: Unable to retrieve initial states of shortcuts notifiers: " <<
                       file.errorString().trimmed().toStdString() << NL;
        }
    }

    Q_INVOKABLE bool isShown(QString area) {
        return !hiddenareas.contains(area);
    }
    Q_INVOKABLE void setHidden(QString area) {
        if(file.open(QIODevice::WriteOnly | QIODevice::Append)) {
            QTextStream out(&file);
            out << (area+"\n");
            file.close();
        } else
            LOG << CURDATE << "ShortcutsNotifier::setHidden() - ERROR: Unable to save state of shortcuts notifier of area '" <<
                   area.toStdString() << "': " << file.errorString().trimmed().toStdString() << NL;
        hiddenareas.append(area);
    }

private:
    QFile file;
    QStringList hiddenareas;

};


#endif // SHORTCUTSNOTIFIER_H
