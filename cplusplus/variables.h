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
