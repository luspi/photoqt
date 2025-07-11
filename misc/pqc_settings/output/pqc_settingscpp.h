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

#ifndef PQCREADONLYSETTINGS_H
#define PQCREADONLYSETTINGS_H

#include <QObject>
#include <QtSql>
#include <QQmlPropertyMap>
#include <pqc_settings.h>

/********************************************************************************/
// NOTE: This is a duplication of some settings from the settings engine.
//       This is intended to be used as read-only interface for C++ code.
//       The values are automatically duplicated from the main settings engine.
/********************************************************************************/

class PQCSettingsCPP : public QObject {

    Q_OBJECT
    friend class PQCSettings;

public:
    static PQCSettingsCPP& get() {
        static PQCSettingsCPP instance;
        return instance;
    }

    PQCSettingsCPP(PQCSettingsCPP const&) = delete;
    void operator=(PQCSettingsCPP const&) = delete;

    QVariant getExtensionValue(const QString &key) { return m_extensions.value(key, ""); }
    QVariant getExtensionDefaultValue(const QString &key) { return m_extensions_defaults.value(key, ""); }

    QStringList getGeneralEnabledExtensions() { return m_generalEnabledExtensions; }

    bool getImageviewFitInWindow() { return m_imageviewFitInWindow; }
    bool getImageviewSortImagesAscending() { return m_imageviewSortImagesAscending; }
    QString getImageviewSortImagesBy() { return m_imageviewSortImagesBy; }
    int getImageviewCache() { return m_imageviewCache; }
    bool getImageviewColorSpaceEnable() { return m_imageviewColorSpaceEnable; }
    bool getImageviewColorSpaceLoadEmbedded() { return m_imageviewColorSpaceLoadEmbedded; }
    QString getImageviewColorSpaceDefault() { return m_imageviewColorSpaceDefault; }
    QString getImageviewAdvancedSortCriteria() { return m_imageviewAdvancedSortCriteria; }
    bool getImageviewAdvancedSortAscending() { return m_imageviewAdvancedSortAscending; }
    QString getImageviewAdvancedSortQuality() { return m_imageviewAdvancedSortQuality; }
    QStringList getImageviewAdvancedSortDateCriteria() { return m_imageviewAdvancedSortDateCriteria; }
    bool getImageviewRespectDevicePixelRatio() { return m_imageviewRespectDevicePixelRatio; }

    bool getFiledialogDevicesShowTmpfs() { return m_filedialogDevicesShowTmpfs; }
    bool getFiledialogShowHiddenFilesFolders() { return m_filedialogShowHiddenFilesFolders; }

    bool getFiletypesLoadAppleLivePhotos() { return m_filetypesLoadAppleLivePhotos; }
    bool getFiletypesLoadMotionPhotos() { return m_filetypesLoadMotionPhotos; }
    bool getFiletypesExternalUnrar() { return m_filetypesExternalUnrar; }
    QString getFiletypesVideoThumbnailer() { return m_filetypesVideoThumbnailer; }
    bool getFiletypesRAWUseEmbeddedIfAvailable() { return m_filetypesRAWUseEmbeddedIfAvailable; }
    double getFiletypesPDFQuality() { return m_filetypesPDFQuality; }
    bool getFiletypesVideoPreferLibmpv() { return m_filetypesVideoPreferLibmpv; }
    bool getFiletypesArchiveAlwaysEnterAutomatically() { return m_filetypesArchiveAlwaysEnterAutomatically; }
    bool getFiletypesComicBookAlwaysEnterAutomatically() { return m_filetypesComicBookAlwaysEnterAutomatically; }
    bool getFiletypesDocumentAlwaysEnterAutomatically() { return m_filetypesDocumentAlwaysEnterAutomatically; }

    QString getInterfaceAccentColor() { return m_interfaceAccentColor; }
    int getInterfaceFontNormalWeight() { return m_interfaceFontNormalWeight; }
    int getInterfaceFontBoldWeight() { return m_interfaceFontBoldWeight; }
    bool getInterfacePopoutWhenWindowIsSmall() { return m_interfacePopoutWhenWindowIsSmall; }
    QString getInterfaceLanguage() { return m_interfaceLanguage; }

    QString getThumbnailsExcludeDropBox() { return m_thumbnailsExcludeDropBox; }
    QString getThumbnailsExcludeNextcloud() { return m_thumbnailsExcludeNextcloud; }
    QString getThumbnailsExcludeOwnCloud() { return m_thumbnailsExcludeOwnCloud; }
    QStringList getThumbnailsExcludeFolders() { return m_thumbnailsExcludeFolders; }
    bool getThumbnailsExcludeNetworkShares() { return m_thumbnailsExcludeNetworkShares; }
    bool getThumbnailsCacheBaseDirDefault() { return m_thumbnailsCacheBaseDirDefault; }
    QString getThumbnailsCacheBaseDirLocation() { return m_thumbnailsCacheBaseDirLocation; }
    int getThumbnailsMaxNumberThreads() { return m_thumbnailsMaxNumberThreads; }
    bool getThumbnailsCache() { return m_thumbnailsCache; }
    bool getThumbnailsIconsOnly() { return m_thumbnailsIconsOnly; }

