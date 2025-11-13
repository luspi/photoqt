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

#ifndef PQCSCRIPTSEXTENSIONS_H
#define PQCSCRIPTSEXTENSIONS_H

#include <QObject>
#include <QMap>
#include <QSize>
#include <QtDebug>
#include <pqc_extensionactions.h>
#include <scripts/pqc_scriptsshortcuts.h>

class PQCExtensionInfo {
public:

    PQCExtensionInfo() {

        // about
        version = 0;
        name = "";
        description = "";
        author = "";
        contact = "";
        website = "";
        targetAPI = 0;

        // setup/integrated
        integratedAllow = true;
        integratedMinimumRequiredWindowSize = QSize(0,0);
        integratedDefaultPosition = 0;
        integratedDefaultDistanceFromEdge = 50;
        integratedDefaultSize = QSize(-1,-1);
        integratedFixSizeToContent = false;

        // setup/popout
        popoutAllow = true;
        popoutDefaultSize = QSize(-1,-1);
        popoutFixSizeToContent = false;

        // setup
        modal = false;
        defaultShortcut = "";
        rememberGeometry = true;
        letMeHandleMouseEvents = false;
        haveCPPActions = false;
        settings = {};

        /***********************/
        // auto generated
        location = "";

    }

    // about
    int version;
    QString name;
    QString description;
    QString author;
    QString contact;
    QString website;
    int targetAPI;

    // setup/integrated
    bool  integratedAllow;
    QSize integratedMinimumRequiredWindowSize;
    int   integratedDefaultPosition;
    int   integratedDefaultDistanceFromEdge;
    QSize integratedDefaultSize;
    bool  integratedFixSizeToContent;

    // setup/popout
    bool  popoutAllow;
    QSize popoutDefaultSize;
    bool  popoutFixSizeToContent;

    // setup
    bool modal;
    QString defaultShortcut;
    bool    rememberGeometry;
    bool    letMeHandleMouseEvents;
    bool    haveCPPActions;
    QList<QStringList>
            settings;

    /***************/

    // extension location in file system
    QString location;

    // convert string to int
    int getIntegerForPosition(std::string val) {
        if(val == "TopLeft" || val == "")
            return 0;
        else if(val == "Top")
            return 1;
        else if(val == "TopRight")
            return 2;
        else if(val == "Left")
            return 3;
        else if(val == "Center")
            return 4;
        else if(val == "Right")
            return 5;
        else if(val == "BottomLeft")
            return 6;
        else if(val == "Bottom")
            return 7;
        else if(val == "BottomRight")
            return 8;
        else {
            qWarning() << "Invalid enum value found:" << val;
            return 0;
        }
    }

};

class PQCExtensionsHandler : public QObject {

    Q_OBJECT

public:
    static PQCExtensionsHandler& get() {
        static PQCExtensionsHandler instance;
        return instance;
    }
    ~PQCExtensionsHandler();

    PQCExtensionsHandler(PQCExtensionsHandler const&)     = delete;
    void operator=(PQCExtensionsHandler const&) = delete;
    bool loadExtension(PQCExtensionInfo *extinfo, QString id, QString baseDir, QString definition);

    // GLOBAL PROPERTIES
    Q_PROPERTY(int numExtensions MEMBER m_numExtensions NOTIFY numExtensionsChanged)

    // REQUEST CUSTOM ACTIONS TO BE TAKEN
    Q_INVOKABLE void requestCallActionWithImage(const QString &id, QVariant additional = QVariant(), bool async = true);
    Q_INVOKABLE void requestCallAction(const QString &id, QVariant additional = QVariant(), bool async = true);

    // SOME SETTINGS STUFF
    Q_INVOKABLE bool getIsEnabled(const QString &id);
    Q_INVOKABLE bool getIsEnabledByDefault(const QString &id);

    // CHECK EXTENSION VERIFICATION
    Q_INVOKABLE bool verifyExtension(QString baseDir, QString id);

    /**********************************/

    // Some other actions that can be requested
    Q_INVOKABLE void executeInternalCommand(QString cmd) {
        PQCScriptsShortcuts::get().executeInternalCommand(cmd);
    }

    /**********************************/

