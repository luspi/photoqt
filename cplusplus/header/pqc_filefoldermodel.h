/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#ifndef PQCFILEFOLDERMODEL_H
#define PQCFILEFOLDERMODEL_H

#include <QObject>
#include <pqc_filefoldermodelcache.h>
#include <QTimer>
#include <QMimeDatabase>
#include <QSize>

class QSize;
class QFileSystemWatcher;

class PQCFileFolderModel : public QObject {

    Q_OBJECT

public:
    static PQCFileFolderModel& get();

    PQCFileFolderModel(PQCFileFolderModel const&)     = delete;
    void operator=(PQCFileFolderModel const&) = delete;

    ~PQCFileFolderModel();

    /********************************************/
    /********************************************/

    Q_PROPERTY(QString fileInFolderMainView READ getFileInFolderMainView WRITE setFileInFolderMainView NOTIFY fileInFolderMainViewChanged)
    QString getFileInFolderMainView();
    void setFileInFolderMainView(QString val);

    Q_PROPERTY(QString folderFileDialog READ getFolderFileDialog WRITE setFolderFileDialog NOTIFY folderFileDialogChanged)
    QString getFolderFileDialog();
    void setFolderFileDialog(QString val);

    /********************************************/
    /********************************************/

    Q_PROPERTY(int countMainView READ getCountMainView WRITE setCountMainView NOTIFY countMainViewChanged)
    int getCountMainView();
    void setCountMainView(int c);

    Q_PROPERTY(int countFoldersFileDialog READ getCountFoldersFileDialog WRITE setCountFoldersFileDialog NOTIFY countFoldersFileDialogChanged)
    int getCountFoldersFileDialog();
    void setCountFoldersFileDialog(int c);

    Q_PROPERTY(int countFilesFileDialog READ getCountFilesFileDialog WRITE setCountFilesFileDialog NOTIFY countFilesFileDialogChanged)
    int getCountFilesFileDialog();
    void setCountFilesFileDialog(int c);

    Q_PROPERTY(int countAllFileDialog READ getCountAllFileDialog NOTIFY countAllFileDialogChanged)
    int getCountAllFileDialog();

    /********************************************/
    /********************************************/

    Q_PROPERTY(QStringList entriesFileDialog READ getEntriesFileDialog NOTIFY entriesFileDialogChanged)
    QStringList getEntriesFileDialog();

    Q_PROPERTY(QStringList entriesMainView READ getEntriesMainView NOTIFY entriesMainViewChanged)
    QStringList getEntriesMainView();

    Q_PROPERTY(bool includeFilesInSubFolders READ getIncludeFilesInSubFolders WRITE setIncludeFilesInSubFolders NOTIFY includeFilesInSubFoldersChanged)
    bool getIncludeFilesInSubFolders();
    void setIncludeFilesInSubFolders(bool c);

    Q_PROPERTY(bool readDocumentOnly READ getReadDocumentOnly WRITE setReadDocumentOnly NOTIFY readDocumentOnlyChanged)
    bool getReadDocumentOnly();
    void setReadDocumentOnly(bool c);

    Q_PROPERTY(bool readArchiveOnly READ getReadArchiveOnly WRITE setReadArchiveOnly NOTIFY readArchiveOnlyChanged)
    bool getReadArchiveOnly();
    void setReadArchiveOnly(bool c);

    /********************************************/
    /********************************************/

    Q_PROPERTY(QStringList restrictToSuffixes READ getRestrictToSuffixes WRITE setRestrictToSuffixes NOTIFY restrictToSuffixesChanged)
    QStringList getRestrictToSuffixes();
    void setRestrictToSuffixes(QStringList val);

    Q_PROPERTY(QStringList nameFilters READ getNameFilters WRITE setNameFilters NOTIFY nameFiltersChanged)
    QStringList getNameFilters();
    void setNameFilters(QStringList val);

    Q_PROPERTY(QStringList filenameFilters READ getFilenameFilters WRITE setFilenameFilters NOTIFY filenameFiltersChanged)
    QStringList getFilenameFilters();
    void setFilenameFilters(QStringList val);

    Q_PROPERTY(QStringList restrictToMimeTypes READ getRestrictToMimeTypes WRITE setRestrictToMimeTypes NOTIFY restrictToMimeTypesChanged)
    QStringList getRestrictToMimeTypes();
    void setRestrictToMimeTypes(QStringList val);

    Q_PROPERTY(QSize imageResolutionFilter READ getImageResolutionFilter WRITE setImageResolutionFilter NOTIFY imageResolutionFilterChanged)
    QSize getImageResolutionFilter();
    void setImageResolutionFilter(QSize val);

    Q_PROPERTY(qint64 fileSizeFilter READ getFileSizeFilter WRITE setFileSizeFilter NOTIFY fileSizeFilterChanged)
    qint64 getFileSizeFilter();
    void setFileSizeFilter(qint64 val);

    Q_PROPERTY(bool filterCurrentlyActive READ getFilterCurrentlyActive NOTIFY filterCurrentlyActiveChanged)
    bool getFilterCurrentlyActive();

    /********************************************/
    /********************************************/

