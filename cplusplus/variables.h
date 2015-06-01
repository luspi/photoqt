#ifndef VARIABLES_H
#define VARIABLES_H

#include <QList>
#include <QRect>

class Variables {

public:
	Variables() {
		verbose = false;
		loadedThumbnails.clear();
		currentDir = "";
        fileDialogOpened = false;
        geometryWhenHiding = QRect();
        skipSystemTrayAndQuit = false;
		trayiconSetup = false;
		trayiconVisible = false;
		hiddenToTrayIcon = false;
		wheelcounter = 0;
	}

public:
	bool verbose;

	QList<int> loadedThumbnails;
	QString currentDir;

    bool fileDialogOpened;
    QRect geometryWhenHiding;
    bool skipSystemTrayAndQuit;
	bool trayiconSetup;
	bool trayiconVisible;
	bool hiddenToTrayIcon;

	int wheelcounter;

};



#endif // VARIABLES_H
