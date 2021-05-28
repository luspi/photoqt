###################################################
#
# Script to generate settings.h and settings.cpp
#
##################################
#
# 1) Property name
# 2) Property type
# 3) Property default value
#

values = {
    
    "" :
        
        [["Version",                    "QString", "QString::fromStdString(VERSION)"],
         ["Language",                   "QString", "QLocale::system().name()"],
         ["WindowMode",                 "bool",    "true"],
         ["WindowDecoration",           "bool",    "true"],
         ["SaveWindowGeometry",         "bool",    "false"],
         ["KeepOnTop",                  "bool",    "false"],
         ["StartupLoadLastLoadedImage", "bool",    "false"]],
    
    "Look" :
        
        [["BackgroundColorAlpha",      "int",  "190"],
         ["BackgroundColorBlue",       "int",  "0"],
         ["BackgroundColorGreen",      "int",  "0"],
         ["BackgroundColorRed",        "int",  "0"],
         ["BackgroundImageCenter",     "bool", "false"],
         ["BackgroundImagePath",       "bool", "\"\""],
         ["BackgroundImageScale",      "bool", "true"],
         ["BackgroundImageScaleCrop",  "bool", "false"],
         ["BackgroundImageScreenshot", "bool", "false"],
         ["BackgroundImageStretch",    "bool", "false"],
         ["BackgroundImageTile",       "bool", "false"],
         ["BackgroundImageUse",        "bool", "false"]],
        
    "Behaviour" :
        
        [["AnimationDuration",                  "int",     "3"],
         ["AnimationType",                      "QString", "\"opacity\""],
         ["ArchiveUseExternalUnrar",            "bool",    "false"],
         ["CloseOnEmptyBackground",             "bool",    "false"],
         ["FitInWindow",                        "bool",    "false"],
         ["HotEdgeWidth",                       "int",     "4"],
         ["InterpolationThreshold",             "int",     "100"],
         ["InterpolationDisableForSmallImages", "bool",    "true"],
         ["KeepZoomRotationMirror",             "bool",    "false"],
         ["LeftButtonMouseClickAndMove",        "bool",    "true"],
         ["LoopThroughFolder",                  "bool",    "true"],
         ["MarginAroundImage",                  "int",     "5"],
         ["MouseWheelSensitivity",              "int",     "0"],
         ["PdfQuality",                         "int",     "150"],
         ["PixmapCache",                        "bool",    "512"],
         ["QuickNavigation",                    "bool",    "false"],
         ["ShowTransparencyMarkerBackground",   "bool",    "false"],
         ["SortImagesBy",                       "QString", "\"naturalname\""],
         ["SortImagesAscending",                "bool",    "true"],
         ["TrayIcon",                           "int",     "0"],
         ["ZoomSpeed",                          "int",     "20"]],
        
    "QuickInfo" :
        
        [["QuickInfoWindowButtonsSize", "int",  "10"],
         ["QuickInfoHideCounter",       "bool", "false"],
         ["QuickInfoHideFilepath",      "bool", "true"],
         ["QuickInfoHideFilename",      "bool", "false"],
         ["QuickInfoWindowButtons",     "bool", "false"],
         ["QuickInfoHideZoomLevel",     "bool", "false"],
         ["QuickInfoHideRotationAngle", "bool", "false"],
         ["QuickInfoManageWindow",      "bool", "false"]],
        
    "Thumbnail" :
        
        [["ThumbnailCache",                      "bool",    "true"],
         ["ThumbnailCenterActive",               "bool",    "false"],
         ["ThumbnailDisable",                    "bool",    "false"],
         ["ThumbnailFilenameInstead",            "bool",    "false"],
         ["ThumbnailFilenameInsteadFontSize",    "int",     "8"],
         ["ThumbnailFontSize",                   "int",     "7"],
         ["ThumbnailKeepVisible",                "bool",    "false"],
         ["ThumbnailKeepVisibleWhenNotZoomedIn", "bool",    "false"],
         ["ThumbnailLiftUp",                     "int",     "6"],
         ["ThumbnailMaxNumberThreads",           "int",     "4"],
         ["ThumbnailPosition",                   "QString", "\"Bottom\""],
         ["ThumbnailSize",                       "int",     "80"],
         ["ThumbnailSpacingBetween",             "int",     "0"],
         ["ThumbnailWriteFilename",              "bool",    "true"]],
        
    "Slideshow" :
        
        [["SlideShowHideQuickInfo",     "bool",    "true"],
         ["SlideShowImageTransition",   "int",     "4"],
         ["SlideShowLoop",              "bool",    "true"],
         ["SlideShowMusicFile",         "QString", "\"\""],
         ["SlideShowShuffle",           "bool",    "false"],
         ["SlideShowTime",              "int",     "5"],
         ["SlideShowTypeAnimation",     "QString", "\"opacity\""],
         ["SlideShowIncludeSubFolders", "bool",    "false"]],
        
    "Metadata" :
        
        [["MetaApplyRotation",  "bool",    "true"],
         ["MetaCopyright",      "bool",    "true"],
         ["MetaDimensions",     "bool",    "true"],
         ["MetaExposureTime",   "bool",    "true"],
         ["MetaFilename",       "bool",    "true"],
         ["MetaFileType",       "bool",    "true"],
         ["MetaFileSize",       "bool",    "true"],
         ["MetaFlash",          "bool",    "true"],
         ["MetaFLength",        "bool",    "true"],
         ["MetaFNumber",        "bool",    "true"],
         ["MetaGps",            "bool",    "true"],
         ["MetaGpsMapService",  "QString", "\"openstreetmap.org\""],
         ["MetaImageNumber",    "bool",    "true"],
         ["MetaIso",            "bool",    "true"],
         ["MetaKeywords",       "bool",    "true"],
         ["MetaLightSource",    "bool",    "true"],
         ["MetaLocation",       "bool",    "true"],
         ["MetaMake",           "bool",    "true"],
         ["MetaModel",          "bool",    "true"],
         ["MetaSceneType",      "bool",    "true"],
         ["MetaSoftware",       "bool",    "true"],
         ["MetaTimePhotoTaken", "bool",    "true"]],
        
    "Metadata Element" :
        
        [["MetadataEnableHotEdge", "bool", "true"],
         ["MetadataOpacity",       "int",  "220"],
         ["MetadataWindowWidth",   "int",  "450"]],
        
    "People Tags in Metadata" :
        
        [["PeopleTagInMetaAlwaysVisible",         "bool",    "false"],
         ["PeopleTagInMetaBorderAroundFace",      "bool",    "false"],
         ["PeopleTagInMetaBorderAroundFaceColor", "QString", "\"#44ff0000\""],
         ["PeopleTagInMetaBorderAroundFaceWidth", "int",     "3"],
         ["PeopleTagInMetaDisplay",               "bool",    "true"],
         ["PeopleTagInMetaFontSize",              "int",     "10"],
         ["PeopleTagInMetaHybridMode",            "bool",    "true"],
         ["PeopleTagInMetaIndependentLabels",     "bool",    "false"]],
        
    "Open File" :
        
        [["OpenDefaultView",            "QString", "\"list\""],
         ["OpenKeepLastLocation",       "bool",    "false"],
         ["OpenPreview",                "bool",    "true"],
         ["OpenShowHiddenFilesFolders", "bool",    "false"],
         ["OpenThumbnails",             "bool",    "true"],
         ["OpenUserPlacesStandard",     "bool",    "true"],
         ["OpenUserPlacesUser",         "bool",    "true"],
         ["OpenUserPlacesVolumes",      "bool",    "true"],
         ["OpenUserPlacesWidth",        "int",     "300"],
         ["OpenZoomLevel",              "int",     "20"]],
        
    "Histogram" :
        
        [["Histogram",         "bool",    "false"],
         ["HistogramPosition", "QPoint",  "100,100"],
         ["HistogramSize",     "QSize",   "300,200"],
         ["HistogramVersion",  "QString", "\"color\""]],
        
    "Main Menu Element" :
        
        [["MainMenuWindowWidth", "int", "450"]],
        
    "Video" :
        
        [["VideoAutoplay",    "bool",    "true"],
         ["VideoLoop",        "bool",    "false"],
         ["VideoVolume",      "int",     "100"],
         ["VideoThumbnailer", "QString", "\"ffmpegthumbnailer\""]],
        
    "Popout" :
        
        [["MainMenuPopoutElement",          "bool", "false"],
         ["MetadataPopoutElement",          "bool", "false"],
         ["HistogramPopoutElement",         "bool", "false"],
         ["ScalePopoutElement",             "bool", "false"],
         ["OpenPopoutElement",              "bool", "false"],
         ["OpenPopoutElementKeepOpen",      "bool", "false"],
         ["SlideShowSettingsPopoutElement", "bool", "false"],
         ["SlideShowControlsPopoutElement", "bool", "false"],
         ["FileRenamePopoutElement",        "bool", "false"],
         ["FileDeletePopoutElement",        "bool", "false"],
         ["AboutPopoutElement",             "bool", "false"],
         ["ImgurPopoutElement",             "bool", "false"],
         ["WallpaperPopoutElement",         "bool", "false"],
         ["FilterPopoutElement",            "bool", "false"],
         ["SettingsManagerPopoutElement",   "bool", "false"],
         ["FileSaveAsPopoutElement",        "bool", "false"]]
        
}


