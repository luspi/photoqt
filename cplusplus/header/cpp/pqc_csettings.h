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
#pragma once

#include <shared/pqc_configfiles.h>

#include <QObject>
#include <QFile>
#include <QMessageBox>
#include <QApplication>
#include <QSqlQuery>
#include <QSqlError>

/********************************************************************************/
// NOTE: This is a duplication of some settings from the settings engine.
//       This is intended to be used as read-only interface for C++ code.
//       The values are automatically duplicated from the main settings engine.
/********************************************************************************/

class PQCCSettings : public QObject {

    Q_OBJECT

public:
    static PQCCSettings& get() {
        static PQCCSettings instance;
        return instance;
    }

    PQCCSettings(PQCCSettings const&) = delete;
    void operator=(PQCCSettings const&) = delete;

    void forceInterfaceVariant(QString var) { m_generalInterfaceVariant = var; }

    QVariant getExtensionValue(const QString &key) { return m_extensions.value(key, ""); }
    QVariant getExtensionDefaultValue(const QString &key) { return m_extensions_defaults.value(key, ""); }

    bool getFiledialogDevicesShowTmpfs() { return m_filedialogDevicesShowTmpfs; }
    bool getFiledialogShowHiddenFilesFolders() { return m_filedialogShowHiddenFilesFolders; }
    bool getFiletypesArchiveAlwaysEnterAutomatically() { return m_filetypesArchiveAlwaysEnterAutomatically; }
    bool getFiletypesComicBookAlwaysEnterAutomatically() { return m_filetypesComicBookAlwaysEnterAutomatically; }
    bool getFiletypesDocumentAlwaysEnterAutomatically() { return m_filetypesDocumentAlwaysEnterAutomatically; }
    bool getFiletypesExternalUnrar() { return m_filetypesExternalUnrar; }
    bool getFiletypesLoadAppleLivePhotos() { return m_filetypesLoadAppleLivePhotos; }
    bool getFiletypesLoadMotionPhotos() { return m_filetypesLoadMotionPhotos; }
    int getFiletypesPDFQuality() { return m_filetypesPDFQuality; }
    bool getFiletypesRAWUseEmbeddedIfAvailable() { return m_filetypesRAWUseEmbeddedIfAvailable; }
    bool getFiletypesVideoPreferLibmpv() { return m_filetypesVideoPreferLibmpv; }
    QString getFiletypesVideoThumbnailer() { return m_filetypesVideoThumbnailer; }
    QStringList getGeneralEnabledExtensions() { return m_generalEnabledExtensions; }
    QString getGeneralInterfaceVariant() { return m_generalInterfaceVariant; }
    bool getImageviewAdvancedSortAscending() { return m_imageviewAdvancedSortAscending; }
    QString getImageviewAdvancedSortCriteria() { return m_imageviewAdvancedSortCriteria; }
    QStringList getImageviewAdvancedSortDateCriteria() { return m_imageviewAdvancedSortDateCriteria; }
    QString getImageviewAdvancedSortQuality() { return m_imageviewAdvancedSortQuality; }
    int getImageviewCache() { return m_imageviewCache; }
    QString getImageviewColorSpaceDefault() { return m_imageviewColorSpaceDefault; }
    bool getImageviewColorSpaceEnable() { return m_imageviewColorSpaceEnable; }
    bool getImageviewColorSpaceLoadEmbedded() { return m_imageviewColorSpaceLoadEmbedded; }
    bool getImageviewFitInWindow() { return m_imageviewFitInWindow; }
    bool getImageviewRespectDevicePixelRatio() { return m_imageviewRespectDevicePixelRatio; }
    bool getImageviewSortImagesAscending() { return m_imageviewSortImagesAscending; }
    QString getImageviewSortImagesBy() { return m_imageviewSortImagesBy; }
    QString getInterfaceAccentColor() { return m_interfaceAccentColor; }
    int getInterfaceFontBoldWeight() { return m_interfaceFontBoldWeight; }
    int getInterfaceFontNormalWeight() { return m_interfaceFontNormalWeight; }
    QString getInterfaceLanguage() { return m_interfaceLanguage; }
    bool getInterfacePopoutWhenWindowIsSmall() { return m_interfacePopoutWhenWindowIsSmall; }
    bool getMetadataAutoRotation() { return m_metadataAutoRotation; }
    bool getThumbnailsCache() { return m_thumbnailsCache; }
    bool getThumbnailsCacheBaseDirDefault() { return m_thumbnailsCacheBaseDirDefault; }
    QString getThumbnailsCacheBaseDirLocation() { return m_thumbnailsCacheBaseDirLocation; }
    QString getThumbnailsExcludeDropBox() { return m_thumbnailsExcludeDropBox; }
    QStringList getThumbnailsExcludeFolders() { return m_thumbnailsExcludeFolders; }
    bool getThumbnailsExcludeNetworkShares() { return m_thumbnailsExcludeNetworkShares; }
    QString getThumbnailsExcludeNextcloud() { return m_thumbnailsExcludeNextcloud; }
    QString getThumbnailsExcludeOwnCloud() { return m_thumbnailsExcludeOwnCloud; }
    bool getThumbnailsIconsOnly() { return m_thumbnailsIconsOnly; }
    int getThumbnailsMaxNumberThreads() { return m_thumbnailsMaxNumberThreads; }

