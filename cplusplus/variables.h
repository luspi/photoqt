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

#ifndef VARIABLES_H
#define VARIABLES_H

#include <QList>
#include <QRect>
#include <QVariant>

class Variables {

public:
	Variables() {
		verbose = false;
		loadedThumbnails.clear();
		currentDir = "";
		geometryWhenHiding = QRect();
		skipSystemTrayAndQuit = false;
		trayiconSetup = false;
		trayiconVisible = false;
		hiddenToTrayIcon = false;
		wheelcounter = 0;
		openfileFilter = "";
		keepLoadingThumbnails = false;
	}

public:
	bool verbose;

	QList<int> loadedThumbnails;
	QString currentDir;

	QRect geometryWhenHiding;
	bool skipSystemTrayAndQuit;
	bool trayiconSetup;
	bool trayiconVisible;
	bool hiddenToTrayIcon;

	QString openfileFilter;

	int wheelcounter;

	bool keepLoadingThumbnails;

};



#endif // VARIABLES_H
