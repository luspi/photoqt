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
		openfileFilter = QVariant();
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

	QVariant openfileFilter;

	int wheelcounter;

};



#endif // VARIABLES_H
