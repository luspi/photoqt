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

#ifndef STARTUPCHECK_SCREENSHOTS_H
#define STARTUPCHECK_SCREENSHOTS_H

#include <QScreen>
#include <QDir>
#include <QGuiApplication>
#include "../logger.h"

namespace StartupCheck {

    namespace Screenshots {

        static inline void getAndStore() {

            if(qgetenv("PHOTOQT_DEBUG") == "yes") LOG << CURDATE << "StartupCheck::Screenshots" << NL;

            // Get screenshots for fake transparency
            for(int i = 0; i < QGuiApplication::screens().count(); ++i) {

                QScreen *screen = QGuiApplication::screens().at(i);
                QRect r = screen->geometry();
                QPixmap pix = screen->grabWindow(0,r.x(),r.y(),r.width(),r.height());
                pix.save(QDir::tempPath() + QString("/photoqt_screenshot_%1.jpg").arg(i));

            }

        }

    }

}

#endif // STARTUPCHECK_SCREENSHOTS_H