    void readDB() {

        QSqlDatabase db = QSqlDatabase::database("settings");

        if(!db.open()) {
            qCritical() << "ERROR: Unable to open settings database. This should never happen...";
            return;
        }

        const QStringList dbtables = {"general",
                                      "interface",
                                      "imageview",
                                      "thumbnails",
                                      "metadata",
                                      "filetypes",
                                      "filedialog"};

        for(const QString &table : dbtables) {

            QSqlQuery query(db);
            query.prepare(QString("SELECT `name`,`value`,`datatype` FROM '%1'").arg(table));
            if(!query.exec()) {
                qWarning() << "ERROR: Getting data for table" << table << "failed:" << query.lastError().text();
                continue;
            }

            while(query.next()) {

                QString name = query.value(0).toString();
                QVariant value = query.value(1).toString();
            
                if(table == "filedialog" && name == "DevicesShowTmpfs") {
                    const bool val = value.toInt();
                    if(m_filedialogDevicesShowTmpfs != val) {
                        m_filedialogDevicesShowTmpfs = value.toInt();
                        Q_EMIT filedialogDevicesShowTmpfsChanged();
                    }
                } else if(table == "filedialog" && name == "ShowHiddenFilesFolders") {
                    const bool val = value.toInt();
                    if(m_filedialogShowHiddenFilesFolders != val) {
                        m_filedialogShowHiddenFilesFolders = value.toInt();
                        Q_EMIT filedialogShowHiddenFilesFoldersChanged();
                    }
                } else if(table == "filetypes" && name == "ArchiveAlwaysEnterAutomatically") {
                    const bool val = value.toInt();
                    if(m_filetypesArchiveAlwaysEnterAutomatically != val) {
                        m_filetypesArchiveAlwaysEnterAutomatically = value.toInt();
                        Q_EMIT filetypesArchiveAlwaysEnterAutomaticallyChanged();
                    }
                } else if(table == "filetypes" && name == "ComicBookAlwaysEnterAutomatically") {
                    const bool val = value.toInt();
                    if(m_filetypesComicBookAlwaysEnterAutomatically != val) {
                        m_filetypesComicBookAlwaysEnterAutomatically = value.toInt();
                        Q_EMIT filetypesComicBookAlwaysEnterAutomaticallyChanged();
                    }
                } else if(table == "filetypes" && name == "DocumentAlwaysEnterAutomatically") {
                    const bool val = value.toInt();
                    if(m_filetypesDocumentAlwaysEnterAutomatically != val) {
                        m_filetypesDocumentAlwaysEnterAutomatically = value.toInt();
                        Q_EMIT filetypesDocumentAlwaysEnterAutomaticallyChanged();
                    }
                } else if(table == "filetypes" && name == "ExternalUnrar") {
                    const bool val = value.toInt();
                    if(m_filetypesExternalUnrar != val) {
                        m_filetypesExternalUnrar = value.toInt();
                        Q_EMIT filetypesExternalUnrarChanged();
                    }
                } else if(table == "filetypes" && name == "LoadAppleLivePhotos") {
                    const bool val = value.toInt();
                    if(m_filetypesLoadAppleLivePhotos != val) {
                        m_filetypesLoadAppleLivePhotos = value.toInt();
                        Q_EMIT filetypesLoadAppleLivePhotosChanged();
                    }
                } else if(table == "filetypes" && name == "LoadMotionPhotos") {
                    const bool val = value.toInt();
                    if(m_filetypesLoadMotionPhotos != val) {
                        m_filetypesLoadMotionPhotos = value.toInt();
                        Q_EMIT filetypesLoadMotionPhotosChanged();
                    }
                } else if(table == "filetypes" && name == "PDFQuality") {
                    const int val = value.toInt();
                    if(m_filetypesPDFQuality != val) {
                        m_filetypesPDFQuality = value.toInt();
                        Q_EMIT filetypesPDFQualityChanged();
                    }
                } else if(table == "filetypes" && name == "RAWUseEmbeddedIfAvailable") {
                    const bool val = value.toInt();
                    if(m_filetypesRAWUseEmbeddedIfAvailable != val) {
                        m_filetypesRAWUseEmbeddedIfAvailable = value.toInt();
                        Q_EMIT filetypesRAWUseEmbeddedIfAvailableChanged();
                    }
                } else if(table == "filetypes" && name == "VideoPreferLibmpv") {
                    const bool val = value.toInt();
                    if(m_filetypesVideoPreferLibmpv != val) {
                        m_filetypesVideoPreferLibmpv = value.toInt();
                        Q_EMIT filetypesVideoPreferLibmpvChanged();
                    }
                } else if(table == "filetypes" && name == "VideoThumbnailer") {
                    const QString val = value.toString();
                    if(m_filetypesVideoThumbnailer != val) {
                        m_filetypesVideoThumbnailer = val;
                        Q_EMIT filetypesVideoThumbnailerChanged();
                    }
                } else if(table == "general" && name == "EnabledExtensions") {
                    const QString val = value.toString();
                    QStringList valToSet = QStringList();
                    if(val.contains(":://::"))
                        valToSet = val.split(":://::");
                    else if(val != "")
                        valToSet = QStringList() << val;
                    if(m_generalEnabledExtensions != valToSet) {
                        m_generalEnabledExtensions = valToSet;
                        Q_EMIT generalEnabledExtensionsChanged();
                    }
                } else if(table == "general" && name == "InterfaceVariant") {
                    const QString val = value.toString();
                    if(m_generalInterfaceVariant != val) {
                        m_generalInterfaceVariant = val;
                        Q_EMIT generalInterfaceVariantChanged();
                    }
                } else if(table == "imageview" && name == "AdvancedSortAscending") {
                    const bool val = value.toInt();
                    if(m_imageviewAdvancedSortAscending != val) {
                        m_imageviewAdvancedSortAscending = value.toInt();
                        Q_EMIT imageviewAdvancedSortAscendingChanged();
                    }
                } else if(table == "imageview" && name == "AdvancedSortCriteria") {
                    const QString val = value.toString();
                    if(m_imageviewAdvancedSortCriteria != val) {
                        m_imageviewAdvancedSortCriteria = val;
                        Q_EMIT imageviewAdvancedSortCriteriaChanged();
                    }
                } else if(table == "imageview" && name == "AdvancedSortDateCriteria") {
                    const QString val = value.toString();
                    QStringList valToSet = QStringList();
                    if(val.contains(":://::"))
                        valToSet = val.split(":://::");
                    else if(val != "")
                        valToSet = QStringList() << val;
                    if(m_imageviewAdvancedSortDateCriteria != valToSet) {
                        m_imageviewAdvancedSortDateCriteria = valToSet;
                        Q_EMIT imageviewAdvancedSortDateCriteriaChanged();
                    }
                } else if(table == "imageview" && name == "AdvancedSortQuality") {
                    const QString val = value.toString();
                    if(m_imageviewAdvancedSortQuality != val) {
                        m_imageviewAdvancedSortQuality = val;
                        Q_EMIT imageviewAdvancedSortQualityChanged();
                    }
                } else if(table == "imageview" && name == "Cache") {
                    const int val = value.toInt();
                    if(m_imageviewCache != val) {
                        m_imageviewCache = value.toInt();
                        Q_EMIT imageviewCacheChanged();
                    }
                } else if(table == "imageview" && name == "ColorSpaceDefault") {
                    const QString val = value.toString();
                    if(m_imageviewColorSpaceDefault != val) {
                        m_imageviewColorSpaceDefault = val;
                        Q_EMIT imageviewColorSpaceDefaultChanged();
                    }
                } else if(table == "imageview" && name == "ColorSpaceEnable") {
                    const bool val = value.toInt();
                    if(m_imageviewColorSpaceEnable != val) {
                        m_imageviewColorSpaceEnable = value.toInt();
                        Q_EMIT imageviewColorSpaceEnableChanged();
                    }
                } else if(table == "imageview" && name == "ColorSpaceLoadEmbedded") {
                    const bool val = value.toInt();
                    if(m_imageviewColorSpaceLoadEmbedded != val) {
                        m_imageviewColorSpaceLoadEmbedded = value.toInt();
                        Q_EMIT imageviewColorSpaceLoadEmbeddedChanged();
                    }
                } else if(table == "imageview" && name == "FitInWindow") {
                    const bool val = value.toInt();
                    if(m_imageviewFitInWindow != val) {
                        m_imageviewFitInWindow = value.toInt();
                        Q_EMIT imageviewFitInWindowChanged();
                    }
                } else if(table == "imageview" && name == "RespectDevicePixelRatio") {
                    const bool val = value.toInt();
                    if(m_imageviewRespectDevicePixelRatio != val) {
                        m_imageviewRespectDevicePixelRatio = value.toInt();
                        Q_EMIT imageviewRespectDevicePixelRatioChanged();
                    }
                } else if(table == "imageview" && name == "SortImagesAscending") {
                    const bool val = value.toInt();
                    if(m_imageviewSortImagesAscending != val) {
                        m_imageviewSortImagesAscending = value.toInt();
                        Q_EMIT imageviewSortImagesAscendingChanged();
                    }
                } else if(table == "imageview" && name == "SortImagesBy") {
                    const QString val = value.toString();
                    if(m_imageviewSortImagesBy != val) {
                        m_imageviewSortImagesBy = val;
                        Q_EMIT imageviewSortImagesByChanged();
                    }
                } else if(table == "interface" && name == "AccentColor") {
                    const QString val = value.toString();
                    if(m_interfaceAccentColor != val) {
                        m_interfaceAccentColor = val;
                        Q_EMIT interfaceAccentColorChanged();
                    }
                } else if(table == "interface" && name == "FontBoldWeight") {
                    const int val = value.toInt();
                    if(m_interfaceFontBoldWeight != val) {
                        m_interfaceFontBoldWeight = value.toInt();
                        Q_EMIT interfaceFontBoldWeightChanged();
                    }
                } else if(table == "interface" && name == "FontNormalWeight") {
                    const int val = value.toInt();
                    if(m_interfaceFontNormalWeight != val) {
                        m_interfaceFontNormalWeight = value.toInt();
                        Q_EMIT interfaceFontNormalWeightChanged();
                    }
                } else if(table == "interface" && name == "Language") {
                    const QString val = value.toString();
                    if(m_interfaceLanguage != val) {
                        m_interfaceLanguage = val;
                        Q_EMIT interfaceLanguageChanged();
                    }
                } else if(table == "interface" && name == "PopoutWhenWindowIsSmall") {
                    const bool val = value.toInt();
                    if(m_interfacePopoutWhenWindowIsSmall != val) {
                        m_interfacePopoutWhenWindowIsSmall = value.toInt();
                        Q_EMIT interfacePopoutWhenWindowIsSmallChanged();
                    }
                } else if(table == "metadata" && name == "AutoRotation") {
                    const bool val = value.toInt();
                    if(m_metadataAutoRotation != val) {
                        m_metadataAutoRotation = value.toInt();
                        Q_EMIT metadataAutoRotationChanged();
                    }
                } else if(table == "thumbnails" && name == "Cache") {
                    const bool val = value.toInt();
                    if(m_thumbnailsCache != val) {
                        m_thumbnailsCache = value.toInt();
                        Q_EMIT thumbnailsCacheChanged();
                    }
                } else if(table == "thumbnails" && name == "CacheBaseDirDefault") {
                    const bool val = value.toInt();
                    if(m_thumbnailsCacheBaseDirDefault != val) {
                        m_thumbnailsCacheBaseDirDefault = value.toInt();
                        Q_EMIT thumbnailsCacheBaseDirDefaultChanged();
                    }
                } else if(table == "thumbnails" && name == "CacheBaseDirLocation") {
                    const QString val = value.toString();
                    if(m_thumbnailsCacheBaseDirLocation != val) {
                        m_thumbnailsCacheBaseDirLocation = val;
                        Q_EMIT thumbnailsCacheBaseDirLocationChanged();
                    }
                } else if(table == "thumbnails" && name == "ExcludeDropBox") {
                    const QString val = value.toString();
                    if(m_thumbnailsExcludeDropBox != val) {
                        m_thumbnailsExcludeDropBox = val;
                        Q_EMIT thumbnailsExcludeDropBoxChanged();
                    }
                } else if(table == "thumbnails" && name == "ExcludeFolders") {
                    const QString val = value.toString();
                    QStringList valToSet = QStringList();
                    if(val.contains(":://::"))
                        valToSet = val.split(":://::");
                    else if(val != "")
                        valToSet = QStringList() << val;
                    if(m_thumbnailsExcludeFolders != valToSet) {
                        m_thumbnailsExcludeFolders = valToSet;
                        Q_EMIT thumbnailsExcludeFoldersChanged();
                    }
                } else if(table == "thumbnails" && name == "ExcludeNetworkShares") {
                    const bool val = value.toInt();
                    if(m_thumbnailsExcludeNetworkShares != val) {
                        m_thumbnailsExcludeNetworkShares = value.toInt();
                        Q_EMIT thumbnailsExcludeNetworkSharesChanged();
                    }
                } else if(table == "thumbnails" && name == "ExcludeNextcloud") {
                    const QString val = value.toString();
                    if(m_thumbnailsExcludeNextcloud != val) {
                        m_thumbnailsExcludeNextcloud = val;
                        Q_EMIT thumbnailsExcludeNextcloudChanged();
                    }
                } else if(table == "thumbnails" && name == "ExcludeOwnCloud") {
                    const QString val = value.toString();
                    if(m_thumbnailsExcludeOwnCloud != val) {
                        m_thumbnailsExcludeOwnCloud = val;
                        Q_EMIT thumbnailsExcludeOwnCloudChanged();
                    }
                } else if(table == "thumbnails" && name == "IconsOnly") {
                    const bool val = value.toInt();
                    if(m_thumbnailsIconsOnly != val) {
                        m_thumbnailsIconsOnly = value.toInt();
                        Q_EMIT thumbnailsIconsOnlyChanged();
                    }
                } else if(table == "thumbnails" && name == "MaxNumberThreads") {
                    const int val = value.toInt();
                    if(m_thumbnailsMaxNumberThreads != val) {
                        m_thumbnailsMaxNumberThreads = value.toInt();
                        Q_EMIT thumbnailsMaxNumberThreadsChanged();
                    }
                }
            }

        }

    }

private:
    PQCCSettings(QObject *parent = nullptr) : QObject(parent) {

        m_filedialogDevicesShowTmpfs = false;
        m_filedialogShowHiddenFilesFolders = false;
        m_filetypesArchiveAlwaysEnterAutomatically = false;
        m_filetypesComicBookAlwaysEnterAutomatically = false;
        m_filetypesDocumentAlwaysEnterAutomatically = false;
        m_filetypesExternalUnrar = false;
        m_filetypesLoadAppleLivePhotos = true;
        m_filetypesLoadMotionPhotos = true;
        m_filetypesPDFQuality = 150;
        m_filetypesRAWUseEmbeddedIfAvailable = true;
        m_filetypesVideoPreferLibmpv = true;
        m_filetypesVideoThumbnailer = "ffmpegthumbnailer";
        m_generalEnabledExtensions = QStringList();
        m_generalInterfaceVariant = "modern";
        m_imageviewAdvancedSortAscending = true;
        m_imageviewAdvancedSortCriteria = "resolution";
        m_imageviewAdvancedSortDateCriteria = QStringList() << "exiforiginal" << "exifdigital" << "filecreation" << "filemodification";
        m_imageviewAdvancedSortQuality = "medium";
        m_imageviewCache = 512;
        m_imageviewColorSpaceDefault = "";
        m_imageviewColorSpaceEnable = true;
        m_imageviewColorSpaceLoadEmbedded = true;
        m_imageviewFitInWindow = false;
        m_imageviewRespectDevicePixelRatio = true;
        m_imageviewSortImagesAscending = true;
        m_imageviewSortImagesBy = "naturalname";
        m_interfaceAccentColor = "#222222";
        m_interfaceFontBoldWeight = 700;
        m_interfaceFontNormalWeight = 400;
        m_interfaceLanguage = "en";
        m_interfacePopoutWhenWindowIsSmall = true;
        m_metadataAutoRotation = true;
        m_thumbnailsCache = true;
        m_thumbnailsCacheBaseDirDefault = true;
        m_thumbnailsCacheBaseDirLocation = "";
        m_thumbnailsExcludeDropBox = "";
        m_thumbnailsExcludeFolders = QStringList();
        m_thumbnailsExcludeNetworkShares = true;
        m_thumbnailsExcludeNextcloud = "";
        m_thumbnailsExcludeOwnCloud = "";
        m_thumbnailsIconsOnly = false;
        m_thumbnailsMaxNumberThreads = 4;

        readDB();

    }

