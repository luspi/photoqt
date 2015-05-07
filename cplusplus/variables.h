#ifndef VARIABLES_H
#define VARIABLES_H

#include <QList>
#include <QRect>

class Variables {

public:
	Variables() {
		loadedThumbnails.clear();
		currentDir = "";
        fileDialogOpened = false;
        geometryWhenHiding = QRect();
        skipSystemTrayAndQuit = false;
	}

public:
	QList<int> loadedThumbnails;
	QString currentDir;

    bool fileDialogOpened;
    QRect geometryWhenHiding;
    bool skipSystemTrayAndQuit;

};



#endif // VARIABLES_H
