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

#ifdef GM
#include <GraphicsMagick/Magick++.h>
#endif

class GetAndDoStuff : public QObject {

	Q_OBJECT

public:
	explicit GetAndDoStuff(QObject *parent = 0);

	Q_INVOKABLE bool isImageAnimated(QString path);
	Q_INVOKABLE QSize getImageSize(QString path);

	Q_INVOKABLE QPoint getCursorPos();

	Q_INVOKABLE QString removePathFromFilename(QString path);

	Q_INVOKABLE QColor addAlphaToColor(QString col, int alpha);

	Q_INVOKABLE QString getFilenameQtImage();

	Q_INVOKABLE QStringList getContextMenu();

	Q_INVOKABLE void saveContextMenu(QJSValue m);

	Q_INVOKABLE QVariantList getShortcuts();

	Q_INVOKABLE QString trim(QString s) { return s.trimmed(); }

private:
	QImageReader reader;
	QSettings *settings;

};


#endif // GETIMAGEINFO_H
