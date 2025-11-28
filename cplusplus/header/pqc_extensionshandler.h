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
#include <pqc_notify_cpp.h>
#include <scripts/pqc_scriptsshortcuts.h>
#include <scripts/pqc_scriptsconfig.h>

class QTranslator;
class QTimer;
class PQCExtensionInfo;

class PQCExtensionsHandler : public QObject {

    Q_OBJECT

public:
    static PQCExtensionsHandler& get() {
        static PQCExtensionsHandler instance;
        return instance;
    }
    ~PQCExtensionsHandler();

    PQCExtensionsHandler(PQCExtensionsHandler const&) = delete;
    void operator=(PQCExtensionsHandler const&) = delete;

    /************************************************************************************/
    /************************************************************************************/
    //
    // THESE ARE NOT TO BE CALLED (DIRECTLY) BY EXTENSIONS!!!
    // Extension MUST use PQCExtensionMethod and PQCExtensionProperties
    //
    /************************************************************************************/
    /************************************************************************************/

    // these can be called from PQCExtensionMethods, but should not be called directly here!

    QVariant callAction(const QString &id, QVariant additional = QVariant());
    QVariant callActionWithImage(const QString &id, QVariant additional = QVariant());

    void callActionNonBlocking(const QString &id, QVariant additional = QVariant());
    void callActionWithImageNonBlocking(const QString &id, QVariant additional = QVariant());

    /************************************************/

    Q_PROPERTY(int numExtensionsEnabled MEMBER m_numExtensionsEnabled NOTIFY numExtensionsEnabledChanged)
    Q_PROPERTY(int numExtensionsAll MEMBER m_numExtensionsAll NOTIFY numExtensionsAllChanged)
    Q_PROPERTY(int numExtensionsFailed MEMBER m_numExtensionsFailed NOTIFY numExtensionsFailedChanged)

    // proeprties regarding which context menu to add an extension to
    Q_PROPERTY(QStringList contextMenuUse MEMBER m_contextMenuUse NOTIFY contextMenuUseChanged)
    Q_PROPERTY(QStringList contextMenuManipulate MEMBER m_contextMenuManipulate NOTIFY contextMenuManipulateChanged)
    Q_PROPERTY(QStringList contextMenuAbout MEMBER m_contextMenuAbout NOTIFY contextMenuAboutChanged)
    Q_PROPERTY(QStringList contextMenuOther MEMBER m_contextMenuOther NOTIFY contextMenuOtherChanged)
    Q_PROPERTY(QStringList mainmenu MEMBER m_mainmenu NOTIFY mainmenuChanged);

    // get some extensions properties
    Q_INVOKABLE int     getExtensionVersion(QString id);
    Q_INVOKABLE QString getExtensionName(QString id);
    Q_INVOKABLE QString getExtensionLongName(QString id);
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
    Q_INVOKABLE bool    getExtensionMainMenu(QString id);
    Q_INVOKABLE QString getExtensionDefaultShortcut(QString id);
    Q_INVOKABLE bool    getExtensionRememberGeometry(QString id);
    Q_INVOKABLE bool    getExtensionCustomMouseHandling(QString id);
    Q_INVOKABLE QString getExtensionContextMenuSection(QString id);
    Q_INVOKABLE bool    getExtensionHasCPPActions(QString id);
    Q_INVOKABLE QList<QStringList> getExtensionSettings(QString id);

    // get a list of all extension ids
    Q_INVOKABLE QStringList getExtensions();

    // get a list of all disabled extensions
    Q_INVOKABLE QStringList getDisabledExtensions();

    // get a list of all extensions that failed the verification and are not excluded
    Q_INVOKABLE QStringList getFailedExtensions();

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

    /*************************************************************/
    // everything below is not to be used by any extension!

    // called when setup is supposed to start
    Q_INVOKABLE void setup();

    // these are predominantly used by the settings manager
    Q_INVOKABLE void setEnabledExtensions(const QStringList &ids);
    Q_INVOKABLE void setDisabledExtensions(const QStringList &ids);
    Q_INVOKABLE void enableExtension(const QString &id);
    Q_INVOKABLE void disableExtension(const QString &id);
    Q_INVOKABLE int installExtension(QString filepath);
    Q_INVOKABLE bool verifyExtension(QString baseDir, QString id);

    bool loadExtension(PQCExtensionInfo *extinfo, QString id, QString baseDir, QString definition);

private:
    PQCExtensionsHandler();

    QMap<QString, PQCExtensionInfo*> m_allextensions;

    // these are processed ones and then cached as they are needed often
    QStringList m_extensions;
    QStringList m_extensionsDisabled;
    QStringList m_extensionsFailed;

    QMap<QString, PQCExtensionActions*> m_actions;

    QMap<QString, QString> m_activeShortcutToExtension;
    QMap<QString, QString> m_extensionToActiveShortcut;

    int m_numExtensionsEnabled;
    int m_numExtensionsAll;
    int m_numExtensionsFailed;
    QTimer *resetNumExtensionsAll;

    void loadSettingsInBGToLookForShortcuts();

    QHash<QString, QVariant> getExtensionZipMetadata(QString filepath);

    QStringList listFilesIn(QString dir);

    QHash<QString, QTranslator*> extTrans;

    QStringList m_mainmenu;
    QStringList m_contextMenuUse;
    QStringList m_contextMenuManipulate;
    QStringList m_contextMenuAbout;
    QStringList m_contextMenuOther;

private Q_SLOTS:
    void updateTranslationLanguage();

Q_SIGNALS:
    void numExtensionsEnabledChanged();
    void numExtensionsAllChanged();
    void numExtensionsFailedChanged();

    void mainmenuChanged();
    void contextMenuUseChanged();
    void contextMenuManipulateChanged();
    void contextMenuAboutChanged();
    void contextMenuOtherChanged();

    // THESE ARE PICKED UP IN PQCExtensionMethods
    void replyForActionWithImage(const QString id, QVariant val);
    void replyForAction(const QString id, QVariant val);
    void receivedMessage(const QString id, QVariant val);

    // THESE ARE CALLED FROM WITHIN PQCExtensionMethods
    void resetGeometry(QString id);




};

#endif
