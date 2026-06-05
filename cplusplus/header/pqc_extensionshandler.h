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

    Q_PROPERTY(int numExtensionsEnabled READ getNumExtensionsEnabled WRITE setNumExtensionsEnabled NOTIFY numExtensionsEnabledChanged)
    Q_PROPERTY(int numExtensionsAll READ getNumExtensionsAll WRITE setNumExtensionsAll NOTIFY numExtensionsAllChanged)
    Q_PROPERTY(int numExtensionsFailed READ getNumExtensionsFailed WRITE setNumExtensionsFailed NOTIFY numExtensionsFailedChanged)

    int getNumExtensionsEnabled() { return m_numExtensionsEnabled; }
    void setNumExtensionsEnabled(const int val) {
        if(val == m_numExtensionsEnabled)
            return;
        m_numExtensionsEnabled = val;
        Q_EMIT numExtensionsEnabledChanged();
    }
    int getNumExtensionsAll() { return m_numExtensionsAll; }
    void setNumExtensionsAll(const int val) {
        if(val == m_numExtensionsAll)
            return;
        m_numExtensionsAll = val;
        Q_EMIT numExtensionsAllChanged();
    }
    int getNumExtensionsFailed() { return m_numExtensionsFailed; }
    void setNumExtensionsFailed(const int val) {
        if(val == m_numExtensionsFailed)
            return;
        m_numExtensionsFailed = val;
        Q_EMIT numExtensionsFailedChanged();
    }

    // properties regarding which context menu to add an extension to
    Q_PROPERTY(QStringList contextMenuUse READ getContextMenuUse WRITE setContextMenuUse NOTIFY contextMenuUseChanged)
    Q_PROPERTY(QStringList contextMenuManipulate READ getContextMenuManipulate WRITE setContextMenuManipulate NOTIFY contextMenuManipulateChanged)
    Q_PROPERTY(QStringList contextMenuAbout READ getContextMenuAbout WRITE setContextMenuAbout NOTIFY contextMenuAboutChanged)
    Q_PROPERTY(QStringList contextMenuOther READ getContextMenuOther WRITE setContextMenuOther NOTIFY contextMenuOtherChanged)
    Q_PROPERTY(QStringList mainmenu READ getMainmenu WRITE setMainmenu NOTIFY mainmenuChanged);

    QStringList getContextMenuUse() { return m_contextMenuUse; }
    void setContextMenuUse(const QStringList val) {
        if(val == m_contextMenuUse)
            return;
        m_contextMenuUse = val;
        Q_EMIT contextMenuUseChanged();
    }
    QStringList getContextMenuManipulate() { return m_contextMenuManipulate; }
    void setContextMenuManipulate(const QStringList val) {
        if(val == m_contextMenuManipulate)
            return;
        m_contextMenuManipulate = val;
        Q_EMIT contextMenuManipulateChanged();
    }
    QStringList getContextMenuAbout() { return m_contextMenuAbout; }
    void setContextMenuAbout(const QStringList val) {
        if(val == m_contextMenuAbout)
            return;
        m_contextMenuAbout = val;
        Q_EMIT contextMenuAboutChanged();
    }
    QStringList getContextMenuOther() { return m_contextMenuOther; }
    void setContextMenuOther(const QStringList val) {
        if(val == m_contextMenuOther)
            return;
        m_contextMenuOther = val;
        Q_EMIT contextMenuOtherChanged();
    }
    QStringList getMainmenu() { return m_mainmenu; }
    void setMainmenu(const QStringList val) {
        if(val == m_mainmenu)
            return;
        m_mainmenu = val;
        Q_EMIT mainmenuChanged();
    }

    // get some extensions properties
    int     getExtensionVersion(QString id);
    QString getExtensionName(QString id);
    QString getExtensionLongName(QString id);
    QString getExtensionAuthor(QString id);
    QString getExtensionContact(QString id);
    QString getExtensionDescription(QString id);
    QString getExtensionWebsite(QString id);
    int     getExtensionTargetAPIVersion(QString id);

    QString getExtensionNameId(QString id);

    bool    getExtensionIntegratedAllow(QString id);
    QSize   getExtensionIntegratedMinimumRequiredWindowSize(QString id);
    int     getExtensionIntegratedDefaultPosition(QString id);
    int     getExtensionIntegratedDefaultDistanceFromEdge(QString id);
    QSize   getExtensionIntegratedDefaultSize(QString id);
    bool    getExtensionIntegratedFixSizeToContent(QString id);

    QSize   getExtensionPopoutDefaultSize(QString id);
    bool    getExtensionPopoutAllow(QString id);
    bool    getExtensionPopoutFixSizeToContent(QString id);

    bool    getExtensionFloating(QString id);
    bool    getExtensionModal(QString id);
    bool    getExtensionMainMenu(QString id);
    QString getExtensionDefaultShortcut(QString id);
    bool    getExtensionRememberGeometry(QString id);
    bool    getExtensionCustomMouseHandling(QString id);
    QString getExtensionContextMenuSection(QString id);
    bool    getExtensionHasCPPActions(QString id);
    QList<QStringList> getExtensionSettings(QString id);

    // get a list of all extension ids
    QStringList getExtensions();

    // get a list of all disabled extensions
    QStringList getDisabledExtensions();

    // get a list of all extensions that failed the verification and are not excluded
    QStringList getFailedExtensions();

    // get a list of all extensions ids, enabled AND disabled
    QStringList getExtensionsEnabledAndDisabld();

    // is this a system extensions (no need to verify)
    bool isSystemExtension(const QString id);

    // get the base dir of the extension
    QString getExtensionLocation(QString id);
    QString getExtensionConfigLocation(QString id);
    QString getExtensionDataLocation(QString id);
    QString getExtensionCacheLocation(QString id);

    // check whether an extension comes with a settings widget
    bool getHasSettings(const QString &id);

    // get the respective extension (if any) for a given shortcut
    QString getExtensionForShortcut(QString sh);
    QString getShortcutForExtension(QString id);
    void addShortcut(QString id, QString sh);
    void removeShortcut(QString id);

    /*************************************************************/
    // everything below is not to be used by any extension!

    // called when setup is supposed to start
    void setup();

    // these are predominantly used by the settings manager
    void setEnabledExtensions(const QStringList &ids);
    void setDisabledExtensions(const QStringList &ids);
    void enableExtension(const QString &id);
    void disableExtension(const QString &id);
    int installExtension(QString filepath);
    bool verifyExtension(QString extensionDir, QString nameId);

    bool loadExtension(std::shared_ptr<PQCExtensionInfo> &extinfo, QString nameId, QString hashId, QString extensionDir, QString manifestTxt, bool isEnabled);
    void setExtensionMainMenu(QString hashId, bool add);
    void setExtensionContextMenu(QString hashId, QString section, bool add);

private:
    PQCExtensionsHandler();

    QMap<QString, std::shared_ptr<PQCExtensionInfo> > m_allextensions;

    // these are processed ones and then cached as they are needed often
    QStringList m_extensions;
    QStringList m_extensionsDisabled;
    QStringList m_extensionsFailed;
    QStringList m_extensionsSystem;

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

    QHash<QString, std::shared_ptr<QTranslator> > extTrans;

    QStringList m_mainmenu;
    QStringList m_contextMenuUse;
    QStringList m_contextMenuManipulate;
    QStringList m_contextMenuAbout;
    QStringList m_contextMenuOther;

    QString m_systemExtensionDir;

    bool m_isSetup;

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
