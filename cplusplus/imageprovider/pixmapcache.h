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
