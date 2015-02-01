#ifndef VARIABLES_H
#define VARIABLES_H

#include <QList>

class Variables {

public:
	Variables() {
		loadedThumbnails.clear();
	}

public:
	QList<int> loadedThumbnails;

};



#endif // VARIABLES_H