    bool getMetadataAutoRotation() { return m_metadataAutoRotation; }

private:
    PQCSettingsCPP(QObject *parent = nullptr) : QObject(parent) {

            m_generalEnabledExtensions = QStringList();

            m_imageviewFitInWindow = false;
            m_imageviewSortImagesAscending = false;
            m_imageviewSortImagesBy = "";
            m_imageviewCache = 0;
            m_imageviewColorSpaceEnable = false;
            m_imageviewColorSpaceLoadEmbedded = false;
            m_imageviewColorSpaceDefault = "";
            m_imageviewAdvancedSortCriteria = "";
            m_imageviewAdvancedSortAscending = false;
            m_imageviewAdvancedSortQuality = "";
            m_imageviewAdvancedSortDateCriteria = QStringList();
            m_imageviewRespectDevicePixelRatio = false;

            m_filedialogDevicesShowTmpfs = false;
            m_filedialogShowHiddenFilesFolders = false;

            m_filetypesLoadAppleLivePhotos = false;
            m_filetypesLoadMotionPhotos = false;
            m_filetypesExternalUnrar = false;
            m_filetypesVideoThumbnailer = "";
            m_filetypesRAWUseEmbeddedIfAvailable = false;
            m_filetypesPDFQuality = 0.0;
            m_filetypesVideoPreferLibmpv = false;
            m_filetypesArchiveAlwaysEnterAutomatically = false;
            m_filetypesComicBookAlwaysEnterAutomatically = false;
            m_filetypesDocumentAlwaysEnterAutomatically = false;

            m_interfaceAccentColor = "";
            m_interfaceFontNormalWeight = 0;
            m_interfaceFontBoldWeight = 0;
            m_interfacePopoutWhenWindowIsSmall = false;
            m_interfaceLanguage = "";

            m_thumbnailsExcludeDropBox = "";
            m_thumbnailsExcludeNextcloud = "";
            m_thumbnailsExcludeOwnCloud = "";
            m_thumbnailsExcludeFolders = QStringList();
            m_thumbnailsExcludeNetworkShares = false;
            m_thumbnailsCacheBaseDirDefault = false;
            m_thumbnailsCacheBaseDirLocation = "";
            m_thumbnailsMaxNumberThreads = 0;
            m_thumbnailsCache = false;
            m_thumbnailsIconsOnly = false;

            m_metadataAutoRotation = false;

    }

    QVariantHash m_extensions;
    QVariantHash m_extensions_defaults;

    QStringList m_generalEnabledExtensions;

    bool m_imageviewFitInWindow;
    bool m_imageviewSortImagesAscending;
    QString m_imageviewSortImagesBy;
    int m_imageviewCache;
    bool m_imageviewColorSpaceEnable;
    bool m_imageviewColorSpaceLoadEmbedded;
    QString m_imageviewColorSpaceDefault;
    QString m_imageviewAdvancedSortCriteria;
    bool m_imageviewAdvancedSortAscending;
    QString m_imageviewAdvancedSortQuality;
    QStringList m_imageviewAdvancedSortDateCriteria;
    bool m_imageviewRespectDevicePixelRatio;

    bool m_filedialogDevicesShowTmpfs;
    bool m_filedialogShowHiddenFilesFolders;

    bool m_filetypesLoadAppleLivePhotos;
    bool m_filetypesLoadMotionPhotos;
    bool m_filetypesExternalUnrar;
    QString m_filetypesVideoThumbnailer;
    bool m_filetypesRAWUseEmbeddedIfAvailable;
    double m_filetypesPDFQuality;
    bool m_filetypesVideoPreferLibmpv;
    bool m_filetypesArchiveAlwaysEnterAutomatically;
    bool m_filetypesComicBookAlwaysEnterAutomatically;
    bool m_filetypesDocumentAlwaysEnterAutomatically;

    QString m_interfaceAccentColor;
    int m_interfaceFontNormalWeight;
    int m_interfaceFontBoldWeight;
    bool m_interfacePopoutWhenWindowIsSmall;
    QString m_interfaceLanguage;

    QString m_thumbnailsExcludeDropBox;
    QString m_thumbnailsExcludeNextcloud;
    QString m_thumbnailsExcludeOwnCloud;
    QStringList m_thumbnailsExcludeFolders;
    bool m_thumbnailsExcludeNetworkShares;
    bool m_thumbnailsCacheBaseDirDefault;
    QString m_thumbnailsCacheBaseDirLocation;
    int m_thumbnailsMaxNumberThreads;
    bool m_thumbnailsCache;
    bool m_thumbnailsIconsOnly;

    bool m_metadataAutoRotation;

Q_SIGNALS:
    void extensionsChanged();
    void generalEnabledExtensionsChanged();

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

#endif
