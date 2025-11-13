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

class PQCScriptsConfig : public QObject {

    Q_OBJECT

public:
    static PQCScriptsConfig& get() {
        static PQCScriptsConfig instance;
        return instance;
    }

    PQCScriptsConfig(PQCScriptsConfig const&) = delete;
    void operator=(PQCScriptsConfig const&) = delete;

    // these are also called from C++, BUT only when PhotoQt exists right after
    // thus in those few spots we create a local instance of this class as we exit right after
    static QString getConfigInfo(bool formatHTML = false);
    static bool exportConfigTo(QString path);
    static bool importConfigFrom(QString path);

    // some general properties
    bool amIOnWindows();
    bool isQtAtLeast6_5();
    QString getVersion();
    bool isBetaVersion();
    bool isDebugBuild();
    void callStartupSetupFresh();

    // check for various supported features
    bool isChromecastEnabled();
    bool isLocationSupportEnabled();
    bool isGraphicsMagickSupportEnabled();
    bool isImageMagickSupportEnabled();
    bool isPugixmlSupportEnabled();
    bool isLibRawSupportEnabled();
    bool isDevILSupportEnabled();
    bool isFreeImageSupportEnabled();
    bool isPDFSupportEnabled();
    bool isLibVipsSupportEnabled();
    bool isLibArchiveSupportEnabled();
    bool isMPVSupportEnabled();
    bool isVideoQtSupportEnabled();
    bool isMotionPhotoSupportEnabled();
    bool isPhotoSphereSupportEnabled();
    bool isZXingSupportEnabled();
    bool isLCMS2SupportEnabled();
    bool isICUSupportEnabled();

    // other methods
    QString getLastLoadedImage();
    void setLastLoadedImage(QString path);
    void deleteLastLoadedImage();

    // pop up messagebox
    void inform(QString title, QString txt);
    bool askForConfirmation(QString title, QString text, QString informativeText);

private:
    PQCScriptsConfig();
    ~PQCScriptsConfig();

};

#endif
