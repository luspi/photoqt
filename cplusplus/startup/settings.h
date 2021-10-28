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

#ifndef PQSTARTUP_SETTINGS_H
#define PQSTARTUP_SETTINGS_H

#include <QFile>
#include <QtSql>
#include "../configfiles.h"
#include "../logger.h"
#include "../settings/settings.h"

namespace PQStartup {

    namespace Settings {

        // this function is called from inside PQSettings
        // that constructor is called before the startup checks begin
        // that's why we need to do it here

        static bool migrateSettings() {

            QFile file(ConfigFiles::SETTINGS_FILE());
            QFile dbfile(ConfigFiles::SETTINGS_DB());

            // if the database doesn't exist, we always need to create it
            if(!dbfile.exists()) {
                if(!QFile::copy(":/settings.db", ConfigFiles::SETTINGS_DB()))
                    LOG << CURDATE << "PQStartup::Settings: unable to create settings database" << NL;
                else {
                    QFile file(ConfigFiles::SETTINGS_DB());
                    file.setPermissions(QFile::WriteOwner|QFile::ReadOwner|QFile::ReadGroup|QFile::ReadOther);
                }
            }

            // nothing to migrate -> we're done
            if(!file.exists())
                return true;

            QSqlDatabase db;

            if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
                db = QSqlDatabase::addDatabase("QSQLITE3", "migratesettings");
            else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
                db = QSqlDatabase::addDatabase("QSQLITE", "migratesettings");
            else
                return false;

            db.setHostName("migratesettings");
            db.setDatabaseName(ConfigFiles::SETTINGS_DB());
            if(!db.open()) {
                LOG << CURDATE << "PQStartup::Settings::migrate: Error opening database: " << db.lastError().text().trimmed().toStdString() << NL;
                return false;
            }

            if(!file.open(QIODevice::ReadOnly)) {
                LOG << CURDATE << "PQStartup::Settings::migrate: Failed to open old settings file" << NL;
                return false;
            }
            QTextStream in(&file);
            QString txt = file.readAll();

            // These are settings combined out of multiple old settings
            QString thumbnailsVisibility = "0";
            QString metadataFaceTagsVisibility = "3";

            for(auto line : txt.split("\n")) {

                if(!line.contains("="))
                    continue;

                bool dontExecQuery = false;

                QSqlQuery query(db);

                QString key = line.split("=")[0].trimmed();
                QString val = line.split("=")[1].trimmed();

                /******************************************************/

                if(key == "Version") {
                    query.prepare("UPDATE `general` SET value=:val WHERE name='Version'");
                    val = QString(VERSION);
                } else if(key == "Language")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='Language'");
                else if(key == "WindowMode")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='WindowMode'");
                else if(key == "WindowDecoration")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='WindowDecoration'");
                else if(key == "SaveWindowGeometry")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='SaveWindowGeometry'");
                else if(key == "KeepOnTop")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='KeepWindowOnTop'");
                else if(key == "StartupLoadLastLoadedImage")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='RememberLastImage'");


                /******************************************************/
                // category: Look

                if(key == "BackgroundColorAlpha")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='OverlayColorAlpha'");
                else if(key == "BackgroundColorBlue")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='OverlayColorBlue'");
                else if(key == "BackgroundColorGreen")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='OverlayColorGreen'");
                else if(key == "BackgroundColorRed")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='OverlayColorRed'");
                else if(key == "BackgroundImageCenter")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImageCenter'");
                else if(key == "BackgroundImagePath")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImagePath'");
                else if(key == "BackgroundImageScale")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImageScale'");
                else if(key == "BackgroundImageScaleCrop")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImageScaleCrop'");
                else if(key == "BackgroundImageScreenshot")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImageScreenshot'");
                else if(key == "BackgroundImageStretch")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImageStretch'");
                else if(key == "BackgroundImageTile")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImageTile'");
                else if(key == "BackgroundImageUse")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImageUse'");


                /******************************************************/
                // category: Behaviour

                if(key == "AnimationDuration")
                    query.prepare("UPDATE `imageview` SET value=:val WHERE name='AnimationDuration'");
                else if(key == "AnimationType")
                    query.prepare("UPDATE `imageview` SET value=:val WHERE name='AnimationType'");
                else if(key == "ArchiveUseExternalUnrar")
                    query.prepare("UPDATE `filetypes` SET value=:val WHERE name='ExternalUnrar'");
                else if(key == "CloseOnEmptyBackground")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='CloseOnEmptyBackground'");
                else if(key == "NavigateOnEmptyBackground")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='NavigateOnEmptyBackground'");

                else if(key == "FitInWindow")
                    query.prepare("UPDATE `imageview` SET value=:val WHERE name='FitInWindow'");
                else if(key == "HotEdgeWidth")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='HotEdgeSize'");
                else if(key == "InterpolationThreshold")
                    query.prepare("UPDATE `imageview` SET value=:val WHERE name='InterpolationThreshold'");
                else if(key == "InterpolationDisableForSmallImages")
                    query.prepare("UPDATE `imageview` SET value=:val WHERE name='InterpolationDisableForSmallImages'");
                else if(key == "KeepZoomRotationMirror")
                    query.prepare("UPDATE `imageview` SET value=:val WHERE name='RememberZoomRotationMirror'");

                else if(key == "LeftButtonMouseClickAndMove")
                    query.prepare("UPDATE `imageview` SET value=:val WHERE name='LeftButtonMoveImage'");
                else if(key == "LoopThroughFolder")
                    query.prepare("UPDATE `imageview` SET value=:val WHERE name='LoopThroughFolder'");
                else if(key == "MarginAroundImage")
                    query.prepare("UPDATE `imageview` SET value=:val WHERE name='Margin'");
                else if(key == "MouseWheelSensitivity")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='MouseWheelSensitivity'");
                else if(key == "PdfQuality")
                    query.prepare("UPDATE `filetypes` SET value=:val WHERE name='PDFQuality'");

                else if(key == "PixmapCache")
                    query.prepare("UPDATE `imageview` SET value=:val WHERE name='Cache'");
                else if(key == "QuickNavigation")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='QuickNavigation'");
                else if(key == "ShowTransparencyMarkerBackground")
                    query.prepare("UPDATE `imageview` SET value=:val WHERE name='TransparencyMarker'");
                else if(key == "SortImagesBy")
                    query.prepare("UPDATE `imageview` SET value=:val WHERE name='SortImagesBy'");
                else if(key == "SortImagesAscending")
                    query.prepare("UPDATE `imageview` SET value=:val WHERE name='SortImagesAscending'");

                else if(key == "TrayIcon")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='TrayIcon'");
                else if(key == "ZoomSpeed")
                    query.prepare("UPDATE `imageview` SET value=:val WHERE name='ZoomSpeed'");


                /******************************************************/
                // category: Labels

                if(key == "LabelsWindowButtonsSize")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsWindowButtonsSize'");
                else if(key == "LabelsHideCounter")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsHideCounter'");
                else if(key == "LabelsHideFilepath")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsHideFilepath'");
                else if(key == "LabelsHideFilename")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsHideFilename'");
                else if(key == "LabelsWindowButtons")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsWindowButtons'");
                else if(key == "LabelsHideZoomLevel")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsHideZoomLevel'");
                else if(key == "LabelsHideRotationAngle")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsHideRotationAngle'");
                else if(key == "LabelsManageWindow")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsManageWindow'");


                /******************************************************/
                // category: Exclude

                if(key == "ExcludeCacheFolders") {
                    QStringList result;
                    QByteArray byteArray = QByteArray::fromBase64(val.toUtf8());
                    QDataStream in(&byteArray, QIODevice::ReadOnly);
                    in >> result;
                    val = result.join(":://::");
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='ExcludeFolders'");
                } else if(key == "ExcludeCacheDropBox")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='ExcludeDropBox'");
                else if(key == "ExcludeCacheNextcloud")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='ExcludeNextcloud'");
                else if(key == "ExcludeCacheOwnCloud")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='ExcludeOwnCloud'");


                /******************************************************/
                // category: Thumbnail

                if(key == "ThumbnailCache")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Cache'");
                else if(key == "ThumbnailCenterActive")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='CenterOnActive'");
                else if(key == "ThumbnailDisable")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Disable'");
                else if(key == "ThumbnailFilenameInstead")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='FilenameOnly'");
                else if(key == "ThumbnailFilenameInsteadFontSize")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='FilenameOnlyFontSize'");

                else if(key == "ThumbnailFontSize")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='FontSize'");
                else if(key == "ThumbnailKeepVisible") {
                    dontExecQuery = true;
                    if(val == "1")
                        thumbnailsVisibility = "1";
                } else if(key == "ThumbnailKeepVisibleWhenNotZoomedIn") {
                    dontExecQuery = true;
                    if(val == "1")
                        thumbnailsVisibility = "2";
                } else if(key == "ThumbnailLiftUp")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='LiftUp'");
                else if(key == "ThumbnailMaxNumberThreads")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='MaxNumberThreads'");

                else if(key == "ThumbnailPosition")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Edge'");
                else if(key == "ThumbnailSize")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Size'");
                else if(key == "ThumbnailSpacingBetween")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Spacing'");
                else if(key == "ThumbnailWriteFilename")
                    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Filename'");


                /******************************************************/
                // category: Slideshow

                if(key == "SlideShowHideLabels")
                    query.prepare("UPDATE `slideshow` SET value=:val WHERE name='HideLabels'");
                else if(key == "SlideShowImageTransition")
                    query.prepare("UPDATE `slideshow` SET value=:val WHERE name='ImageTransition'");
                else if(key == "SlideShowLoop")
                    query.prepare("UPDATE `slideshow` SET value=:val WHERE name='Loop'");
                else if(key == "SlideShowMusicFile")
                    query.prepare("UPDATE `slideshow` SET value=:val WHERE name='MusicFile'");
                else if(key == "SlideShowShuffle")
                    query.prepare("UPDATE `slideshow` SET value=:val WHERE name='Shuffle'");
                else if(key == "SlideShowTime")
                    query.prepare("UPDATE `slideshow` SET value=:val WHERE name='Time'");
                else if(key == "SlideShowTypeAnimation")
                    query.prepare("UPDATE `slideshow` SET value=:val WHERE name='TypeAnimation'");
                else if(key == "SlideShowIncludeSubFolders")
                    query.prepare("UPDATE `slideshow` SET value=:val WHERE name='IncludeSubFolders'");


                /******************************************************/
                // category: Metadata

                if(key == "MetaApplyRotation")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='AutoRotation'");
                else if(key == "MetaCopyright")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='Copyright'");
                else if(key == "MetaDimensions")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='Dimensions'");
                else if(key == "MetaExposureTime")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='ExposureTime'");
                else if(key == "MetaFilename")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='Filename'");

                else if(key == "MetaFileType")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='FileType'");
                else if(key == "MetaFileSize")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='FileSize'");
                else if(key == "MetaFlash")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='Flash'");
                else if(key == "MetaFLength")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='FLength'");
                else if(key == "MetaFNumber")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='FNumber'");

                else if(key == "MetaGps")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='Gps'");
                else if(key == "MetaGpsMapService")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='GpsMap'");
                else if(key == "MetaImageNumber")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='ImageNumber'");
                else if(key == "MetaIso")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='Iso'");
                else if(key == "MetaKeywords")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='Keywords'");

                else if(key == "MetaLightSource")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='LightSource'");
                else if(key == "MetaLocation")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='Location'");
                else if(key == "MetaMake")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='Make'");
                else if(key == "MetaModel")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='Model'");
                else if(key == "MetaSceneType")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='SceneType'");

                else if(key == "MetaSoftware")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='Software'");
                else if(key == "MetaTimePhotoTaken")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='Time'");


                /******************************************************/
                // category: Metadata Element

                if(key == "MetadataEnableHotEdge")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='ElementHotEdge'");
                else if(key == "MetadataOpacity")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='ElementOpacity'");
                else if(key == "MetadataWindowWidth")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='ElementWidth'");


                /******************************************************/
                // category: People Tags in Metadata

                if(key == "PeopleTagInMetaBorderAroundFace")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='FaceTagsBorder'");
                else if(key == "PeopleTagInMetaBorderAroundFaceColor")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='FaceTagsBorderColor'");
                else if(key == "PeopleTagInMetaBorderAroundFaceWidth")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='FaceTagsBorderWidth'");
                else if(key == "PeopleTagInMetaDisplay")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='FaceTagsEnabled'");
                else if(key == "PeopleTagInMetaFontSize")
                    query.prepare("UPDATE `metadata` SET value=:val WHERE name='FaceTagsFontSize'");
                else if(key == "PeopleTagInMetaAlwaysVisible") {
                    dontExecQuery = true;
                    if(val == "1")
                        metadataFaceTagsVisibility = "1";
                } else if(key == "PeopleTagInMetaHybridMode") {
                    dontExecQuery = true;
                    if(val == "1")
                        metadataFaceTagsVisibility = "0";
                } else if(key == "PeopleTagInMetaIndependentLabels") {
                    dontExecQuery = true;
                    if(val == "1")
                        metadataFaceTagsVisibility = "2";
                }


                /******************************************************/
                // category: Open File

                if(key == "OpenDefaultView")
                    query.prepare("UPDATE `openfile` SET value=:val WHERE name='DefaultView'");
                else if(key == "OpenKeepLastLocation")
                    query.prepare("UPDATE `openfile` SET value=:val WHERE name='KeepLastLocation'");
                else if(key == "OpenPreview")
                    query.prepare("UPDATE `openfile` SET value=:val WHERE name='Preview'");
                else if(key == "OpenShowHiddenFilesFolders")
                    query.prepare("UPDATE `openfile` SET value=:val WHERE name='ShowHiddenFilesFolders'");
                else if(key == "OpenThumbnails")
                    query.prepare("UPDATE `openfile` SET value=:val WHERE name='Thumbnails'");

                else if(key == "OpenUserPlacesStandard")
                    query.prepare("UPDATE `openfile` SET value=:val WHERE name='UserPlacesStandard'");
                else if(key == "OpenUserPlacesUser")
                    query.prepare("UPDATE `openfile` SET value=:val WHERE name='UserPlacesUser'");
                else if(key == "OpenUserPlacesVolumes")
                    query.prepare("UPDATE `openfile` SET value=:val WHERE name='UserPlacesVolumes'");
                else if(key == "OpenUserPlacesWidth")
                    query.prepare("UPDATE `openfile` SET value=:val WHERE name='UserPlacesWidth'");
                else if(key == "OpenZoomLevel")
                    query.prepare("UPDATE `openfile` SET value=:val WHERE name='ZoomLevel'");


                /******************************************************/
                // category: Histogram

                if(key == "Histogram")
                    query.prepare("UPDATE `histogram` SET value=:val WHERE name='Visibility'");
                else if(key == "HistogramPosition")
                    query.prepare("UPDATE `histogram` SET value=:val WHERE name='Position'");
                else if(key == "HistogramSize")
                    query.prepare("UPDATE `histogram` SET value=:val WHERE name='Size'");
                else if(key == "HistogramVersion")
                    query.prepare("UPDATE `histogram` SET value=:val WHERE name='Version'");


                /******************************************************/
                // category: Main Menu Element

                if(key == "MainMenuWindowWidth")
                    query.prepare("UPDATE `mainmenu` SET value=:val WHERE name='ElementWidth'");


                /******************************************************/
                // category: Video

                if(key == "VideoAutoplay")
                    query.prepare("UPDATE `filetypes` SET value=:val WHERE name='VideoAutoplay'");
                else if(key == "VideoLoop")
                    query.prepare("UPDATE `filetypes` SET value=:val WHERE name='VideoLoop'");
                else if(key == "VideoVolume")
                    query.prepare("UPDATE `filetypes` SET value=:val WHERE name='VideoVolume'");
                else if(key == "VideoThumbnailer")
                    query.prepare("UPDATE `filetypes` SET value=:val WHERE name='VideoThumbnailer'");


                /******************************************************/
                // category:

                if(key == "MainMenuPopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutMainMenu'");
                else if(key == "MetadataPopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutMetadata'");
                else if(key == "HistogramPopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutHistogram'");
                else if(key == "ScalePopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutScale'");
                else if(key == "OpenPopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutOpenFile'");

                else if(key == "OpenPopoutElementKeepOpen")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutOpenFileKeepOpen'");
                else if(key == "SlideShowSettingsPopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutSlideShowSettings'");
                else if(key == "SlideShowControlsPopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutSlideShowControls'");
                else if(key == "FileRenamePopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutFileRename'");
                else if(key == "FileDeletePopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutFileDelete'");

                else if(key == "AboutPopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutAbout'");
                else if(key == "ImgurPopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutImgur'");
                else if(key == "WallpaperPopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutWallpaper'");
                else if(key == "FilterPopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutFilter'");
                else if(key == "SettingsManagerPopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutSettingsManager'");

                else if(key == "FileSaveAsPopoutElement")
                    query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutFileSaveAs'");

                if(!dontExecQuery) {

                    query.bindValue(":val", val);

                    if(!query.exec()) {
                        LOG << CURDATE << "PQStartup::Settings::migrate: Updating setting failed:  " << key.toStdString() << " / " << val.toStdString() << NL;
                        LOG << CURDATE << "PQStartup::Settings::migrate: SQL error:  " << query.lastError().text().trimmed().toStdString() << NL;
                    }

                }

            }

            // The following multiple old settings combine, thus they can only be updated here

            QSqlQuery query(db);
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Visibility'");
            query.bindValue(":val", thumbnailsVisibility);
            if(!query.exec()) {
                LOG << CURDATE << "PQStartup::Settings::migrate: Updating setting failed:  thumbnailsVisibility / " << thumbnailsVisibility.toStdString() << NL;
                LOG << CURDATE << "PQStartup::Settings::migrate: SQL error:  " << query.lastError().text().trimmed().toStdString() << NL;
            }

            query.clear();
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='FaceTagsVisibility'");
            query.bindValue(":val", metadataFaceTagsVisibility);
            if(!query.exec()) {
                LOG << CURDATE << "PQStartup::Settings::migrate: Updating setting failed:  metadataFaceTagsVisibility / " << metadataFaceTagsVisibility.toStdString() << NL;
                LOG << CURDATE << "PQStartup::Settings::migrate: SQL error:  " << query.lastError().text().trimmed().toStdString() << NL;
            }

            if(!QFile::copy(ConfigFiles::SETTINGS_FILE(), QString("%1.pre-v2.5").arg(ConfigFiles::SETTINGS_FILE())))
                LOG << CURDATE << "PQStartup::Settings::migrate: Failed to copy old settings file to 'settings.pre-v2.5' filename" << NL;
            else {
                if(!QFile::remove(ConfigFiles::SETTINGS_FILE()))
                    LOG << CURDATE << "PQStartup::Settings::migrate: Failed to rename old settings file to 'settings.pre-v2.5'" << NL;
            }

            query.clear();
            db.close();

            return true;

        }

    }

}

#endif // PQSTARTUP_SETTINGS_H
