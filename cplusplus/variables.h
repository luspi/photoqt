#ifndef VARIABLES_H
#define VARIABLES_H

#include <QList>

class Variables {

public:
	Variables() {
		loadedThumbnails.clear();
		currentDir = "";
	}

public:
	QList<int> loadedThumbnails;
	QString currentDir;

};



#endif // VARIABLES_H