    ~PQCCSettings() {}

    QVariantHash m_extensions;
    QVariantHash m_extensions_defaults;

    bool m_filedialogDevicesShowTmpfs;
    bool m_filedialogShowHiddenFilesFolders;
    bool m_filetypesArchiveAlwaysEnterAutomatically;
    bool m_filetypesComicBookAlwaysEnterAutomatically;
    bool m_filetypesDocumentAlwaysEnterAutomatically;
    bool m_filetypesExternalUnrar;
    bool m_filetypesLoadAppleLivePhotos;
    bool m_filetypesLoadMotionPhotos;
    int m_filetypesPDFQuality;
    bool m_filetypesRAWUseEmbeddedIfAvailable;
    bool m_filetypesVideoPreferLibmpv;
    QString m_filetypesVideoThumbnailer;
    QStringList m_generalEnabledExtensions;
    QString m_generalInterfaceVariant;
    bool m_imageviewAdvancedSortAscending;
    QString m_imageviewAdvancedSortCriteria;
    QStringList m_imageviewAdvancedSortDateCriteria;
    QString m_imageviewAdvancedSortQuality;
    int m_imageviewCache;
    QString m_imageviewColorSpaceDefault;
    bool m_imageviewColorSpaceEnable;
    bool m_imageviewColorSpaceLoadEmbedded;
    bool m_imageviewFitInWindow;
    bool m_imageviewRespectDevicePixelRatio;
    bool m_imageviewSortImagesAscending;
    QString m_imageviewSortImagesBy;
    QString m_interfaceAccentColor;
    int m_interfaceFontBoldWeight;
    int m_interfaceFontNormalWeight;
    QString m_interfaceLanguage;
    bool m_interfacePopoutWhenWindowIsSmall;
    bool m_metadataAutoRotation;
    bool m_thumbnailsCache;
    bool m_thumbnailsCacheBaseDirDefault;
    QString m_thumbnailsCacheBaseDirLocation;
    QString m_thumbnailsExcludeDropBox;
    QStringList m_thumbnailsExcludeFolders;
    bool m_thumbnailsExcludeNetworkShares;
    QString m_thumbnailsExcludeNextcloud;
    QString m_thumbnailsExcludeOwnCloud;
    bool m_thumbnailsIconsOnly;
    int m_thumbnailsMaxNumberThreads;

Q_SIGNALS:
    void extensionsChanged();
    void generalEnabledExtensionsChanged();
    void generalInterfaceVariantChanged();
    void imageviewFitInWindowChanged();
    void imageviewSortImagesAscendingChanged();
    void imageviewSortImagesByChanged();
    void imageviewCacheChanged();
    void imageviewColorSpaceEnableChanged();
    void imageviewColorSpaceLoadEmbeddedChanged();
    void imageviewColorSpaceDefaultChanged();
    void imageviewAdvancedSortCriteriaChanged();
    void imageviewAdvancedSortAscendingChanged();
    void imageviewAdvancedSortQualityChanged();
    void imageviewAdvancedSortDateCriteriaChanged();
    void imageviewRespectDevicePixelRatioChanged();
    void filedialogDevicesShowTmpfsChanged();
    void filedialogShowHiddenFilesFoldersChanged();
    void filetypesLoadAppleLivePhotosChanged();
    void filetypesLoadMotionPhotosChanged();
    void filetypesExternalUnrarChanged();
    void filetypesVideoThumbnailerChanged();
    void filetypesRAWUseEmbeddedIfAvailableChanged();
    void filetypesPDFQualityChanged();
    void filetypesVideoPreferLibmpvChanged();
    void filetypesArchiveAlwaysEnterAutomaticallyChanged();
    void filetypesComicBookAlwaysEnterAutomaticallyChanged();
    void filetypesDocumentAlwaysEnterAutomaticallyChanged();
    void interfaceAccentColorChanged();
    void interfaceFontNormalWeightChanged();
    void interfaceFontBoldWeightChanged();
    void interfacePopoutWhenWindowIsSmallChanged();
    void interfaceLanguageChanged();
    void thumbnailsExcludeDropBoxChanged();
    void thumbnailsExcludeNextcloudChanged();
    void thumbnailsExcludeOwnCloudChanged();
    void thumbnailsExcludeFoldersChanged();
    void thumbnailsExcludeNetworkSharesChanged();
    void thumbnailsCacheBaseDirDefaultChanged();
    void thumbnailsCacheBaseDirLocationChanged();
    void thumbnailsMaxNumberThreadsChanged();
    void thumbnailsCacheChanged();
    void thumbnailsIconsOnlyChanged();
    void metadataAutoRotationChanged();

};
