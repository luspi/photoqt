/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

#ifndef PQCSCRIPTSCONFIG_H
#define PQCSCRIPTSCONFIG_H

#include <QObject>
#include <QTranslator>
#include <QQmlEngine>
#include <QQmlEngine>

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton CANNOT be used from C++.
//            It can ONLY be used from QML.
//
/*************************************************************/
/*************************************************************/

class PQCScriptsConfig : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCScriptsConfig();
    ~PQCScriptsConfig();

    // these are also called from C++, BUT only when PhotoQt exists right after
    // thus in those few spots we create a local instance of this class as we exit right after
    Q_INVOKABLE static QString getConfigInfo(bool formatHTML = false);
    Q_INVOKABLE static bool exportConfigTo(QString path);
    Q_INVOKABLE static bool importConfigFrom(QString path);

    // some general properties
    Q_INVOKABLE bool amIOnWindows();
    Q_INVOKABLE bool isQtAtLeast6_5();
    Q_INVOKABLE QString getVersion();
    Q_INVOKABLE bool isBetaVersion();
    Q_INVOKABLE void callStartupSetupFresh();

    // check for various supported features
    Q_INVOKABLE bool isChromecastEnabled();
    Q_INVOKABLE bool isLocationSupportEnabled();
    Q_INVOKABLE bool isGraphicsMagickSupportEnabled();
    Q_INVOKABLE bool isImageMagickSupportEnabled();
    Q_INVOKABLE bool isPugixmlSupportEnabled();
    Q_INVOKABLE bool isLibRawSupportEnabled();
    Q_INVOKABLE bool isDevILSupportEnabled();
    Q_INVOKABLE bool isFreeImageSupportEnabled();
    Q_INVOKABLE bool isPDFSupportEnabled();
    Q_INVOKABLE bool isLibVipsSupportEnabled();
    Q_INVOKABLE bool isLibArchiveSupportEnabled();
    Q_INVOKABLE bool isMPVSupportEnabled();
    Q_INVOKABLE bool isVideoQtSupportEnabled();
    Q_INVOKABLE bool isMotionPhotoSupportEnabled();
    Q_INVOKABLE bool isPhotoSphereSupportEnabled();
    Q_INVOKABLE bool isZXingSupportEnabled();
    Q_INVOKABLE bool isLCMS2SupportEnabled();
    Q_INVOKABLE bool isICUSupportEnabled();

    // other methods
    Q_INVOKABLE QStringList getAvailableTranslations();
    Q_INVOKABLE void updateTranslation();
    Q_INVOKABLE QString getLastLoadedImage();
    Q_INVOKABLE void setLastLoadedImage(QString path);
    Q_INVOKABLE void deleteLastLoadedImage();

    // pop up messagebox
    Q_INVOKABLE void inform(QString title, QString txt);
    Q_INVOKABLE bool askForConfirmation(QString title, QString text, QString informativeText);

private:

    QTranslator *trans;
    QString currentTranslation;

};

#endif
