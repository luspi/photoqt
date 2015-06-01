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

#ifdef GM
#include <GraphicsMagick/Magick++.h>
#endif

class GetAndDoStuffOther : public QObject {

	Q_OBJECT

public:
	explicit GetAndDoStuffOther(QObject *parent = 0);
	~GetAndDoStuffOther();

	bool isImageAnimated(QString path);
	QSize getImageSize(QString path);
	QPoint getCursorPos();
	QPoint getGlobalCursorPos();
	QColor addAlphaToColor(QString col, int alpha);
	bool amIOnLinux();
	QString trim(QString s) { return s.trimmed(); }
	int getCurrentScreen(int x, int y);
	QString getTempDir();
	QString getHomeDir();
	bool isExivSupportEnabled();
	bool isGraphicsMagickSupportEnabled();

private:
	QImageReader reader;

};

#endif // GETANDDOSTUFFOTHER_H