#########################################################################

#########################################################################

#########################################################################

#########################################################################

#########################################################################
#########################################################################
#########################################################################
#########################################################################
##
## COMPOSING THE HEADER settings.h
##
#########################################################################
#########################################################################

preamble  = """/**************************************************************************
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
 
 /* auto-generated using generatesettings.py */

#ifndef PQSETTINGS_H
#define PQSETTINGS_H

#include <QObject>
#include <QQmlContext>
#include <QQmlEngine>
#include <QPoint>
#include <QSize>
#include <QTimer>
#include <QFileSystemWatcher>
#include <QFile>
#include <QFileInfo>

#include "../logger.h"

class PQSettings : public QObject {

    Q_OBJECT

public:
    static PQSettings& get() {
        static PQSettings instance;
        return instance;
    }

    PQSettings(PQSettings const&)     = delete;
    void operator=(PQSettings const&) = delete;

    Q_INVOKABLE void setDefault();
    
"""

# preamble of PRIVATE section             
private  = """
private:
    PQSettings();

    QTimer *saveSettingsTimer;
    QFileSystemWatcher *watcher;
    QTimer *watcherAddFileTimer;
    
"""

# init Q_PROPERTY section
qproperty = ""

# init SIGNALS section
signals = "signals:\n"

for key in values:
    for v in values[key]:

        prpCap = v[0]
        prp = f"{v[0][0].lower()}{v[0][1:]}"
        typ = v[1]
        val = v[2]


        ##############################
        ## Q_PROPERTY section

        qproperty += f"    Q_PROPERTY({typ} {prp} READ get{prpCap} WRITE set{prpCap} NOTIFY {prp}Changed)\n"
        qproperty += f"    {typ} get{prpCap}() {{ return m_{prp}; }}\n"
        qproperty += f"    void set{prpCap}({typ} val) {{\n"
        qproperty += f"        if(m_{prp} != val) {{\n"
        qproperty += f"            m_{prp} = val;\n"
        qproperty += f"            emit {prp}Changed();\n"
        qproperty +=  "            saveSettingsTimer->start();\n"
        qproperty +=  "        }\n"
        qproperty +=  "    }\n"
        qproperty +=  "    \n"


        ##############################
        ## PRIVATE section

        private += f"    {typ:7} m_{prp};\n"


        ##############################
        ## SIGNALS section

        signals += f"    void {prp}Changed();\n"

