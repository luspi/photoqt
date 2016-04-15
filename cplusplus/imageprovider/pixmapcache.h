#ifndef PIXMAPCACHE_H
#define PIXMAPCACHE_H

#include <QObject>
#include <QCache>
#include <QPixmap>

class PixmapCache : public QObject {

	Q_OBJECT

public:
	PixmapCache() : QObject() { cache.setMaxCost(10*1024); }

	void insert(QString key, QPixmap pix) {
		cache.insert(key, &pix, (pix.width()*pix.height()*pix.depth())/8);
	}
	bool find(QString key, QPixmap *pix = NULL) {
		if(cache.contains(key)) {
			pix = cache.take(key);
			return true;
		} else
			return false;
	}

	void setCacheLimit(int lim) {
		cache.setMaxCost(lim);
	}

	~PixmapCache() { }

private:
	QCache<QString,QPixmap> cache;

};

#endif
