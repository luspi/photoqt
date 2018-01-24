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

#ifndef STARTUPCHECK_STARTINTRAY_H
#define STARTUPCHECK_STARTINTRAY_H

#include <QScreen>
#include <QDir>
#include <QGuiApplication>
#include "../logger.h"
#include "../settings/settings.h"

namespace StartupCheck {

    namespace StartInTray {

        static inline void makeSureSettingsReflectTrayStartupSetting(bool verbose, int startintray, Settings *settings) {

            if(verbose) LOG << CURDATE << "StartupCheck::StartInTray" << NL;

            if(startintray) {

                if(verbose) LOG << CURDATE << "Starting minimised to tray" << NL;

                // If the option "Use Tray Icon" in the settings is not set, we set it

                settings->setTrayIcon(1);

            }

        }

    }

}

#endif // STARTUPCHECK_STARTINTRAY_H
