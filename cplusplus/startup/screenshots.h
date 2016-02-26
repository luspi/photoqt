#ifndef SCREENSHOTS_H
#define SCREENSHOTS_H

#include <QScreen>
#include <QDir>
#include <QGuiApplication>
#include "../logger.h"

namespace StartupCheck {

	namespace Screenshots {

		static inline void getAndStore(bool verbose) {

			if(verbose) LOG << DATE << "StartupCheck::Screenshots" << std::endl;

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

#endif // SCREENSHOTS_H
