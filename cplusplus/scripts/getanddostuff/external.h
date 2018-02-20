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

#ifndef GETANDDOSTUFFEXTERNAL_H
#define GETANDDOSTUFFEXTERNAL_H

#include <QObject>
#include <QDesktopServices>
#include <QProcess>
#include <QFileInfo>
#include <QDir>
#include <QUrl>
#include <QFileDialog>
#include <sstream>
#include <QApplication>
#include <QTimer>
#include <QNetworkInterface>
#include <QRegExpValidator>
#include "../../logger.h"
#include "../../imageprovider/imageproviderfull.h"

#include "../../zip/zipreader.h"
#include "../../zip/zipwriter.h"

class GetAndDoStuffExternal : public QObject {

    Q_OBJECT

public:
    explicit GetAndDoStuffExternal(QObject *parent = 0);
    ~GetAndDoStuffExternal();

    void executeApp(QString exec, QString fname);
    void openLink(QString url);
    void openInDefaultFileManager(QString file);
    QString exportConfig(QString useThisFilename = "");
    QString importConfig(QString filename);
    void restartPhotoQt(QString loadThisFileAfter);
    bool checkIfConnectedToInternet();
    void clipboardSetImage(QString filepath);

private:
    ImageProviderFull *imageprovider;

};

#endif // GETANDDOSTUFFEXTERNAL_H