# PROVATE SLOTS section
privateslots  = """
private slots:
    void readSettings();
    void saveSettings();
    void addFileToWatcher();
    
"""

#####################################
#####################################

file_h = open("settings.h","w")

file_h.write(preamble)
file_h.write(qproperty)
file_h.write(private)
file_h.write(privateslots)
file_h.write(signals)
file_h.write("\n};\n\n#endif // PQSETTINGS_H\n")

file_h.close()


#########################################################################
#########################################################################
#########################################################################
#########################################################################
##
## COMPOSING THE source settings.cpp
##
#########################################################################
#########################################################################

preamble  = """/**************************************************************************
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
 
 /* auto-generated using generatesettings.py */

#include "settings.h"

PQSettings::PQSettings() {

    // When saving the settings, we don't want to write the settings file hundreds of time within a few milliseconds,
    // but use a timer to save it once after all settings are set
    saveSettingsTimer = new QTimer;
    saveSettingsTimer->setInterval(400);
    saveSettingsTimer->setSingleShot(true);

    watcher = new QFileSystemWatcher;
    connect(watcher, &QFileSystemWatcher::fileChanged, [this](QString){ readSettings(); });

    watcherAddFileTimer = new QTimer;
    watcherAddFileTimer->setInterval(500);
    watcherAddFileTimer->setSingleShot(true);
    connect(watcherAddFileTimer, &QTimer::timeout, this, &PQSettings::addFileToWatcher);

    setDefault();
    readSettings();

    // we only connect it here so that setting the defaults doesn't accidentally trigger overwriting existing settings
    connect(saveSettingsTimer, &QTimer::timeout, this, &PQSettings::saveSettings);

}
"""

addfiletowatcher  = """
void PQSettings::addFileToWatcher() {

    DBG << CURDATE << "PQSettings::addFileToWatcher()" << NL;

    QFileInfo info(ConfigFiles::SETTINGS_FILE());
    if(!info.exists()) {
        watcherAddFileTimer->start();
        return;
    }
    watcher->removePath(ConfigFiles::SETTINGS_FILE());
    watcher->addPath(ConfigFiles::SETTINGS_FILE());
    
}
"""

