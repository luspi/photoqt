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

#ifndef GETANDDOSTUFFIMAGEINFO_H
#define GETANDDOSTUFFIMAGEINFO_H

#include <QObject>
#include <QMovie>
#include "../../imageprovider/imageproviderfull.h"

class GetAndDoStuffImageInfo : public QObject {

    Q_OBJECT

public:
    explicit GetAndDoStuffImageInfo(QObject *parent = 0);
    ~GetAndDoStuffImageInfo();

    bool isImageAnimated(QString path);
    QSize getAnimatedImageSize(QString path);
    QList<int> getNumFramesAndDuration(QString filename);
    QString getLastModified(QString filename);

private:
    ImageProviderFull *provider;

    QMovie *mov;

};

#endif // GETANDDOSTUFFIMAGEINFO_H
