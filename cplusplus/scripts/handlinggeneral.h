/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

#ifndef PQHANDLINGGENERAL_H
#define PQHANDLINGGENERAL_H

#include <QObject>
#include <QRect>
#include <QDesktopServices>
#include <QUrl>
#include <QNetworkInterface>
#include <QMimeDatabase>
#include <QStringRef>
#include <QMessageBox>
#include "../imageprovider/imageproviderfull.h"
#include "../logger.h"

class PQHandlingGeneral : public QObject {

    Q_OBJECT

public:
    Q_INVOKABLE bool isGraphicsMagickSupportEnabled();
    Q_INVOKABLE bool isImageMagickSupportEnabled();
    Q_INVOKABLE bool isLibRawSupportEnabled();
    Q_INVOKABLE bool isLibArchiveSupportEnabled();
    Q_INVOKABLE bool isDevILSupportEnabled();
    Q_INVOKABLE bool isFreeImageSupportEnabled();
    Q_INVOKABLE bool isPopplerSupportEnabled();
    Q_INVOKABLE bool isVideoSupportEnabled();

    Q_INVOKABLE QString getFileNameFromFullPath(QString path, bool onlyExtraInfo = false);
    Q_INVOKABLE QString getFilePathFromFullPath(QString path);
    Q_INVOKABLE bool isDir(QString path);
    Q_INVOKABLE QString getFileSize(QString path);

    Q_INVOKABLE void setLastLoadedImage(QString path);
    Q_INVOKABLE QString getLastLoadedImage();
    Q_INVOKABLE void deleteLastLoadedImage();

    Q_INVOKABLE QString getTempDir();
    Q_INVOKABLE void cleanUpScreenshotsTakenAtStartup();

    Q_INVOKABLE QString getUniqueId();

    Q_INVOKABLE QString convertSecsToProperTime(int secs, int sameFormatsAsVal);

    Q_INVOKABLE void openInDefaultFileManager(QString filename);
    Q_INVOKABLE void copyToClipboard(QString filename);
    Q_INVOKABLE void copyTextToClipboard(QString txt);

    Q_INVOKABLE bool checkIfConnectedToInternet();

    Q_INVOKABLE QString getFileType(QString filename);

    Q_INVOKABLE QVariantList convertHexToRgba(QString hex);
    Q_INVOKABLE QString convertRgbaToHex(QVariantList rgba);

    Q_INVOKABLE bool askForConfirmation(QString text, QString informativeText);

    Q_INVOKABLE void setOverrideCursor(bool enabled);

    Q_INVOKABLE QString getVersion();
    Q_INVOKABLE QString getQtVersion();

    Q_INVOKABLE QStringList getAvailableTranslations();

    Q_INVOKABLE QString getIconPathFromTheme(QString binary);

private:
    PQImageProviderFull *imageprovider;
    QMimeDatabase mimedb;

};

#endif // PQHandlingGeneral
