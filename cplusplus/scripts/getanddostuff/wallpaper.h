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
