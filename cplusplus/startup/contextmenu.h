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

#ifndef PQSTARTUP_CONTEXTMENU_H
#define PQSTARTUP_CONTEXTMENU_H

#include <QApplication>
#include <QProcess>
#include <QFile>
#include "../configfiles.h"
#include "../logger.h"

namespace PQStartup {

    namespace ContextMenu {

        bool checkIfBinaryExists(QString exec) {

#ifdef Q_OS_WIN
            return false;
#endif

            QProcess p;
            p.setStandardOutputFile(QProcess::nullDevice());
            p.start("which", QStringList() << exec);
            p.waitForFinished();
            return p.exitCode() == 0;
        }


        static void createDefault() {

            QFile file(ConfigFiles::CONTEXTMENU_FILE());
            if(!file.exists()) {

#ifdef Q_OS_WIN
                return;
#endif

                // These are the possible entries
                // There will be a ' %f' added at the end of each executable.
                QStringList m;
                //: Used as in 'Edit with [application]'. %1 will be replaced with application name.
                m << QApplication::translate("startup", "Edit with %1").arg("Gimp") << "gimp"
                     //: Used as in 'Edit with [application]'. %1 will be replaced with application name.
                  << QApplication::translate("startup", "Edit with %1").arg("Krita") << "krita"
                     //: Used as in 'Edit with [application]'. %1 will be replaced with application name.
                  << QApplication::translate("startup", "Edit with %1").arg("KolourPaint") << "kolourpaint"
                     //: Used as in 'Open with [application]'. %1 will be replaced with application name.
                  << QApplication::translate("startup", "Open in %1").arg("GwenView") << "gwenview"
                     //: Used as in 'Open with [application]'. %1 will be replaced with application name.
                  << QApplication::translate("startup", "Open in %1").arg("showFoto") << "showfoto"
                     //: Used as in 'Open with [application]'. %1 will be replaced with application name.
                  << QApplication::translate("startup", "Open in %1").arg("Shotwell") << "shotwell"
                     //: Used as in 'Open with [application]'. %1 will be replaced with application name.
                  << QApplication::translate("startup", "Open in %1").arg("GThumb") << "gthumb"
                     //: Used as in 'Open with [application]'. %1 will be replaced with application name.
                  << QApplication::translate("startup", "Open in %1").arg("Eye of Gnome") << "eog";

                QString cont = "";
                // Check for all entries
                for(int i = 0; i < m.size()/2; ++i)
                    if(checkIfBinaryExists(m[2*i+1])) {
                        cont += QString("0%1").arg(m[2*i+1]);
                        cont += " %f\n";
                        cont += QString("%1\n\n").arg(m[2*i]);
                    }

                if(file.open(QIODevice::WriteOnly)) {

                    QTextStream out(&file);
                    out << cont;
                    file.close();

                }


            }

        }

    }

}

#endif // PQSTARTUP_CONTEXTMENU_H