    Q_PROPERTY(int advancedSortDone READ getAdvancedSortDone NOTIFY advancedSortDoneChanged)
    int getAdvancedSortDone();

    /********************************************/
    /********************************************/

    Q_PROPERTY(int currentIndex READ getCurrentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
    int getCurrentIndex();
    void setCurrentIndex(int val);

    Q_PROPERTY(QString currentFile READ getCurrentFile NOTIFY currentFileChanged)
    QString getCurrentFile();

    Q_PROPERTY(bool isPDF READ getIsPDF NOTIFY isPDFChanged)
    bool getIsPDF();

    Q_PROPERTY(bool isARC READ getIsARC NOTIFY isARCChanged)
    bool getIsARC();

    Q_PROPERTY(QString pdfName READ getPdfName NOTIFY pdfNameChanged)
    QString getPdfName();

    Q_PROPERTY(int pdfNum READ getPdfNum NOTIFY pdfNumChanged)
    int getPdfNum();

    Q_PROPERTY(QString arcName READ getArcName NOTIFY arcNameChanged)
    QString getArcName();

    Q_PROPERTY(QString arcFile READ getArcFile NOTIFY arcFileChanged)
    QString getArcFile();

    /********************************************/
    /********************************************/

    Q_INVOKABLE void advancedSortMainView();
    Q_INVOKABLE void advancedSortMainViewCANCEL();
    Q_INVOKABLE void forceReloadMainView();
    Q_INVOKABLE void forceReloadFileDialog();
    Q_INVOKABLE int getIndexOfMainView(QString filepath);
    Q_INVOKABLE void removeEntryMainView(int index);
    Q_INVOKABLE void removeAllUserFilter();
    Q_INVOKABLE bool isUserFilterSet();
    Q_INVOKABLE void enableViewerMode();
    Q_INVOKABLE void disableViewerMode();
    Q_INVOKABLE QString getFirstMatchFileDialog(QString partial);

    /********************************************/

    Q_INVOKABLE void resetModel();

private:
    PQCFileFolderModel(QObject *parent = 0);

    PQCFileFolderModelCache cache;

    QFileSystemWatcher *watcherMainView;
    QFileSystemWatcher *watcherFileDialog;

    QString m_fileInFolderMainView;
    QString m_folderFileDialog;
    int m_countMainView;
    int m_countFoldersFileDialog;
    int m_countFilesFileDialog;
    int m_countAllFileDialog;

    bool m_readDocumentOnly;
    bool m_readArchiveOnly;
    bool m_includeFilesInSubFolders;

    QStringList m_entriesMainView;
    QStringList m_entriesFileDialog;

    QStringList m_nameFilters;
    QStringList m_restrictToSuffixes;
    QStringList m_restrictToMimeTypes;
    QStringList m_filenameFilters;
    QSize m_imageResolutionFilter;
    qint64 m_fileSizeFilter;
    bool m_filterCurrentlyActive;

    int m_currentIndex;
    QString m_currentFile;

    bool m_isPDF;
    bool m_isARC;
    QString m_pdfName;
    int m_pdfNum;
    QString m_arcName;
    QString m_arcFile;

    QTimer *loadDelayMainView;
    QTimer *loadDelayFileDialog;

    QStringList getAllFolders(QString folder);
    QStringList getAllFiles(QString folder, bool ignoreFiltersExceptDefault = false);

    QMimeDatabase db;

    QStringList listPDFPages(QString path);

    int m_advancedSortDone;
    bool advancedSortKeepGoing;

    QString cacheAdvancedSortCriteria;
    QString cacheAdvancedSortFolderName;
    QStringList cacheAdvancedSortFolder;
    qint64 cacheAdvancedSortLastModified;
    bool cacheAdvancedSortAscending;

    void checkFilterActive();

private Q_SLOTS:
    void loadDataMainView();
    void loadDataFileDialog();
    void handleNewDataLoadedMainView();

    void handleSettingsChanges(const QString &key, const QVariant &value);

Q_SIGNALS:
    void newDataLoadedMainView();
    void newDataLoadedFileDialog();

    void advancedSortingComplete();

    void countMainViewChanged();
    void countFoldersFileDialogChanged();
    void countFilesFileDialogChanged();
    void countAllFileDialogChanged();
    void entriesMainViewChanged();
    void entriesFileDialogChanged();
    void fileInFolderMainViewChanged();
    void folderFileDialogChanged();
    void nameFiltersChanged();
    void restrictToSuffixesChanged();
    void filenameFiltersChanged();
    void restrictToMimeTypesChanged();
    void imageResolutionFilterChanged();
    void fileSizeFilterChanged();
    void filterCurrentlyActiveChanged();
    void sortFieldChanged();
    void sortReversedChanged();
    void readDocumentOnlyChanged();
    void readArchiveOnlyChanged();
    void includeFilesInSubFoldersChanged();
    void advancedSortDoneChanged();
    void currentIndexChanged();
    void currentFileChanged();
    void isPDFChanged();
    void isARCChanged();
    void pdfNameChanged();
    void pdfNumChanged();
    void arcNameChanged();
    void arcFileChanged();

};

#endif
