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
#include <QQmlEngine>
#include <pqc_extensionshandler.h>

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton is a wrapper for the C++ class
//            This class here can ONLY be used from QML!
//
/*************************************************************/
/*************************************************************/

class PQCExtensionsHandlerQML : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(PQCExtensionsHandler)

public:
    PQCExtensionsHandlerQML() {
        connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::numExtensionsEnabledChanged,
                this, &PQCExtensionsHandlerQML::numExtensionsEnabledChanged);
        connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::numExtensionsAllChanged,
                this, &PQCExtensionsHandlerQML::numExtensionsAllChanged);
        connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::numExtensionsFailedChanged,
                this, &PQCExtensionsHandlerQML::numExtensionsFailedChanged);

        connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::mainmenuChanged,
                this, &PQCExtensionsHandlerQML::mainmenuChanged);
        connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::contextMenuUseChanged,
                this, &PQCExtensionsHandlerQML::contextMenuUseChanged);
        connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::contextMenuManipulateChanged,
                this, &PQCExtensionsHandlerQML::contextMenuManipulateChanged);
        connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::contextMenuAboutChanged,
                this, &PQCExtensionsHandlerQML::contextMenuAboutChanged);
        connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::contextMenuOtherChanged,
                this, &PQCExtensionsHandlerQML::contextMenuOtherChanged);

        connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::replyForActionWithImage,
                this, &PQCExtensionsHandlerQML::replyForActionWithImage);
        connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::replyForAction,
                this, &PQCExtensionsHandlerQML::replyForAction);
        connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::receivedMessage,
                this, &PQCExtensionsHandlerQML::receivedMessage);
        connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::resetGeometry,
                this, &PQCExtensionsHandlerQML::resetGeometry);

    }

    Q_PROPERTY(int numExtensionsEnabled READ getNumExtensionsEnabled WRITE setNumExtensionsEnabled NOTIFY numExtensionsEnabledChanged)
    Q_PROPERTY(int numExtensionsAll READ getNumExtensionsAll WRITE setNumExtensionsAll NOTIFY numExtensionsAllChanged)
    Q_PROPERTY(int numExtensionsFailed READ getNumExtensionsFailed WRITE setNumExtensionsFailed NOTIFY numExtensionsFailedChanged)

    int getNumExtensionsEnabled() { return PQCExtensionsHandler::get().getNumExtensionsEnabled(); }
    void setNumExtensionsEnabled(const int val) { PQCExtensionsHandler::get().setNumExtensionsEnabled(val); }
    int getNumExtensionsAll() { return PQCExtensionsHandler::get().getNumExtensionsAll(); }
    void setNumExtensionsAll(const int val) { PQCExtensionsHandler::get().setNumExtensionsAll(val); }
    int getNumExtensionsFailed() { return PQCExtensionsHandler::get().getNumExtensionsFailed(); }
    void setNumExtensionsFailed(const int val) { PQCExtensionsHandler::get().setNumExtensionsFailed(val); }

    Q_PROPERTY(QStringList contextMenuUse READ getContextMenuUse WRITE setContextMenuUse NOTIFY contextMenuUseChanged)
    Q_PROPERTY(QStringList contextMenuManipulate READ getContextMenuManipulate WRITE setContextMenuManipulate NOTIFY contextMenuManipulateChanged)
    Q_PROPERTY(QStringList contextMenuAbout READ getContextMenuAbout WRITE setContextMenuAbout NOTIFY contextMenuAboutChanged)
    Q_PROPERTY(QStringList contextMenuOther READ getContextMenuOther WRITE setContextMenuOther NOTIFY contextMenuOtherChanged)
    Q_PROPERTY(QStringList mainmenu READ getMainmenu WRITE setMainmenu NOTIFY mainmenuChanged);

    QStringList getContextMenuUse() { return PQCExtensionsHandler::get().getContextMenuUse(); }
    void setContextMenuUse(const QStringList val) { PQCExtensionsHandler::get().setContextMenuUse(val); }
    QStringList getContextMenuManipulate() { return PQCExtensionsHandler::get().getContextMenuManipulate(); }
    void setContextMenuManipulate(const QStringList val) { PQCExtensionsHandler::get().setContextMenuManipulate(val); }
    QStringList getContextMenuAbout() { return PQCExtensionsHandler::get().getContextMenuAbout(); }
    void setContextMenuAbout(const QStringList val) { PQCExtensionsHandler::get().setContextMenuAbout(val); }
    QStringList getContextMenuOther() { return PQCExtensionsHandler::get().getContextMenuOther(); }
    void setContextMenuOther(const QStringList val) { PQCExtensionsHandler::get().setContextMenuOther(val); }
    QStringList getMainmenu() { return PQCExtensionsHandler::get().getMainmenu(); }
    void setMainmenu(const QStringList val) { PQCExtensionsHandler::get().setMainmenu(val); }

    // get some extensions properties
    Q_INVOKABLE int     getExtensionVersion(QString id) {
        return PQCExtensionsHandler::get().getExtensionVersion(id);
    }
    Q_INVOKABLE QString getExtensionName(QString id) {
        return PQCExtensionsHandler::get().getExtensionName(id);
    }
    Q_INVOKABLE QString getExtensionLongName(QString id) {
        return PQCExtensionsHandler::get().getExtensionLongName(id);
    }
    Q_INVOKABLE QString getExtensionAuthor(QString id) {
        return PQCExtensionsHandler::get().getExtensionAuthor(id);
    }
    Q_INVOKABLE QString getExtensionContact(QString id) {
        return PQCExtensionsHandler::get().getExtensionContact(id);
    }
    Q_INVOKABLE QString getExtensionDescription(QString id) {
        return PQCExtensionsHandler::get().getExtensionDescription(id);
    }
    Q_INVOKABLE QString getExtensionWebsite(QString id) {
        return PQCExtensionsHandler::get().getExtensionWebsite(id);
    }
    Q_INVOKABLE int     getExtensionTargetAPIVersion(QString id) {
        return PQCExtensionsHandler::get().getExtensionTargetAPIVersion(id);
    }

    Q_INVOKABLE QString getExtensionNameId(QString id) {
        return PQCExtensionsHandler::get().getExtensionNameId(id);
    }

    Q_INVOKABLE bool    getExtensionIntegratedAllow(QString id) {
        return PQCExtensionsHandler::get().getExtensionIntegratedAllow(id);
    }
    Q_INVOKABLE QSize   getExtensionIntegratedMinimumRequiredWindowSize(QString id) {
        return PQCExtensionsHandler::get().getExtensionIntegratedMinimumRequiredWindowSize(id);
    }
    Q_INVOKABLE int     getExtensionIntegratedDefaultPosition(QString id) {
        return PQCExtensionsHandler::get().getExtensionIntegratedDefaultPosition(id);
    }
    Q_INVOKABLE int     getExtensionIntegratedDefaultDistanceFromEdge(QString id) {
        return PQCExtensionsHandler::get().getExtensionIntegratedDefaultDistanceFromEdge(id);
    }
    Q_INVOKABLE QSize   getExtensionIntegratedDefaultSize(QString id) {
        return PQCExtensionsHandler::get().getExtensionIntegratedDefaultSize(id);
    }
    Q_INVOKABLE bool    getExtensionIntegratedFixSizeToContent(QString id) {
        return PQCExtensionsHandler::get().getExtensionIntegratedFixSizeToContent(id);
    }

    Q_INVOKABLE QSize   getExtensionPopoutDefaultSize(QString id) {
        return PQCExtensionsHandler::get().getExtensionPopoutDefaultSize(id);
    }
    Q_INVOKABLE bool    getExtensionPopoutAllow(QString id) {
        return PQCExtensionsHandler::get().getExtensionPopoutAllow(id);
    }
    Q_INVOKABLE bool    getExtensionPopoutFixSizeToContent(QString id) {
        return PQCExtensionsHandler::get().getExtensionPopoutFixSizeToContent(id);
    }

    Q_INVOKABLE bool    getExtensionFloating(QString id) {
        return PQCExtensionsHandler::get().getExtensionFloating(id);
    }
    Q_INVOKABLE bool    getExtensionModal(QString id) {
        return PQCExtensionsHandler::get().getExtensionModal(id);
    }
    Q_INVOKABLE bool    getExtensionMainMenu(QString id) {
        return PQCExtensionsHandler::get().getExtensionMainMenu(id);
    }
    Q_INVOKABLE QString getExtensionDefaultShortcut(QString id) {
        return PQCExtensionsHandler::get().getExtensionDefaultShortcut(id);
    }
    Q_INVOKABLE bool    getExtensionRememberGeometry(QString id) {
        return PQCExtensionsHandler::get().getExtensionRememberGeometry(id);
    }
    Q_INVOKABLE bool    getExtensionCustomMouseHandling(QString id) {
        return PQCExtensionsHandler::get().getExtensionCustomMouseHandling(id);
    }
    Q_INVOKABLE QString getExtensionContextMenuSection(QString id) {
        return PQCExtensionsHandler::get().getExtensionContextMenuSection(id);
    }
    Q_INVOKABLE bool    getExtensionHasCPPActions(QString id) {
        return PQCExtensionsHandler::get().getExtensionHasCPPActions(id);
    }
    Q_INVOKABLE QList<QStringList> getExtensionSettings(QString id) {
        return PQCExtensionsHandler::get().getExtensionSettings(id);
    }

    // get a list of all extension ids
    Q_INVOKABLE QStringList getExtensions() {
        return PQCExtensionsHandler::get().getExtensions();
    }

    // get a list of all disabled extensions
    Q_INVOKABLE QStringList getDisabledExtensions() {
        return PQCExtensionsHandler::get().getDisabledExtensions();
    }

    // get a list of all extensions that failed the verification and are not excluded
    Q_INVOKABLE QStringList getFailedExtensions() {
        return PQCExtensionsHandler::get().getFailedExtensions();
    }

    // get a list of all extensions ids, enabled AND disabled
    Q_INVOKABLE QStringList getExtensionsEnabledAndDisabld() {
        return PQCExtensionsHandler::get().getExtensionsEnabledAndDisabld();
    }

    // get the base dir of the extension
    Q_INVOKABLE QString getExtensionLocation(QString id) {
        return PQCExtensionsHandler::get().getExtensionLocation(id);
    }
    Q_INVOKABLE QString getExtensionConfigLocation(QString id) {
        return PQCExtensionsHandler::get().getExtensionConfigLocation(id);
    }
    Q_INVOKABLE QString getExtensionDataLocation(QString id) {
        return PQCExtensionsHandler::get().getExtensionDataLocation(id);
    }
    Q_INVOKABLE QString getExtensionCacheLocation(QString id) {
        return PQCExtensionsHandler::get().getExtensionCacheLocation(id);
    }

    // check whether an extension comes with a settings widget
    Q_INVOKABLE bool getHasSettings(const QString &id) {
        return PQCExtensionsHandler::get().getHasSettings(id);
    }

    // get the respective extension (if any) for a given shortcut
    Q_INVOKABLE QString getExtensionForShortcut(QString sh) {
        return PQCExtensionsHandler::get().getExtensionForShortcut(sh);
    }
    Q_INVOKABLE QString getShortcutForExtension(QString id) {
        return PQCExtensionsHandler::get().getShortcutForExtension(id);
    }
    Q_INVOKABLE void addShortcut(QString id, QString sh) {
               PQCExtensionsHandler::get().addShortcut(id, sh);
    }
    Q_INVOKABLE void removeShortcut(QString id) {
               PQCExtensionsHandler::get().removeShortcut(id);
    }

    /*************************************************************/
    // everything below is not to be used by any extension!

    // called when setup is supposed to start
    Q_INVOKABLE void setup() {
               PQCExtensionsHandler::get().setup();
    }

    // these are predominantly used by the settings manager
    Q_INVOKABLE void setEnabledExtensions(const QStringList &ids) {
               PQCExtensionsHandler::get().setEnabledExtensions(ids);
    }
    Q_INVOKABLE void setDisabledExtensions(const QStringList &ids) {
               PQCExtensionsHandler::get().setDisabledExtensions(ids);
    }
    Q_INVOKABLE void enableExtension(const QString &id) {
               PQCExtensionsHandler::get().enableExtension(id);
    }
    Q_INVOKABLE void disableExtension(const QString &id) {
               PQCExtensionsHandler::get().disableExtension(id);
    }
    Q_INVOKABLE int installExtension(QString filepath) {
        return PQCExtensionsHandler::get().installExtension(filepath);
    }
    Q_INVOKABLE bool verifyExtension(QString extensionDir, QString nameId) {
        return PQCExtensionsHandler::get().verifyExtension(extensionDir, nameId);
    }

Q_SIGNALS:
    void numExtensionsEnabledChanged();
    void numExtensionsAllChanged();
    void numExtensionsFailedChanged();

    void mainmenuChanged();
    void contextMenuUseChanged();
    void contextMenuManipulateChanged();
    void contextMenuAboutChanged();
    void contextMenuOtherChanged();

    // these are read-only from the QML side
    void replyForActionWithImage(const QString id, QVariant val);
    void replyForAction(const QString id, QVariant val);
    void receivedMessage(const QString id, QVariant val);
    void resetGeometry(QString id);

};
