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

            if(!all.contains("ElementsFadeIn="))
                all.replace("MyWidgetAnimated==", "ElementsFadeIn=");

            if(!all.contains("ImageTransition="))
                all.replace("Transition=", "ImageTransition=");

            if(!all.contains("CloseOnEmptyBackground="))
                all.replace("CloseOnGrey=", "CloseOnEmptyBackground=");

            if(!all.contains("MarginAroundImage="))
                all.replace("BorderAroundImg=", "MarginAroundImage=");

            if(!all.contains("HotEdgeWidth="))
                all.replace("MenuSensitivity=", "HotEdgeWidth=");

            if(!all.contains("SlideShowImageTransition="))
                all.replace("SlideShowTransition=", "SlideShowImageTransition=");

            if(!all.contains("ThumbnailCacheFile="))
                all.replace("ThbCacheFile=", "ThumbnailCacheFile=");


            if(!all.contains("backgroundColorRed="))
                all.replace("bgColorRed=", "backgroundColorRed=");

            if(!all.contains("backgroundColorGreen="))
                all.replace("bgColorGreen=", "backgroundColorGreen=");

            if(!all.contains("backgroundColorBlue="))
                all.replace("bgColorBlue=", "backgroundColorBlue=");

            if(!all.contains("backgroundColorAlpha="))
                all.replace("bgColorAlpha=", "backgroundColorAlpha=");


            if(!all.contains("QuickInfoHideCounter="))
                all.replace("HideCounter=", "QuickInfoHideCounter=");

            if(!all.contains("QuickInfoHideFilepath="))
                all.replace("HideFilepathShowFilename=", "QuickInfoHideFilepath=");

            if(!all.contains("QuickInfoHideFilename="))
                all.replace("HideFilename=", "QuickInfoHideFilename=");

            if(!all.contains("QuickInfoHideX="))
                all.replace("HideX=", "QuickInfoHideX=");

            if(!all.contains("QuickInfoFullX="))
                all.replace("FancyX=", "QuickInfoFullX=");

            if(!all.contains("QuickInfoCloseXSize="))
                all.replace("CloseXSize=", "QuickInfoCloseXSize=");


            if(!all.contains("MetaFilename="))
                all.replace("ExifFilename=", "MetaFilename=");

            if(!all.contains("MetaFileType="))
                all.replace("ExifFiletype=", "MetaFileType=");

            if(!all.contains("MetaFileSize="))
                all.replace("ExifFilesize=", "MetaFileSize=");

            if(!all.contains("MetaImageNumber="))
                all.replace("ExifImageNumber=", "MetaImageNumber=");

            if(!all.contains("MetaDimensions="))
                all.replace("ExifDimensions=", "MetaDimensions=");

            if(!all.contains("MetaMake="))
                all.replace("ExifMake=", "MetaMake=");

            if(!all.contains("MetaModel="))
                all.replace("ExifModel=", "MetaModel=");

            if(!all.contains("MetaSoftware="))
                all.replace("ExifSoftware=", "MetaSoftware=");

            if(!all.contains("MetaTimePhotoTaken="))
                all.replace("ExifPhotoTaken=", "MetaTimePhotoTaken=");

            if(!all.contains("MetaExposureTime="))
                all.replace("ExifExposureTime=", "MetaExposureTime=");

            if(!all.contains("MetaFlash="))
                all.replace("ExifFlash=", "MetaFlash=");

            if(!all.contains("MetaIso="))
                all.replace("ExifIso=", "MetaIso=");

            if(!all.contains("MetaSceneType="))
                all.replace("ExifSceneType=", "MetaSceneType=");

            if(!all.contains("MetaFLength="))
                all.replace("ExifFLength=", "MetaFLength=");

            if(!all.contains("MetaFNumber="))
                all.replace("ExifFNumber=", "MetaFNumber=");

            if(!all.contains("MetaLightSource="))
                all.replace("ExifLightSource=", "MetaLightSource=");

            if(!all.contains("MetaGps="))
                all.replace("ExifGps=", "MetaGps=");

            if(!all.contains("MetaGpsMapService="))
                all.replace("ExifGPSMapService=", "MetaGpsMapService=");


            if(!all.contains("MetaKeywords="))
                all.replace("IptcKeywords=", "MetaKeywords=");

            if(!all.contains("MetaLocation="))
                all.replace("IptcLocation=", "MetaLocation=");

            if(!all.contains("MetaCopyright="))
                all.replace("IptcCopyright=", "MetaCopyright=");


            if(!all.contains("MetadataEnableHotEdge="))
                all.replace("ExifEnableMouseTriggering=", "MetadataEnableHotEdge=");

            if(!all.contains("MetadataFontSize="))
                all.replace("ExifFontSize=", "MetadataFontSize=");

            if(!all.contains("MetadataOpacity="))
                all.replace("ExifOpacity=", "MetadataOpacity=");

            if(!all.contains("MetadataWindowWidth="))
                all.replace("ExifMetadaWindowWidth=", "MetadataWindowWidth=");

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
