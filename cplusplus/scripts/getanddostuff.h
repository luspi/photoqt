/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

#ifndef GETIMAGEINFO_H
#define GETIMAGEINFO_H

#include <QJSValue>

#include "getanddostuff/context.h"
#include "getanddostuff/external.h"
#include "getanddostuff/manipulation.h"
#include "getanddostuff/file.h"
#include "getanddostuff/other.h"
#include "getanddostuff/wallpaper.h"
#include "getanddostuff/openfile.h"

class GetAndDoStuff : public QObject {

    Q_OBJECT

public:
     explicit GetAndDoStuff(QObject *parent = 0) : QObject(parent) {

        context = new GetAndDoStuffContext;
        external = new GetAndDoStuffExternal;
        manipulation = new GetAndDoStuffManipulation;
        file = new GetAndDoStuffFile;
        other = new GetAndDoStuffOther;
        wallpaper = new GetAndDoStuffWallpaper;
        openfile = new GetAndDoStuffOpenFile;

        connect(manipulation, SIGNAL(reloadDirectory(QString,bool)), this, SIGNAL(reloadDirectory(QString,bool)));

    }

    ~GetAndDoStuff() {
        delete context;
        delete external;
        delete manipulation;
        delete file;
        delete other;
        delete wallpaper;
        delete openfile;
    }

    // CONTEXT
    Q_INVOKABLE QStringList getDefaultContextMenuEntries() { return context->getDefaultContextMenuEntries(); }
    Q_INVOKABLE QStringList getContextMenu() { return context->getContextMenu(); }
    Q_INVOKABLE void saveContextMenu(QJSValue m) { context->saveContextMenu(m.toVariant().toList()); }

    // EXTERNAL
    Q_INVOKABLE void executeApp(QString exec, QString fname) { external->executeApp(exec, fname); }
    Q_INVOKABLE void openLink(QString url) { external->openLink(url); }
    Q_INVOKABLE void openInDefaultFileManager(QString file) { external->openInDefaultFileManager(file); }
    Q_INVOKABLE QString exportConfig() { return external->exportConfig(); }
    Q_INVOKABLE QString importConfig(QString filename) { return external->importConfig(filename); }
    Q_INVOKABLE void restartPhotoQt(QString loadThisFileAfter) { external->restartPhotoQt(loadThisFileAfter); }
    Q_INVOKABLE bool checkIfConnectedToInternet() { return external->checkIfConnectedToInternet(); }
    Q_INVOKABLE void clipboardSetImage(QString filepath) { external->clipboardSetImage(filepath); }

    // FILE
    Q_INVOKABLE QString removePathFromFilename(QString path, bool removeSuffix = false) { return file->removePathFromFilename(path, removeSuffix); }
    Q_INVOKABLE QString removeFilenameFromPath(QString file) { return this->file->removeFilenameFromPath(file); }
    Q_INVOKABLE QString getSuffix(QString file) { return this->file->getSuffix(file); }
    Q_INVOKABLE QString getFilenameQtImage() { return file->getFilenameQtImage(); }
    Q_INVOKABLE QString getFilename(QString caption, QString dir, QString filter = "") { return file->getFilename(caption, dir, filter); }
    Q_INVOKABLE QString getIconPathFromTheme(QString binary) { return file->getIconPathFromTheme(binary); }
    Q_INVOKABLE QString getSaveFilename(QString caption, QString file) { return this->file->getSaveFilename(caption, file); }
    Q_INVOKABLE bool doesThisExist(QString path) { return this->file->doesThisExist(path); }

    // MANIPULATION
    Q_INVOKABLE bool canBeScaled(QString filename) { return manipulation->canBeScaled(filename); }
    Q_INVOKABLE bool scaleImage(QString filename, int width, int height, int quality, QString newfilename) { return manipulation->scaleImage(filename, width, height, quality, newfilename); }
    Q_INVOKABLE void deleteImage(QString filename, bool trash) { manipulation->deleteImage(filename, trash); }
    Q_INVOKABLE void copyImage(QString imagePath, QString destinationPath) { manipulation->copyImage(imagePath, destinationPath); }
    Q_INVOKABLE void moveImage(QString imagePath, QString destinationPath) { manipulation->moveImage(imagePath, destinationPath); }
    Q_INVOKABLE QString getImageBaseName(QString imagePath) { return manipulation->getImageBaseName(imagePath); }

