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

        static void createDefaultShortcuts() {

            // If the shortcuts file does not exist create it with the set of default shortcuts
            QFile shortcutsfile(ConfigFiles::SHORTCUTS_FILE());
            if(!shortcutsfile.exists()) {

                QString cont = QString("Version=%1\n").arg(VERSION);

                cont += "0::Left::__prev\n";
                cont += "0::Backspace::__prev\n";
                cont += "0::Right Button+W::__prev\n";
                cont += "0::Right::__next\n";
                cont += "0::Space::__next\n";
                cont += "0::Right Button+E::__next\n";
                cont += "0::Home::__goToFirst\n";
                cont += "0::End::__goToLast\n";
                cont += "0::O::__open\n";
                cont += "0::Ctrl+O::__open\n";
                cont += "0::Right Button+WE::__open\n";
                cont += "0::Escape::__quit\n";
                cont += "0::Q::__quit\n";
                cont += "0::Ctrl+Q::__quit\n";
                cont += "0::Right Button+SES::__quit\n";
                cont += "0::+::__zoomIn\n";
                cont += "0::=::__zoomIn\n";
                cont += "0::Ctrl++::__zoomIn\n";
                cont += "0::Ctrl+=::__zoomIn\n";
                cont += "0::Ctrl+Wheel Up::__zoomIn\n";
                cont += "0::-::__zoomOut\n";
                cont += "0::Ctrl+-::__zoomOut\n";
                cont += "0::Ctrl+Wheel Down::__zoomOut\n";
                cont += "0::1::__zoomActual\n";
                cont += "0::Ctrl+1::__zoomActual\n";
                cont += "0::0::__zoomReset\n";
                cont += "0::L::__rotateL\n";
                cont += "0::R::__rotateR\n";
                cont += "0::Ctrl+0::__rotate0\n";
                cont += "0::Ctrl+H::__flipH\n";
                cont += "0::Ctrl+V::__flipV\n";
                cont += "0::P::__settings\n";
                cont += "0::Ctrl+X::__scale\n";
                cont += "0::Ctrl+C::__copy\n";
                cont += "0::Delete::__delete\n";
                cont += "0::Ctrl+M::__move\n";
                cont += "0::F2::__rename\n";
                cont += "0::I::__about\n";
                cont += "0::H::__histogram\n";
                cont += "0::M::__slideshow\n";
                cont += "0::Shift+M::__slideshowQuick\n";
                cont += "0::W::__wallpaper\n";
                cont += "0::Ctrl+F::__filterImages\n";
                cont += "0::Shift+P::__playPauseAni\n";
                cont += "0::F::__tagFaces\n";
                cont += "0::Ctrl+Shift+I::__imgurAnonym\n";
                cont += "0::Ctrl+Shift+S::__saveAs\n";
                cont += "0::Ctrl+S::__saveAs\n";

                if(shortcutsfile.open(QIODevice::WriteOnly)) {
                    QTextStream out(&shortcutsfile);
                    out << cont;
                    shortcutsfile.close();
                } else
                    LOG << CURDATE << "ERROR: Unable to create default shortcuts file" << NL;

            }

        }

    }

}

#endif
