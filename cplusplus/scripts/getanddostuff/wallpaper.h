#ifndef GETANDDOSTUFFWALLPAPER_H
#define GETANDDOSTUFFWALLPAPER_H

#include <iostream>
#include <QObject>
#include <QVariantMap>
#include <QProcess>

#include "../runprocess.h"
#include "../../logger.h"

class GetAndDoStuffWallpaper : public QObject {

	Q_OBJECT

public:
	explicit GetAndDoStuffWallpaper(QObject *parent = 0);
	~GetAndDoStuffWallpaper();

	QString detectWindowManager();
	void setWallpaper(QString wm, QVariantMap options, QString file);
	int getScreenCount();
	int checkWallpaperTool(QString wm);
	QList<int> getEnlightenmentWorkspaceCount();

};

#endif // GETANDDOSTUFFWALLPAPER_H
