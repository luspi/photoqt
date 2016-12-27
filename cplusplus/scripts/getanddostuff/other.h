#ifndef GETANDDOSTUFFOTHER_H
#define GETANDDOSTUFFOTHER_H

#include <QObject>
#include <QMovie>
#include <QFileInfo>
#include <QSize>
#include <QUrl>
#include <QGuiApplication>
#include <QCursor>
#include <QScreen>
#include <QColor>
#include <QDir>
#include <QTextStream>
#include <QStandardPaths>
#include "../../logger.h"

#ifdef GM
#include <GraphicsMagick/Magick++.h>
#include "../gmimagemagick.h"
#endif

class GetAndDoStuffOther : public QObject {

	Q_OBJECT

public:
	explicit GetAndDoStuffOther(QObject *parent = 0);
	~GetAndDoStuffOther();

	QPoint getGlobalCursorPos();
	QColor addAlphaToColor(QString col, int alpha);
	bool amIOnLinux();
	bool amIOnWindows();
	QString trim(QString s) { return s.trimmed(); }
	int getCurrentScreen(int x, int y);
	QString getTempDir();
	QString getHomeDir();
	QString getDesktopDir();
	QString getRootDir();
	QString getPicturesDir();
	QString getDownloadsDir();
	bool isExivSupportEnabled();
	bool isGraphicsMagickSupportEnabled();
	bool isLibRawSupportEnabled();
	QString getVersionString();
	QList<QString> getScreenNames();

};

#endif // GETANDDOSTUFFOTHER_H
