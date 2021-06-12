/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

#ifndef PQSTARTUP_SHORTCUTS_H
#define PQSTARTUP_SHORTCUTS_H

#include "../logger.h"
#include "../configfiles.h"

namespace PQStartup {

    namespace Shortcuts {

        static void updateShortcuts() {

            QFile shortcutsfile(ConfigFiles::SHORTCUTS_FILE());

            if(shortcutsfile.exists() && shortcutsfile.open(QIODevice::ReadWrite)) {

                QTextStream in(&shortcutsfile);
                QString txt = in.readAll();

                // rename shortcuts
                if(txt.contains("__hideMeta")) {
                    txt = txt.replace("__hideMeta", "__showMetaData");
                    QTextStream out(&shortcutsfile);
                    out << txt;
                }

                shortcutsfile.close();

            }

        }

        static void updateShortcutsFormat() {

            QFile shortcutsfile(ConfigFiles::SHORTCUTS_FILE());

            if(shortcutsfile.exists() && shortcutsfile.open(QIODevice::ReadWrite)) {

                QTextStream in(&shortcutsfile);
                QString txt = in.readAll();

                // version updated, reformat
                if(!txt.contains(QString("Version=%1\n").arg(VERSION))) {

                    QMap<QString, QStringList> newShortcuts;

                    const QStringList parts = txt.split("\n");
                    for(const QString &p : parts) {

                        if(!p.contains("::"))
                            continue;

                        const QStringList entries = p.split("::");
                        if(entries.count() > 3 || entries.at(1) == "__")
                            return;

                        const QString cmd = QString("%1::%2").arg(entries.at(0), entries.at(2));
                        const QString sh = entries.at(1);

                        if(newShortcuts.contains(cmd))
                            newShortcuts[cmd].append(sh);
                        else
                            newShortcuts.insert(cmd, QStringList() << sh);

                    }

                    QString newtxt = QString("Version=%1\n").arg(VERSION);

                    QMap<QString, QStringList>::const_iterator iter = newShortcuts.constBegin();
                    while(iter != newShortcuts.constEnd()) {

                        newtxt += QString("%1").arg(iter.key());
                        for(const QString &entry : qAsConst(iter.value()))
                            newtxt += QString("::%1").arg(entry);
                        newtxt += "\n";

                        ++iter;
                    }

                    shortcutsfile.close();
                    shortcutsfile.open(QIODevice::WriteOnly|QIODevice::Truncate);

                    QTextStream out(&shortcutsfile);
                    out << newtxt;

                }

                shortcutsfile.close();

            }

        }

    }

}

#endif
