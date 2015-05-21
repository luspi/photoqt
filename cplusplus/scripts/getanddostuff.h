#ifndef GETIMAGEINFO_H
#define GETIMAGEINFO_H

#include <QImageReader>
#include <QFileInfo>
#include <QSettings>
#include <QCursor>
#include <QColor>
#include <QFileDialog>
#include <QJSValue>
#include <iostream>
#include <QIcon>
#include <QProcess>
#include <QDateTime>
#include <QDesktopServices>
#include <QScreen>
#include <QGuiApplication>

#include "runprocess.h"

#ifdef GM
#include <GraphicsMagick/Magick++.h>
#endif

#ifdef EXIV2
#include <exiv2/image.hpp>
#include <exiv2/exif.hpp>
#endif

#include "getanddostuff/context.h"
#include "getanddostuff/external.h"
#include "getanddostuff/manipulation.h"
#include "getanddostuff/file.h"
#include "getanddostuff/other.h"
#include "getanddostuff/shortcuts.h"
#include "getanddostuff/wallpaper.h"

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

		connect(manipulation, SIGNAL(reloadDirectory(QString,bool)), this, SIGNAL(reloadDirectory(QString,bool)));

	}

	~GetAndDoStuff() {
		delete context;
		delete external;
		delete manipulation;
		delete file;
		delete other;
		delete shortcuts;
		delete wallpaper;
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
	Q_INVOKABLE bool scaleImage(QString filename, int width, int height, int quality, QString newfilename) { return manipulation->scaleImage(filename, width, height, quality, newfilename); }
	Q_INVOKABLE void deleteImage(QString filename, bool trash) { manipulation->deleteImage(filename, trash); }
	Q_INVOKABLE bool renameImage(QString oldfilename, QString newfilename) { manipulation->renameImage(oldfilename, newfilename); }
	Q_INVOKABLE void copyImage(QString path) { manipulation->copyImage(path); }
	Q_INVOKABLE void moveImage(QString path) { manipulation->moveImage(path); }

	// OTHER
	Q_INVOKABLE bool isImageAnimated(QString path) { return other->isImageAnimated(path); }
	Q_INVOKABLE QSize getImageSize(QString path) { return other->getImageSize(path); }
	Q_INVOKABLE QPoint getCursorPos() { return other->getCursorPos(); }
	Q_INVOKABLE QPoint getGlobalCursorPos() { return other->getGlobalCursorPos(); }
	Q_INVOKABLE QColor addAlphaToColor(QString col, int alpha) { return other->addAlphaToColor(col, alpha); }
	Q_INVOKABLE bool amIOnLinux() { return other->amIOnLinux(); }
	Q_INVOKABLE QString trim(QString s) { return other->trim(s); }

	// SHORTCUTS
	Q_INVOKABLE QVariantMap getShortcuts() { return shortcuts->getShortcuts(); }
	Q_INVOKABLE void saveShortcuts(QVariantList l) { shortcuts->saveShortcuts(l); }
	Q_INVOKABLE QVariantMap getDefaultShortcuts() { return shortcuts->getDefaultShortcuts(); }
	Q_INVOKABLE QString getShortcutFile() { return shortcuts->getShortcutFile(); }
	Q_INVOKABLE QString filterOutShortcutCommand(QString combo, QString file) { return shortcuts->filterOutShortcutCommand(combo, file); }

	// WALLPAPER
	Q_INVOKABLE QString detectWindowManager() { return wallpaper->detectWindowManager(); }
	Q_INVOKABLE void setWallpaper(QString wm, QVariantMap options, QString file) { wallpaper->setWallpaper(wm, options, file); }
	Q_INVOKABLE int getScreenCount() { return wallpaper->getScreenCount(); }
	Q_INVOKABLE int checkWallpaperTool(QString wm) { return wallpaper->checkWallpaperTool(wm); }
	Q_INVOKABLE QList<int> getEnlightenmentWorkspaceCount() { return wallpaper->getEnlightenmentWorkspaceCount(); }


private:
	GetAndDoStuffContext *context;
	GetAndDoStuffExternal *external;
	GetAndDoStuffManipulation *manipulation;
	GetAndDoStuffFile *file;
	GetAndDoStuffOther *other;
	GetAndDoStuffShortcuts *shortcuts;
	GetAndDoStuffWallpaper *wallpaper;

signals:
    void reloadDirectory(QString path, bool deleted = false);

};


#endif // GETIMAGEINFO_H