setdefault  = """
void PQSettings::setDefault() {

    DBG << CURDATE << \"PQSettings::setDefault()\" << NL;
    
"""

readsettings  = """
void PQSettings::readSettings() {

    DBG << CURDATE << "PQSettings::readSettings()" << NL;

    watcherAddFileTimer->start();

    QFile file(ConfigFiles::SETTINGS_FILE());

    if(file.exists() && !file.open(QIODevice::ReadOnly))

        LOG << CURDATE  << "Settings::readSettings() - ERROR reading settings:" << file.errorString().trimmed().toStdString() << NL;

    else if(file.exists() && file.isOpen()) {

        // Read file
        QTextStream in(&file);
        QStringList parts = in.readAll().split("\\n");
        file.close();

        for(QString line : parts) {
        
"""

savesettings  = """
// Save settings
void PQSettings::saveSettings() {

    DBG << CURDATE << "PQSettings::saveSettings()" << NL;

    QFile file(ConfigFiles::SETTINGS_FILE());

    if(file.exists() && !file.open(QIODevice::ReadWrite))

        LOG << CURDATE << "Settings::saveSettings() - ERROR saving settings" << NL;

    else {

        if(file.exists()) {
            file.close();
            file.remove();
        }
        file.open(QIODevice::ReadWrite);

        QTextStream out(&file);

"""

firstpass = 1

for key in values:
    
    if key != "":
        savesettings += f"\n        cont += \"\\n[{key}]\\n\";\n\n"
    
    for v in values[key]:
        
        prpCap = v[0]
        prp = f"{v[0][0].lower()}{v[0][1:]}"
        typ = v[1]
        val = v[2]
        
        #####################################
        
        if typ == "QSize":
            setdefault += f"    set{prpCap}(QSize({val}));\n"
        elif typ == "QPoint":
            setdefault += f"    set{prpCap}(QPoint({val}));\n"
        else:
            setdefault += f"    set{prpCap}({val});\n"
        
        
        #####################################
        
        if firstpass == 1:
            readsettings += f"            if(line.startsWith(\"{prpCap}=\"))"
        else:
            readsettings += f"            else if(line.startsWith(\"{prpCap}=\"))"
            
        if typ == "QString":
            readsettings += f"\n                set{prpCap}(line.split(\"=\").at(1).trimmed());\n"
        elif typ == "bool" or typ == "int":
            readsettings += f"\n                set{prpCap}(line.split(\"=\").at(1).toInt());\n"
        elif typ == "QPoint":
            readsettings += f" {{\n                QStringList parts = line.split(\"{prpCap}=\").at(1).split(\",\");\n"
            readsettings += f"                set{prpCap}(QPoint(parts.at(0).toInt(), parts.at(1).toInt()));\n"
            readsettings += "            }\n"
        elif typ == "QSize":
            readsettings += f" {{\n                QStringList parts = line.split(\"{prpCap}=\").at(1).split(\",\");\n"
            readsettings += f"                set{prpCap}(QSize(parts.at(0).toInt(), parts.at(1).toInt()));\n"
            readsettings += "            }\n"
        readsettings += "\n"
        
        
        #####################################
        
        if firstpass == 1:
            savesettings += "        QString cont = "
        else:
            savesettings += "        cont += "
            
        if typ == "QString" or typ == "int":
            savesettings += f"QString(\"{prpCap}=%1\\n\").arg(m_{prp});\n";
        elif typ == "bool":
            savesettings += f"QString(\"{prpCap}=%1\\n\").arg(int(m_{prp}));\n";
        elif typ == "QPoint":
            savesettings += f"QString(\"{prpCap}=%1,%2\\n\").arg(m_{prp}.x()).arg(m_{prp}.y());\n"
        elif typ == "QSize":
            savesettings += f"QString(\"{prpCap}=%1,%2\\n\").arg(m_{prp}.width()).arg(m_{prp}.height());\n"
        
        
        #####################################
        
        firstpass = 0
        
    #####################################
    
    setdefault += "\n"
    readsettings += "\n"
    
#####################################

readsettings += "        }\n\n"
readsettings += "    }\n\n"
readsettings += "}\n\n"

#####################################

setdefault += "}\n"

#####################################

savesettings += "\n"
savesettings += "        out << cont;\n"
savesettings += "        file.close();\n"
savesettings += "\n"
savesettings += "    }\n"
savesettings += "\n"
savesettings += "}\n"

#####################################
#####################################

file_c = open("settings.cpp","w")

file_c.write(preamble)
file_c.write(addfiletowatcher)
file_c.write(setdefault)
file_c.write(readsettings)
file_c.write(savesettings)

file_c.close()
