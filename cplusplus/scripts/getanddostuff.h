#ifndef GETIMAGEINFO_H
#define GETIMAGEINFO_H

#include <QJSValue>

#include "getanddostuff/context.h"
#include "getanddostuff/external.h"
#include "getanddostuff/manipulation.h"
#include "getanddostuff/file.h"
#include "getanddostuff/other.h"
#include "getanddostuff/shortcuts.h"
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
		shortcuts = new GetAndDoStuffShortcuts;
		wallpaper = new GetAndDoStuffWallpaper;
		openfile = new GetAndDoStuffOpenFile;

		connect(manipulation, SIGNAL(reloadDirectory(QString,bool)), this, SIGNAL(reloadDirectory(QString,bool)));
		connect(openfile, SIGNAL(userPlacesUpdated()), this, SIGNAL(userPlacesUpdated()));
		connect(shortcuts, SIGNAL(shortcutFileChanged(int)), this, SLOT(setShortcutNotifier(int)));

	}

	~GetAndDoStuff() {
		delete context;
		delete external;
		delete manipulation;
		delete file;
		delete other;
		delete shortcuts;
		delete wallpaper;
		delete openfile;
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
	Q_INVOKABLE bool renameImage(QString oldfilename, QString newfilename) { return manipulation->renameImage(oldfilename, newfilename); }
	Q_INVOKABLE void copyImage(QString path) { manipulation->copyImage(path); }
	Q_INVOKABLE void moveImage(QString path) { manipulation->moveImage(path); }

	// OTHER
	Q_INVOKABLE bool isImageAnimated(QString path) { return other->isImageAnimated(path); }
	Q_INVOKABLE QSize getAnimatedImageSize(QString path) { return other->getAnimatedImageSize(path); }
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

	// SHORTCUTS
	Q_INVOKABLE QVariantMap getShortcuts() { return shortcuts->getShortcuts(); }
	Q_INVOKABLE void saveShortcuts(QVariantMap l) { shortcuts->saveShortcuts(l); }
	Q_INVOKABLE QVariantMap getDefaultShortcuts() { return shortcuts->getDefaultShortcuts(); }
	Q_INVOKABLE QString getShortcutFile() { return shortcuts->getShortcutFile(); }
	Q_INVOKABLE QString filterOutShortcutCommand(QString combo, QString file) { return shortcuts->filterOutShortcutCommand(combo, file); }

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
	Q_INVOKABLE QVariantList getFoldersIn(QString path) { return this->openfile->getFoldersIn(path); }
	Q_INVOKABLE QVariantList getFilesIn(QString path) { return this->openfile->getFilesIn(path); }
	Q_INVOKABLE QVariantList getFilesWithSizeIn(QString path, int selectionFileTypes) { return this->openfile->getFilesWithSizeIn(path,selectionFileTypes); }
	Q_INVOKABLE void addToUserPlaces(QString path) { this->openfile->addToUserPlaces(path); }
	Q_INVOKABLE void saveUserPlaces(QVariantList enabled) { return this->openfile->saveUserPlaces(enabled); }
	Q_INVOKABLE QString getOpenFileLastLocation() {  return this->openfile->getOpenFileLastLocation(); }
	Q_INVOKABLE void setOpenFileLastLocation(QString path) { openfile->setOpenFileLastLocation(path); }

	int shortcutNotifier;
	Q_PROPERTY(int shortcutNotifier READ getShortcutNotifier WRITE setShortcutNotifier NOTIFY shortcutNotifierChanged)
	int getShortcutNotifier() { return shortcutNotifier; }

public slots:
	void setShortcutNotifier(int val) {
		shortcutNotifier = val;
		emit shortcutNotifierChanged(val);
	}

private:
	GetAndDoStuffContext *context;
	GetAndDoStuffExternal *external;
	GetAndDoStuffManipulation *manipulation;
	GetAndDoStuffFile *file;
	GetAndDoStuffOther *other;
	GetAndDoStuffShortcuts *shortcuts;
	GetAndDoStuffWallpaper *wallpaper;
	GetAndDoStuffOpenFile *openfile;

signals:
	void reloadDirectory(QString path, bool deleted = false);
	void shortcutNotifierChanged(int val);
	void userPlacesUpdated();

};


#endif // GETIMAGEINFO_H
