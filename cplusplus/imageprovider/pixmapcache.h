#ifndef PQPIXMAPCACHE_H
#define PQPIXMAPCACHE_H

#include <QPixmapCache>
#include "../settings/settings.h"

class PQPixmapCache : public QObject {

    Q_OBJECT

public:
        static PQPixmapCache& get() {
            static PQPixmapCache instance;
            return instance;
        }

        PQPixmapCache(PQPixmapCache const&)  = delete;
        void operator=(PQPixmapCache const&) = delete;

        void setCacheLimit(int limit) { cache->setCacheLimit(limit); }

        bool find(const QString &key, QPixmap *pixmap) { return cache->find(key, pixmap); }

        bool insert(const QString &key, const QPixmap &pixmap) { return cache->insert(key, pixmap); }

private:
        QPixmapCache *cache;
        PQPixmapCache() {
            cache = new QPixmapCache;
            cache->setCacheLimit(8*1024*std::max(0, std::min(1000, PQSettings::get().getPixmapCache())));
        }

};

#endif
