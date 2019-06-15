#ifndef PQSTARTUP_SCREENSHOTS_H
#define PQSTARTUP_SCREENSHOTS_H

#include <QScreen>
#include <QDir>
#include <QGuiApplication>
#include <QPixmap>
#include "../logger.h"

namespace PQStartup {

    namespace Screenshots {

        static void getAndStore() {

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

#endif // PQSTARTUPCHECK_SCREENSHOTS_H
