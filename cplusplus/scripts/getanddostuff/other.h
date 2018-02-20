/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#ifndef GETANDDOSTUFFOTHER_H
#define GETANDDOSTUFFOTHER_H

#include <QObject>
#include <QMovie>
#include <QFileInfo>
#include <QSize>
#include <QUrl>
#include <QGuiApplication>
#include <QCursor>
#include <QScreen>
#include <QColor>
#include <QDir>
#include <QTextStream>
#include <QStandardPaths>
#include <QtQml>
#include "../../logger.h"

#include <QWindow>

#ifdef GM
#include <GraphicsMagick/Magick++.h>
#include "../gmimagemagick.h"
#endif

class GetAndDoStuffOther : public QObject {

    Q_OBJECT

public:
    explicit GetAndDoStuffOther(QObject *parent = 0);
    ~GetAndDoStuffOther();

    QString convertRgbaToHex(int r, int g, int b, int a);
    bool amIOnLinux();
    bool amIOnWindows();
    QString trim(QString s) { return s.trimmed(); }
    int getCurrentScreen(int x, int y);
    QString getTempDir();
    QString getHomeDir();
    QString getDesktopDir();
    QString getPicturesDir();
    QString getDownloadsDir();
    bool isExivSupportEnabled();
    bool isGraphicsMagickSupportEnabled();
    bool isLibRawSupportEnabled();
    QString getVersionString();
    void storeGeometry(QRect rect);
    QRect getStoredGeometry();
    bool isImageAnimated(QString path);
    QString convertIdIntoString(QObject *object);

};

#endif // GETANDDOSTUFFOTHER_H