    // get some extensions properties
    Q_INVOKABLE int     getExtensionVersion(QString id);
    Q_INVOKABLE QString getExtensionName(QString id);
    Q_INVOKABLE QString getExtensionAuthor(QString id);
    Q_INVOKABLE QString getExtensionContact(QString id);
    Q_INVOKABLE QString getExtensionDescription(QString id);
    Q_INVOKABLE QString getExtensionWebsite(QString id);
    Q_INVOKABLE int     getExtensionTargetAPIVersion(QString id);

    Q_INVOKABLE bool    getExtensionIntegratedAllow(QString id);
    Q_INVOKABLE QSize   getExtensionIntegratedMinimumRequiredWindowSize(QString id);
    Q_INVOKABLE int     getExtensionIntegratedDefaultPosition(QString id);
    Q_INVOKABLE int     getExtensionIntegratedDefaultDistanceFromEdge(QString id);
    Q_INVOKABLE QSize   getExtensionIntegratedDefaultSize(QString id);
    Q_INVOKABLE bool    getExtensionIntegratedFixSizeToContent(QString id);

    Q_INVOKABLE QSize   getExtensionPopoutDefaultSize(QString id);
    Q_INVOKABLE bool    getExtensionPopoutAllow(QString id);
    Q_INVOKABLE bool    getExtensionPopoutFixSizeToContent(QString id);

    Q_INVOKABLE bool    getExtensionModal(QString id);

    Q_INVOKABLE QString getExtensionDefaultShortcut(QString id);
    Q_INVOKABLE bool    getExtensionRememberGeometry(QString id);
    Q_INVOKABLE bool    getExtensionLetMeHandleMouseEvents(QString id);
    Q_INVOKABLE bool    getExtensionHasCPPActions(QString id);
    Q_INVOKABLE QList<QStringList> getExtensionSettings(QString id);

    // called when setup is supposed to start
    Q_INVOKABLE void setup();

    // get a list of all extension ids
    Q_INVOKABLE QStringList getExtensions();

    // get a list of all disabled extensions
    Q_INVOKABLE QStringList getDisabledExtensions();

    // get a list of all extensions ids, enabled AND disabled
    Q_INVOKABLE QStringList getExtensionsEnabledAndDisabld();

    // get the base dir of the extension
    Q_INVOKABLE QString getExtensionLocation(QString id);
    Q_INVOKABLE QString getExtensionConfigLocation(QString id);
    Q_INVOKABLE QString getExtensionDataLocation(QString id);
    Q_INVOKABLE QString getExtensionCacheLocation(QString id);

    // check whether an extension comes with a settings widget
    Q_INVOKABLE bool getHasSettings(const QString &id);

    // get the respective extension (if any) for a given shortcut
    Q_INVOKABLE QString getExtensionForShortcut(QString sh);
    Q_INVOKABLE QString getShortcutForExtension(QString id);
    Q_INVOKABLE void addShortcut(QString id, QString sh);
    Q_INVOKABLE void removeShortcut(QString id);

    /****************************/

    // these are predominantly used by the settings manager
    Q_INVOKABLE void setEnabledExtensions(QStringList ids);
    Q_INVOKABLE void setDisabledExtensions(QStringList ids);
    Q_INVOKABLE int installExtension(QString filepath);

private:
    PQCExtensionsHandler();

    QMap<QString, PQCExtensionInfo*> m_allextensions;

    // these are processed ones and then cached as they are needed often
    QStringList m_extensions;
    QStringList m_extensionsDisabled;

    QMap<QString, PQCExtensionActions*> m_actions;

    QMap<QString, QString> m_activeShortcutToExtension;
    QMap<QString, QString> m_extensionToActiveShortcut;

    QString previousCurrentFile;

    int m_numExtensions;

    void loadSettingsInBGToLookForShortcuts();

    QHash<QString, QVariant> getExtensionZipMetadata(QString filepath);

    QStringList listFilesIn(QString dir);

Q_SIGNALS:
    Q_INVOKABLE void requestResetGeometry(QString id);

    void replyForActionWithImage(const QString id, QVariant val);
    void replyForAction(const QString id, QVariant val);
    void receivedMessage(const QString id, QVariant val);

    void numExtensionsChanged();

    void receivedShortcut(QString combo);

};

#endif
