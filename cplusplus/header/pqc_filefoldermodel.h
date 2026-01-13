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

#ifndef PQCFILEFOLDERMODEL_H
#define PQCFILEFOLDERMODEL_H

#include <QObject>
#include <pqc_filefoldermodelcache.h>
#include <QTimer>
#include <QMimeDatabase>
#include <QSize>
#include <QQmlEngine>

#include <pqc_filefoldermodelCPP.h>

class QSize;
class QFileSystemWatcher;

class PQCFileFolderModel : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCFileFolderModel(QObject *parent = 0);
    ~PQCFileFolderModel();

    /********************************************/
    /********************************************/

    Q_PROPERTY(QString fileInFolderMainView READ getFileInFolderMainView WRITE setFileInFolderMainView NOTIFY fileInFolderMainViewChanged)
    QString getFileInFolderMainView();
    void setFileInFolderMainView(QString val);

    Q_PROPERTY(QString folderFileDialog READ getFolderFileDialog WRITE setFolderFileDialog NOTIFY folderFileDialogChanged)
    QString getFolderFileDialog();
    void setFolderFileDialog(QString val);

    Q_PROPERTY(bool firstFolderMainViewLoaded READ getFirstFolderMainViewLoaded WRITE setFirstFolderMainViewLoaded NOTIFY firstFolderMainViewLoadedChanged)
    bool getFirstFolderMainViewLoaded();
    void setFirstFolderMainViewLoaded(bool val);

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

    Q_PROPERTY(QStringList virtualFolders READ getVirtualFolders WRITE setVirtualFolders NOTIFY virtualFoldersChanged)
    QStringList getVirtualFolders();
    void setVirtualFolders(QStringList val);

    Q_PROPERTY(QStringList virtualFiles READ getVirtualFiles WRITE setVirtualFiles NOTIFY virtualFilesChanged)
    QStringList getVirtualFiles();
    void setVirtualFiles(QStringList val);

    Q_PROPERTY(bool loadVirtualFolderFileDialog READ getLoadVirtualFolderFileDialog WRITE setLoadVirtualFolderFileDialog NOTIFY loadVirtualFolderFileDialogChanged)
    bool getLoadVirtualFolderFileDialog();
    void setLoadVirtualFolderFileDialog(bool c);

    Q_PROPERTY(bool loadVirtualFolderMainView READ getLoadVirtualFolderMainView WRITE setLoadVirtualFolderMainView NOTIFY loadVirtualFolderMainViewChanged)
    bool getLoadVirtualFolderMainView();
    void setLoadVirtualFolderMainView(bool c);

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
    Q_INVOKABLE int getIndexOf(QString file);

    Q_PROPERTY(int currentIndexNoDelay READ getCurrentIndexNoDelay NOTIFY currentIndexNoDelayChanged)
    int getCurrentIndexNoDelay();

    Q_PROPERTY(QString currentFile READ getCurrentFile NOTIFY currentFileChanged)
    QString getCurrentFile();

    Q_PROPERTY(QString currentFileNoDelay READ getCurrentFileNoDelay NOTIFY currentFileNoDelayChanged)
    QString getCurrentFileNoDelay();

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

    Q_PROPERTY(bool justLeftViewerMode MEMBER m_justLeftViewerMode NOTIFY justLeftViewerModeChanged)
    Q_PROPERTY(bool activeViewerMode MEMBER m_activeViewerMode NOTIFY activeViewerModeChanged)

    /********************************************/
    /********************************************/

    Q_INVOKABLE void advancedSortMainView(QString advSortCriteria, bool advSortAscending, QString advSortQuality, QStringList advDateCriteria);
    Q_INVOKABLE void advancedSortMainViewCANCEL();
    Q_INVOKABLE void forceReloadMainView();
    Q_INVOKABLE void forceReloadFileDialog();
    Q_INVOKABLE int getIndexOfMainView(QString filepath);
    Q_INVOKABLE void removeEntryMainView(int index);
    Q_INVOKABLE void removeAllUserFilter();
    Q_INVOKABLE bool isUserFilterSet();
    Q_INVOKABLE void enableViewerMode(int page = 0);
    Q_INVOKABLE void disableViewerMode(bool bufferDisabling = true);
    Q_INVOKABLE QString getFirstMatchFileDialog(QString partial);
    Q_INVOKABLE void loadNextMatchOfSearch(const QString search);

    /********************************************/

    Q_INVOKABLE void resetModel();

    /********************************************/

private:
    PQCFileFolderModelCache cache;

    QFileSystemWatcher *watcherMainView;
    QFileSystemWatcher *watcherFileDialog;


    QString m_fileInFolderMainView;
    QString m_folderFileDialog;
    bool m_firstFolderMainViewLoaded;
    int m_countMainView;
    int m_countFoldersFileDialog;
    int m_countFilesFileDialog;
    int m_countAllFileDialog;

    bool m_readDocumentOnly;
    bool m_readArchiveOnly;
    bool m_includeFilesInSubFolders;
    QStringList m_virtualFolders;
    QStringList m_virtualFiles;
    bool m_loadVirtualFolderFileDialog;
    bool m_loadVirtualFolderMainView;

    QStringList m_entriesMainView;
    QStringList m_entriesFileDialog;

    QStringList m_nameFilters;
    QStringList m_restrictToSuffixes;
    QStringList m_restrictToMimeTypes;
    QStringList m_filenameFilters;
    QSize m_imageResolutionFilter;
    qint64 m_fileSizeFilter;
    bool m_filterCurrentlyActive;
    bool m_justLeftViewerMode;
    bool m_activeViewerMode;

    int m_currentIndex;
    int m_currentIndexNoDelay;
    QString m_currentFile;
    QString m_currentFileNoDelay;

    bool m_isPDF;
    bool m_isARC;
    QString m_pdfName;
    int m_pdfNum;
    QString m_arcName;
    QString m_arcFile;

    QTimer *loadDelayMainView;
    QTimer *loadDelayFileDialog;

    QTimer *timerNotifyCurrentIndexChanged;
    QTimer *timerResetJustLeftViewerMode;

    QStringList getAllFolders(QString folder, bool forceShowHidden = false);
    QStringList getAllFiles(QString folder, bool ignoreFiltersExceptDefault = false, bool enforceOnlyIncludingThisFolder = false);

    QMimeDatabase db;

    QStringList listPDFPages(QString path);

    int m_advancedSortDone;
    bool advancedSortKeepGoing;

    QString cacheAdvancedSortCriteria;
    QString cacheAdvancedSortFolderName;
    QStringList cacheAdvancedSortFolder;
    qint64 cacheAdvancedSortLastModified;
    bool cacheAdvancedSortAscending;

    QStringList archiveContentPreloaded;

    void checkFilterActive();

private Q_SLOTS:
    void loadDataMainView();
    void loadDataFileDialog();
    void handleNewDataLoadedMainView();

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
    void firstFolderMainViewLoadedChanged();
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
    void virtualFoldersChanged();
    void virtualFilesChanged();
    void loadVirtualFolderFileDialogChanged();
    void loadVirtualFolderMainViewChanged();
    void advancedSortDoneChanged();
    void currentIndexChanged();
    void currentIndexNoDelayChanged();
    void currentFileChanged();
    void currentFileNoDelayChanged();
    void isPDFChanged();
    void isARCChanged();
    void pdfNameChanged();
    void pdfNumChanged();
    void arcNameChanged();
    void arcFileChanged();
    void justLeftViewerModeChanged();
    void activeViewerModeChanged();

};

#endif