    // OTHER
    Q_INVOKABLE QString convertRgbaToHex(int r, int g, int b, int a) { return other->convertRgbaToHex(r, g, b, a); }
    Q_INVOKABLE bool amIOnLinux() { return other->amIOnLinux(); }
    Q_INVOKABLE bool amIOnWindows() { return other->amIOnWindows(); }
    Q_INVOKABLE QString trim(QString s) { return other->trim(s); }
    Q_INVOKABLE int getCurrentScreen(int x, int y) { return other->getCurrentScreen(x,y); }
    Q_INVOKABLE QString getTempDir() { return other->getTempDir(); }
    Q_INVOKABLE QString getHomeDir() { return other->getHomeDir(); }
    Q_INVOKABLE QString getDesktopDir() { return other->getDesktopDir(); }
    Q_INVOKABLE QString getPicturesDir() { return other->getPicturesDir(); }
    Q_INVOKABLE QString getDownloadsDir() { return other->getDownloadsDir(); }
    Q_INVOKABLE bool isExivSupportEnabled() { return other->isExivSupportEnabled(); }
    Q_INVOKABLE bool isGraphicsMagickSupportEnabled() { return other->isGraphicsMagickSupportEnabled(); }
    Q_INVOKABLE bool isLibRawSupportEnabled() { return other->isLibRawSupportEnabled(); }
    Q_INVOKABLE bool isDevILSupportEnabled() { return other->isDevILSupportEnabled(); }
    Q_INVOKABLE QString getVersionString() { return other->getVersionString(); }
    Q_INVOKABLE void storeGeometry(QRect rect) { other->storeGeometry(rect); }
    Q_INVOKABLE QRect getStoredGeometry() { return other->getStoredGeometry(); }
    Q_INVOKABLE bool isImageAnimated(QString path) { return other->isImageAnimated(path); }
    Q_INVOKABLE QString convertIdIntoString(QObject *object) { return other->convertIdIntoString(object); }

    // WALLPAPER
    Q_INVOKABLE QString detectWindowManager() { return wallpaper->detectWindowManager(); }
    Q_INVOKABLE void setWallpaper(QString wm, QVariantMap options, QString file) { wallpaper->setWallpaper(wm, options, file); }
    Q_INVOKABLE int getScreenCount() { return wallpaper->getScreenCount(); }
    Q_INVOKABLE int checkWallpaperTool(QString wm) { return wallpaper->checkWallpaperTool(wm); }
    Q_INVOKABLE QList<int> getEnlightenmentWorkspaceCount() { return wallpaper->getEnlightenmentWorkspaceCount(); }

    // OPENFILE
    Q_INVOKABLE int getNumberFilesInFolder(QString path, int selectionFileTypes) { return this->openfile->getNumberFilesInFolder(path, selectionFileTypes); }
    Q_INVOKABLE QVariantList getUserPlaces() { return this->openfile->getUserPlaces(); }
    Q_INVOKABLE QVariantList getStorageInfo() { return this->openfile->getStorageInfo(); }
    Q_INVOKABLE QVariantList getFoldersIn(QString path, bool getDotDot = true, bool showHidden = false) { return this->openfile->getFoldersIn(path, getDotDot, showHidden); }
    Q_INVOKABLE QVariantList getFilesIn(QString file, QString filter, QString sortby, bool sortbyAscending) { return this->openfile->getFilesIn(file, filter, sortby, sortbyAscending); }
    Q_INVOKABLE QVariantList getFilesWithSizeIn(QString path, int selectionFileTypes, bool showHidden, QString sortby, bool sortbyAscending) { return this->openfile->getFilesWithSizeIn(path,selectionFileTypes, showHidden, sortby, sortbyAscending); }
    Q_INVOKABLE void saveUserPlaces(QVariantList enabled) { return this->openfile->saveUserPlaces(enabled); }
    Q_INVOKABLE QString getOpenFileLastLocation() {  return this->openfile->getOpenFileLastLocation(); }
    Q_INVOKABLE void setOpenFileLastLocation(QString path) { openfile->setOpenFileLastLocation(path); }
    Q_INVOKABLE void saveLastOpenedImage(QString path) { openfile->saveLastOpenedImage(path); }
    Q_INVOKABLE QString getLastOpenedImage() { return openfile->getLastOpenedImage(); }
    Q_INVOKABLE QString getCurrentWorkingDirectory() { return openfile->getCurrentWorkingDirectory(); }
    Q_INVOKABLE QString getDirectoryDirName(QString path) { return openfile->getDirectoryDirName(path); }
    Q_INVOKABLE bool isSupportedImageType(QString path) { return openfile->isSupportedImageType(path); }

private:
    GetAndDoStuffContext *context;
    GetAndDoStuffExternal *external;
    GetAndDoStuffManipulation *manipulation;
    GetAndDoStuffFile *file;
    GetAndDoStuffOther *other;
    GetAndDoStuffWallpaper *wallpaper;
    GetAndDoStuffOpenFile *openfile;

signals:
    void reloadDirectory(QString path, bool deleted = false);

};


#endif // GETIMAGEINFO_H
