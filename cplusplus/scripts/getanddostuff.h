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
#include "getanddostuff/imageinfo.h"

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
        imageinfo = new GetAndDoStuffImageInfo;

        connect(manipulation, SIGNAL(reloadDirectory(QString,bool)), this, SIGNAL(reloadDirectory(QString,bool)));
        connect(openfile, SIGNAL(userPlacesUpdated()), this, SIGNAL(userPlacesUpdated()));

    }

    ~GetAndDoStuff() {
        delete context;
        delete external;
        delete manipulation;
        delete file;
        delete other;
        delete wallpaper;
        delete openfile;
        delete imageinfo;
    }

    // CONTEXT
    Q_INVOKABLE QStringList setDefaultContextMenuEntries() { return context->setDefaultContextMenuEntries(); }
    Q_INVOKABLE QStringList getContextMenu() { return context->getContextMenu(); }
    Q_INVOKABLE qint64 getContextMenuFileModifiedTime() { return context->getContextMenuFileModifiedTime(); }
    Q_INVOKABLE void saveContextMenu(QJSValue m) { context->saveContextMenu(m.toVariant().toList()); }

    // EXTERNAL
    Q_INVOKABLE void executeApp(QString exec, QString fname) { external->executeApp(exec, fname); }
    Q_INVOKABLE void openLink(QString url) { external->openLink(url); }
    Q_INVOKABLE void openInDefaultFileManager(QString file) { external->openInDefaultFileManager(file); }
    Q_INVOKABLE QString exportConfig() { return external->exportConfig(); }
    Q_INVOKABLE QString importConfig(QString filename) { return external->importConfig(filename); }
    Q_INVOKABLE void restartPhotoQt(QString loadThisFileAfter) { external->restartPhotoQt(loadThisFileAfter); }
    Q_INVOKABLE bool checkIfConnectedToInternet() { return external->checkIfConnectedToInternet(); }

    // FILE
    Q_INVOKABLE QString removePathFromFilename(QString path, bool removeSuffix = false) { return file->removePathFromFilename(path, removeSuffix); }
    Q_INVOKABLE QString removeFilenameFromPath(QString file) { return this->file->removeFilenameFromPath(file); }
    Q_INVOKABLE QString getSuffix(QString file) { return this->file->getSuffix(file); }
    Q_INVOKABLE QString getFilenameQtImage() { return file->getFilenameQtImage(); }
    Q_INVOKABLE QString getFilename(QString caption, QString dir, QString filter = "") { return file->getFilename(caption, dir, filter); }
    Q_INVOKABLE QString getIconPathFromTheme(QString binary) { return file->getIconPathFromTheme(binary); }
    Q_INVOKABLE QString getSaveFilename(QString caption, QString file) { return this->file->getSaveFilename(caption, file); }

    // MANIPULATION
    Q_INVOKABLE bool canBeScaled(QString filename) { return manipulation->canBeScaled(filename); }
    Q_INVOKABLE bool scaleImage(QString filename, int width, int height, int quality, QString newfilename) { return manipulation->scaleImage(filename, width, height, quality, newfilename); }
    Q_INVOKABLE void deleteImage(QString filename, bool trash) { manipulation->deleteImage(filename, trash); }
    Q_INVOKABLE void copyImage(QString imagePath, QString destinationPath) { manipulation->copyImage(imagePath, destinationPath); }
    Q_INVOKABLE void moveImage(QString imagePath, QString destinationPath) { manipulation->moveImage(imagePath, destinationPath); }
    Q_INVOKABLE QString getImageSuffix(QString imagePath) { return manipulation->getImageSuffix(imagePath); }

    // OTHER
    Q_INVOKABLE QPoint getGlobalCursorPos() { return other->getGlobalCursorPos(); }
    Q_INVOKABLE QColor addAlphaToColor(QString col, int alpha) { return other->addAlphaToColor(col, alpha); }
    Q_INVOKABLE bool amIOnLinux() { return other->amIOnLinux(); }
    Q_INVOKABLE bool amIOnWindows() { return other->amIOnWindows(); }
    Q_INVOKABLE QString trim(QString s) { return other->trim(s); }
    Q_INVOKABLE int getCurrentScreen(int x, int y) { return other->getCurrentScreen(x,y); }
    Q_INVOKABLE QString getTempDir() { return other->getTempDir(); }
    Q_INVOKABLE QString getHomeDir() { return other->getHomeDir(); }
    Q_INVOKABLE QString getDesktopDir() { return other->getDesktopDir(); }
    Q_INVOKABLE QString getRootDir() { return other->getRootDir(); }
    Q_INVOKABLE QString getPicturesDir() { return other->getPicturesDir(); }
    Q_INVOKABLE QString getDownloadsDir() { return other->getDownloadsDir(); }
    Q_INVOKABLE bool isExivSupportEnabled() { return other->isExivSupportEnabled(); }
    Q_INVOKABLE bool isGraphicsMagickSupportEnabled() { return other->isGraphicsMagickSupportEnabled(); }
    Q_INVOKABLE bool isLibRawSupportEnabled() { return other->isLibRawSupportEnabled(); }
    Q_INVOKABLE QString getVersionString() { return other->getVersionString(); }
    Q_INVOKABLE QList<QString> getScreenNames() { return other->getScreenNames(); }
    Q_INVOKABLE QRect getStoredGeometry() { return other->getStoredGeometry(); }

    // WALLPAPER
    Q_INVOKABLE QString detectWindowManager() { return wallpaper->detectWindowManager(); }
    Q_INVOKABLE void setWallpaper(QString wm, QVariantMap options, QString file) { wallpaper->setWallpaper(wm, options, file); }
    Q_INVOKABLE int getScreenCount() { return wallpaper->getScreenCount(); }
    Q_INVOKABLE int checkWallpaperTool(QString wm) { return wallpaper->checkWallpaperTool(wm); }
    Q_INVOKABLE QList<int> getEnlightenmentWorkspaceCount() { return wallpaper->getEnlightenmentWorkspaceCount(); }

    // OPENFILE
    Q_INVOKABLE int getNumberFilesInFolder(QString path, int selectionFileTypes) { return this->openfile->getNumberFilesInFolder(path, selectionFileTypes); }
    Q_INVOKABLE QVariantList getUserPlaces() { return this->openfile->getUserPlaces(); }
    Q_INVOKABLE QVariantList getFilesAndFoldersIn(QString path) { return this->openfile->getFilesAndFoldersIn(path); }
    Q_INVOKABLE bool isFolder(QString path) { return this->openfile->isFolder(path); }
    Q_INVOKABLE QString removePrefixFromDirectoryOrFile(QString path) { return this->openfile->removePrefixFromDirectoryOrFile(path); }
    Q_INVOKABLE QVariantList getFoldersIn(QString path, bool getDotDot = true, bool showHidden = false) { return this->openfile->getFoldersIn(path, getDotDot, showHidden); }
    Q_INVOKABLE QVariantList getFilesIn(QString path, QString filter = "") { return this->openfile->getFilesIn(path, filter); }
    Q_INVOKABLE QVariantList getFilesWithSizeIn(QString path, int selectionFileTypes, bool showHidden = false) { return this->openfile->getFilesWithSizeIn(path,selectionFileTypes, showHidden); }
    Q_INVOKABLE void addToUserPlaces(QString path) { this->openfile->addToUserPlaces(path); }
    Q_INVOKABLE void saveUserPlaces(QVariantList enabled) { return this->openfile->saveUserPlaces(enabled); }
    Q_INVOKABLE QString getOpenFileLastLocation() {  return this->openfile->getOpenFileLastLocation(); }
    Q_INVOKABLE void setOpenFileLastLocation(QString path) { openfile->setOpenFileLastLocation(path); }
    Q_INVOKABLE void saveLastOpenedImage(QString path) { openfile->saveLastOpenedImage(path); }
    Q_INVOKABLE QString getDirectoryDirName(QString path) { return openfile->getDirectoryDirName(path); }

    // IMAGE INFO
    Q_INVOKABLE bool isImageAnimated(QString path) { return imageinfo->isImageAnimated(path); }
    Q_INVOKABLE QSize getAnimatedImageSize(QString path) { return imageinfo->getAnimatedImageSize(path); }
    Q_INVOKABLE QList<int> getNumFramesAndDuration(QString filename) { return imageinfo->getNumFramesAndDuration(filename); }
    Q_INVOKABLE QString getLastModified(QString filename) { return imageinfo->getLastModified(filename); }

private:
    GetAndDoStuffContext *context;
    GetAndDoStuffExternal *external;
    GetAndDoStuffManipulation *manipulation;
    GetAndDoStuffFile *file;
    GetAndDoStuffOther *other;
    GetAndDoStuffWallpaper *wallpaper;
    GetAndDoStuffOpenFile *openfile;
    GetAndDoStuffImageInfo *imageinfo;

signals:
    void reloadDirectory(QString path, bool deleted = false);
    void userPlacesUpdated();

};


#endif // GETIMAGEINFO_H
