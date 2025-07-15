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

class PQCExtensionInfo {
public:

    PQCExtensionInfo() {

        // required user provided
        version = 0;
        name = "";
        description = "";
        author = "";
        contact = "";
        targetAPI = 0;
        defaultShortcut = "";

        // optional user provided
        minimumRequiredWindowSize = QSize(0,0);
        isModal = false;
        allowIntegrated = true;
        allowPopout = true;
        positionAt = DefaultPosition::TopLeft;
        rememberGeometry = true;
        fixSizeToContent = false;
        letMeHandleMouseEvents = false;
        shortcuts = {};
        settings = {};
        haveCPPActions = false;

        // auto generated
        location = "";
    }

    enum DefaultPosition {
        TopLeft = 0,
        Top,
        TopRight,
        Left,
        Center,
        Right,
        BottomLeft,
        Bottom,
        BottomRight
    };

    int version;
    QString name;
    QString description;
    QString author;
    QString contact;
    int targetAPI;
    QString defaultShortcut;

    QSize minimumRequiredWindowSize;
    bool isModal;
    bool allowIntegrated;
    bool allowPopout;
    DefaultPosition positionAt;
    bool rememberGeometry;
    bool fixSizeToContent;
    bool letMeHandleMouseEvents;
    QList<QStringList> shortcuts;
    QList<QStringList> settings;
    bool haveCPPActions;

    QString location;

    DefaultPosition getEnumForPosition(std::string val) {
        if(val == "TopLeft")
            return DefaultPosition::TopLeft;
        else if(val == "Top")
            return DefaultPosition::Top;
        else if(val == "TopRight")
            return DefaultPosition::TopRight;
        else if(val == "Left")
            return DefaultPosition::Left;
        else if(val == "Center")
            return DefaultPosition::Center;
        else if(val == "Right")
            return DefaultPosition::Right;
        else if(val == "Bottom")
            return DefaultPosition::BottomLeft;
        else if(val == "Bottom")
            return DefaultPosition::Bottom;
        else if(val == "Bottom")
            return DefaultPosition::BottomRight;
        else {
            qWarning() << "Invalid enum value found:" << val;
            return DefaultPosition::TopLeft;
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

    // REQUEST CUSTOM ACTIONS TO BE TAKEN
    Q_INVOKABLE void requestCallActionWithImage1(const QString &id, QVariant additional = QVariant());
    Q_INVOKABLE void requestCallActionWithImage2(const QString &id, QVariant additional = QVariant());
    Q_INVOKABLE void requestCallAction1(const QString &id, QVariant additional = QVariant());
    Q_INVOKABLE void requestCallAction2(const QString &id, QVariant additional = QVariant());

    // REQUEST SPECIAL ACTIONS
    Q_INVOKABLE void requestExecutionOfInternalShortcut(const QString &cmd);
    Q_INVOKABLE void requestShowingOf(const QString &id);

    // GLOBAL PROPERTIES
    Q_PROPERTY(int numFiles MEMBER m_numFiles NOTIFY numFilesChanged)
    Q_PROPERTY(QString currentFile MEMBER m_currentFile NOTIFY currentFileChanged)
    Q_PROPERTY(int currentIndex MEMBER m_currentIndex NOTIFY currentIndexChanged)

    // SOME SETTINGS STUFF
    Q_INVOKABLE bool getIsEnabled(const QString &id);
    Q_INVOKABLE bool getIsEnabledByDefault(const QString &id);

    /**********************************/

    // get some extensions properties
    Q_INVOKABLE int     getExtensionVersion(QString id);
    Q_INVOKABLE QString getExtensionName(QString id);
    Q_INVOKABLE QString getExtensionAuthor(QString id);
    Q_INVOKABLE QString getExtensionContact(QString id);
    Q_INVOKABLE QString getExtensionDescription(QString id);
    Q_INVOKABLE int     getExtensionTargetAPIVersion(QString id);

    Q_INVOKABLE QSize   getExtensionMinimumRequiredWindowSize(QString id);
    Q_INVOKABLE bool    getExtensionIsModal(QString id);
    Q_INVOKABLE bool    getExtensionAllowIntegrated(QString id);
    Q_INVOKABLE bool    getExtensionAllowPopout(QString id);
    Q_INVOKABLE PQCExtensionInfo::DefaultPosition getExtensionPositionAt(QString id);
    Q_INVOKABLE bool    getExtensionRememberGeometry(QString id);
    Q_INVOKABLE bool    getExtensionFixSizeToContent(QString id);
    Q_INVOKABLE bool    getExtensionLetMeHandleMouseEvents(QString id);

    Q_INVOKABLE QList<QStringList> getExtensionSettings(QString id);
    Q_INVOKABLE QStringList        getExtensionShortcuts(QString id);
    Q_INVOKABLE QList<QStringList> getExtensionShortcutsActions(QString id);

    Q_INVOKABLE bool getExtensionHasCPPActions(QString id);

    // some other generated properties to find
    Q_INVOKABLE QStringList getAllShortcuts();
    Q_INVOKABLE QString getDescriptionForShortcut(QString sh);
    Q_INVOKABLE QString getWhichExtensionForShortcut(QString sh);

    // called when setup is supposed to start
    Q_INVOKABLE void setup();

    // get a list of all extension ids
    Q_INVOKABLE QStringList getExtensions();

    // get a list of all disabled extensions
    Q_INVOKABLE QStringList getDisabledExtensions();

    // get the base dir of the extension
    Q_INVOKABLE QString getExtensionLocation(QString id);

    // check whether an extension comes with C++ actions
    Q_INVOKABLE bool getHasActions(const QString &id);

    // check whether an extension comes with a settings widget
    Q_INVOKABLE bool getHasSettings(const QString &id);

    // how many extensions are enabled for which we need to be ready for
    Q_PROPERTY(int numExtensions MEMBER m_numExtensions NOTIFY numExtensionsChanged)

private:
    PQCExtensionsHandler();

    int m_numFiles;
    int m_currentIndex;
    QString m_currentFile;

    QMap<QString, PQCExtensionInfo*> m_allextensions;

    // these are processed ones and then cached as they are needed often
    QStringList m_extensions;
    QStringList m_extensionsDisabled;

    QMap<QString, QStringList> m_shortcuts;
    QStringList m_simpleListAllShortcuts;
    QMap<QString,QString> m_mapShortcutToExtension;

    QMap<QString, PQCExtensionActions*> m_actions;

    QString previousCurrentFile;

    int m_numExtensions;

Q_SIGNALS:
    void numFilesChanged();
    void currentIndexChanged();
    void currentFileChanged();
    void currentImageDisplayed();

    Q_INVOKABLE void requestResetGeometry(QString id);

    void replyForActionWithImage1(const QString id, QVariant val);
    void replyForActionWithImage2(const QString id, QVariant val);
    void replyForAction1(const QString id, QVariant val);
    void replyForAction2(const QString id, QVariant val);

    void numExtensionsChanged();

};

#endif
