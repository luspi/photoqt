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

#ifndef STARTUPCHECK_SETTINGS_H
#define STARTUPCHECK_SETTINGS_H

#include "../configfiles.h"
#include "../logger.h"
#include "../settings/settings.h"

namespace StartupCheck {

    namespace Settings {

        static inline void moveToNewKeyNames() {

            QFile fileIn(ConfigFiles::SETTINGS_FILE());
            if(!fileIn.open(QIODevice::ReadOnly)) {
                LOG << CURDATE << "ERROR! Startup::Settings - unable to open settings file for reading -> unable to ensure values are preserved between sessions." << NL;
                return;
            }

            QTextStream in(&fileIn);

            QString all = in.readAll();

            fileIn.close();

            // THESE SETTINGS CHANGED NAME!!

            all.replace("MyWidgetAnimated", "ElementsFadeIn");
            all.replace("Transition", "ImageTransition");
            all.replace("CloseOnGrey", "CloseOnEmptyBackground");
            all.replace("BorderAroundImg", "MarginAroundImage");
            all.replace("MenuSensitivity", "HotEdgeWidth");
            all.replace("SlideShowTransition", "SlideShowImageTransition");
            all.replace("ThbCacheFile", "ThumbnailCacheFile");

            all.replace("bgColorRed", "backgroundColorRed");
            all.replace("bgColorGreen", "backgroundColorGreen");
            all.replace("bgColorBlue", "backgroundColorBlue");
            all.replace("bgColorAlpha", "backgroundColorAlpha");

            all.replace("HideCounter", "QuickinfoHideCounter");
            all.replace("HideFilepathShowFilename", "QuickinfoHideFilepath");
            all.replace("HideFilename", "QuickinfoHideFilename");
            all.replace("HideX", "QuickinfoHideX");
            all.replace("FancyX", "QuickinfoFancyX");
            all.replace("CloseXSize", "QuickinfoCloseXSize");

            all.replace("ExifFilename", "MetaFilename");
            all.replace("ExifFiletype", "MetaFileType");
            all.replace("ExifFilesize", "MetaFileSize");
            all.replace("ExifImageNumber", "MetaImageNumber");
            all.replace("ExifDimensions", "MetaDimensions");
            all.replace("ExifMake", "MetaMake");
            all.replace("ExifModel", "MetaModel");
            all.replace("ExifSoftware", "MetaSoftware");
            all.replace("ExifPhotoTaken", "MetaTimePhotoTaken");
            all.replace("ExifExposureTime", "MetaExposureTime");
            all.replace("ExifFlash", "MetaFlash");
            all.replace("ExifIso", "MetaIso");
            all.replace("ExifSceneType", "MetaSceneType");
            all.replace("ExifFLength", "MetaFLength");
            all.replace("ExifFNumber", "MetaFNumber");
            all.replace("ExifLightSource", "MetaLightSource");
            all.replace("ExifGps", "MetaGps");
            all.replace("ExifRotation", "MetaRotation");
            all.replace("ExifGPSMapService", "MetaGpsMapService");

            all.replace("IptcKeywords", "MetaKeywords");
            all.replace("IptcLocation", "MetaLocation");
            all.replace("IptcCopyright", "MetaCopyright");

            all.replace("ExifEnableMouseTriggering", "MetadataEnableHotEdge");
            all.replace("ExifFontSize", "MetadataFontSize");
            all.replace("ExifOpacity", "MetadataOpacity");
            all.replace("ExifMetadaWindowWidth", "MetadataWindowWidth");

            QFile fileOut(ConfigFiles::SETTINGS_FILE());
            if(!fileOut.open(QIODevice::WriteOnly|QIODevice::Truncate)) {
                LOG << CURDATE << "ERROR! Startup::Settings - unable to open settings file for writing -> unable to ensure values are preserved between sessions." << NL;
                return;
            }

            QTextStream out(&fileOut);
            out << all;
            fileOut.close();
        }

    }
}

#endif // STARTUPCHECK_SETTINGS_H
