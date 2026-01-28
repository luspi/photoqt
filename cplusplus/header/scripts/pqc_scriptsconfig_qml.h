/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
#pragma once

#include <QObject>
#include <QTranslator>
#include <QQmlEngine>
#include <scripts/pqc_scriptsconfig.h>

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton is a wrapper for the C++ class
//            This class here can ONLY be used from QML!
//
/*************************************************************/
/*************************************************************/

class PQCScriptsConfigQML : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(PQCScriptsConfig)

public:
    PQCScriptsConfigQML() {}

    // these are also called from C++, BUT only when PhotoQt exists right after
    // thus in those few spots we create a local instance of this class as we exit right after
    Q_INVOKABLE static QString getConfigInfo(bool formatHTML = false) {
        return PQCScriptsConfig::get().getConfigInfo(formatHTML);
    }
    Q_INVOKABLE static bool exportConfigTo(QString path) {
        return PQCScriptsConfig::get().exportConfigTo(path);
    }
    Q_INVOKABLE static bool importConfigFrom(QString path) {
        return PQCScriptsConfig::get().importConfigFrom(path);
    }

    // some general properties
    Q_INVOKABLE bool amIOnWindows() {
        return PQCScriptsConfig::get().amIOnWindows();
    }
    Q_INVOKABLE bool isQtAtLeast6_5() {
        return PQCScriptsConfig::get().isQtAtLeast6_5();
    }
    Q_INVOKABLE QString getVersion() {
        return PQCScriptsConfig::get().getVersion();
    }
    Q_INVOKABLE bool isBetaVersion() {
        return PQCScriptsConfig::get().isBetaVersion();
    }
    Q_INVOKABLE bool isDebugBuild() {
        return PQCScriptsConfig::get().isDebugBuild();
    }
    Q_INVOKABLE void callStartupSetupFresh() {
        PQCScriptsConfig::get().callStartupSetupFresh();
    }

    // check for various supported features
    Q_INVOKABLE bool isChromecastEnabled() {
        return PQCScriptsConfig::get().isChromecastEnabled();
    }
    Q_INVOKABLE bool isLocationSupportEnabled() {
        return PQCScriptsConfig::get().isLocationSupportEnabled();
    }
    Q_INVOKABLE bool isGraphicsMagickSupportEnabled() {
        return PQCScriptsConfig::get().isGraphicsMagickSupportEnabled();
    }
    Q_INVOKABLE bool isImageMagickSupportEnabled() {
        return PQCScriptsConfig::get().isImageMagickSupportEnabled();
    }
    Q_INVOKABLE bool isPugixmlSupportEnabled() {
        return PQCScriptsConfig::get().isPugixmlSupportEnabled();
    }
    Q_INVOKABLE bool isLibRawSupportEnabled() {
        return PQCScriptsConfig::get().isLibRawSupportEnabled();
    }
    Q_INVOKABLE bool isDevILSupportEnabled() {
        return PQCScriptsConfig::get().isDevILSupportEnabled();
    }
    Q_INVOKABLE bool isFreeImageSupportEnabled() {
        return PQCScriptsConfig::get().isFreeImageSupportEnabled();
    }
    Q_INVOKABLE bool isPDFSupportEnabled() {
        return PQCScriptsConfig::get().isPDFSupportEnabled();
    }
    Q_INVOKABLE bool isLibVipsSupportEnabled() {
        return PQCScriptsConfig::get().isLibVipsSupportEnabled();
    }
    Q_INVOKABLE bool isLibArchiveSupportEnabled() {
        return PQCScriptsConfig::get().isLibArchiveSupportEnabled();
    }
    Q_INVOKABLE bool isMPVSupportEnabled() {
        return PQCScriptsConfig::get().isMPVSupportEnabled();
    }
    Q_INVOKABLE bool isVideoQtSupportEnabled() {
        return PQCScriptsConfig::get().isVideoQtSupportEnabled();
    }
    Q_INVOKABLE bool isMotionPhotoSupportEnabled() {
        return PQCScriptsConfig::get().isMotionPhotoSupportEnabled();
    }
    Q_INVOKABLE bool isPhotoSphereSupportEnabled() {
        return PQCScriptsConfig::get().isPhotoSphereSupportEnabled();
    }
    Q_INVOKABLE bool isZXingSupportEnabled() {
        return PQCScriptsConfig::get().isZXingSupportEnabled();
    }
    Q_INVOKABLE bool isLCMS2SupportEnabled() {
        return PQCScriptsConfig::get().isLCMS2SupportEnabled();
    }
    Q_INVOKABLE bool isICUSupportEnabled() {
        return PQCScriptsConfig::get().isICUSupportEnabled();
    }
    Q_INVOKABLE bool isJasperWorkaroundsEnabled() {
        return PQCScriptsConfig::get().isJasperWorkaroundsEnabled();
    }

    // other methods
    Q_INVOKABLE QString getLastLoadedImage() {
        return PQCScriptsConfig::get().getLastLoadedImage();
    }
    Q_INVOKABLE void setLastLoadedImage(QString path) {
        PQCScriptsConfig::get().setLastLoadedImage(path);
    }
    Q_INVOKABLE void deleteLastLoadedImage() {
        PQCScriptsConfig::get().deleteLastLoadedImage();
    }

    // pop up messagebox
    Q_INVOKABLE void inform(QString title, QString txt) {
        PQCScriptsConfig::get().inform(title, txt);
    }
    Q_INVOKABLE bool askForConfirmation(QString title, QString text, QString informativeText) {
        return PQCScriptsConfig::get().askForConfirmation(title, text, informativeText);
    }

    // interface handling at runtime
    Q_INVOKABLE bool setInterfaceForNextStartup(QString variant) {
        return PQCScriptsConfig::get().setInterfaceForNextStartup(variant);
    }
    Q_INVOKABLE QString getInterfaceForNextStartup() {
        return PQCScriptsConfig::get().getInterfaceForNextStartup();
    }

};
