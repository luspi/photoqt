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

#ifdef GM
#include <GraphicsMagick/Magick++.h>
#endif

#ifdef EXIV2
#include <exiv2/image.hpp>
#include <exiv2/exif.hpp>
#endif

class GetAndDoStuff : public QObject {

	Q_OBJECT

public:
	explicit GetAndDoStuff(QObject *parent = 0);
	~GetAndDoStuff();

	Q_INVOKABLE bool isImageAnimated(QString path);
	Q_INVOKABLE QSize getImageSize(QString path);

    Q_INVOKABLE QPoint getCursorPos();
    Q_INVOKABLE QPoint getGlobalCursorPos();

    Q_INVOKABLE QString removePathFromFilename(QString path, bool removeSuffix = false);
    Q_INVOKABLE QString removeFilenameFromPath(QString file);
    Q_INVOKABLE QString getSuffix(QString file);

	Q_INVOKABLE QColor addAlphaToColor(QString col, int alpha);

	Q_INVOKABLE QString getFilenameQtImage();

	Q_INVOKABLE QStringList setDefaultContextMenuEntries();
	Q_INVOKABLE QStringList getContextMenu();
	Q_INVOKABLE qint64 getContextMenuFileModifiedTime();

	Q_INVOKABLE void saveContextMenu(QJSValue m);
	void saveContextMenu(QVariantList m);

	Q_INVOKABLE QVariantMap getShortcuts();
	Q_INVOKABLE void saveShortcuts(QVariantList l);
	Q_INVOKABLE QVariantMap getDefaultShortcuts();

	Q_INVOKABLE QString trim(QString s) { return s.trimmed(); }

	Q_INVOKABLE QString getShortcutFile();
	Q_INVOKABLE QString filterOutShortcutCommand(QString combo, QString file);

	Q_INVOKABLE QString getFilename(QString caption, QString dir, QString filter = "");

	Q_INVOKABLE QString getIconPathFromTheme(QString binary);
	Q_INVOKABLE bool checkIfBinaryExists(QString exec);
	Q_INVOKABLE void executeApp(QString exec, QString fname, QString close);
    Q_INVOKABLE void openLink(QString url);
    Q_INVOKABLE void openInDefaultFileManager(QString file);

    Q_INVOKABLE bool scaleImage(QString filename, int width, int height, int quality, QString newfilename);
    Q_INVOKABLE QString getSaveFilename(QString caption, QString file);

    Q_INVOKABLE bool amIOnLinux();
    Q_INVOKABLE void deleteImage(QString filename, bool trash);
    Q_INVOKABLE bool renameImage(QString oldfilename, QString newfilename);
    Q_INVOKABLE void copyImage(QString path);
    Q_INVOKABLE void moveImage(QString path);

    Q_INVOKABLE QString detectWindowManager();
    Q_INVOKABLE void setWallpaper(QString wm, QVariantMap options, QString file);


private:
	QImageReader reader;
	QSettings *settings;

signals:
    void reloadDirectory(QString path, bool deleted = false);

};


#endif // GETIMAGEINFO_H
