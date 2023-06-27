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

class QSize;
class QFileSystemWatcher;

class PQCFileFolderModel : public QObject {

    Q_OBJECT

public:
    enum FileRoles {
        FileNameRole = Qt::UserRole + 1,
        FilePathRole,
        PathRole,
        FileSizeRole,
        FileModifiedRole,
        FileIsDirRole,
        FileTypeRole
    };

    enum SortBy {
        Name,
        NaturalName,
        Time,
        Size,
        Type
    };
    Q_ENUM(SortBy)

    enum AdvancedSort {
        DominantColor,
        AverageColor
    };

    PQCFileFolderModel(QObject *parent = nullptr);
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

    Q_PROPERTY(int countFoldersFileDialog READ getCountFoldersFileDialog WRITE setCountFoldersFileDialog NOTIFY countFileDialogChanged)
    int getCountFoldersFileDialog();
    void setCountFoldersFileDialog(int c);

    Q_PROPERTY(int countFilesFileDialog READ getCountFilesFileDialog WRITE setCountFilesFileDialog NOTIFY countFileDialogChanged)
    int getCountFilesFileDialog();
    void setCountFilesFileDialog(int c);

    /********************************************/
    /********************************************/

    Q_PROPERTY(QStringList entriesFileDialog READ getEntriesFileDialog NOTIFY entriesFileDialogChanged)
    QStringList getEntriesFileDialog();

    Q_PROPERTY(QStringList entriesMainView READ getEntriesMainView NOTIFY entriesMainViewChanged)
    QStringList getEntriesMainView();

    Q_PROPERTY(int includeFilesInSubFolders READ getIncludeFilesInSubFolders WRITE setIncludeFilesInSubFolders NOTIFY includeFilesInSubFoldersChanged)
    int getIncludeFilesInSubFolders();
    void setIncludeFilesInSubFolders(int c);

    /********************************************/
    /********************************************/

    Q_PROPERTY(QStringList defaultNameFilters READ getDefaultNameFilters WRITE setDefaultNameFilters NOTIFY defaultNameFiltersChanged)
    QStringList getDefaultNameFilters();
    void setDefaultNameFilters(QStringList val);

    Q_PROPERTY(QStringList nameFilters READ getNameFilters WRITE setNameFilters NOTIFY nameFiltersChanged)
    QStringList getNameFilters();
    void setNameFilters(QStringList val);

    Q_PROPERTY(QStringList filenameFilters READ getFilenameFilters WRITE setFilenameFilters NOTIFY filenameFiltersChanged)
    QStringList getFilenameFilters();
    void setFilenameFilters(QStringList val);

    Q_PROPERTY(QStringList mimeTypeFilters READ getMimeTypeFilters WRITE setMimeTypeFilters NOTIFY mimeTypeFiltersChanged)
    QStringList getMimeTypeFilters();
    void setMimeTypeFilters(QStringList val);

    Q_PROPERTY(QSize imageResolutionFilter READ getImageResolutionFilter WRITE setImageResolutionFilter NOTIFY imageResolutionFilterChanged)
    QSize getImageResolutionFilter();
    void setImageResolutionFilter(QSize val);

    Q_PROPERTY(qint64 fileSizeFilter READ getFileSizeFilter WRITE setFileSizeFilter NOTIFY fileSizeFilterChanged)
    qint64 getFileSizeFilter();
    void setFileSizeFilter(qint64 val);

    /********************************************/
    /********************************************/

    Q_PROPERTY(int advancedSortDone READ getAdvancedSortDone NOTIFY advancedSortDoneChanged)
    int getAdvancedSortDone();

    /********************************************/
    /********************************************/

    Q_INVOKABLE void advancedSortMainView();
    Q_INVOKABLE void advancedSortMainViewCANCEL();
    Q_INVOKABLE void forceReloadMainView();
    Q_INVOKABLE int getIndexOfMainView(QString filepath);
    Q_INVOKABLE void removeEntryMainView(int index);

    /********************************************/

    Q_INVOKABLE void resetModel();

private:
    PQCFileFolderModelCache cache;

    QFileSystemWatcher *watcherMainView;
    QFileSystemWatcher *watcherFileDialog;

    QString m_fileInFolderMainView;
    QString m_folderFileDialog;
    int m_countMainView;
    int m_countFoldersFileDialog;
    int m_countFilesFileDialog;

    bool m_readDocumentOnly;
    bool m_readArchiveOnly;
    bool m_includeFilesInSubFolders;

    QStringList m_entriesMainView;
    QStringList m_entriesFileDialog;

    QStringList m_nameFilters;
    QStringList m_defaultNameFilters;
    QStringList m_filenameFilters;
    QStringList m_mimeTypeFilters;
    QSize m_imageResolutionFilter;
    qint64 m_fileSizeFilter;
    bool m_showHidden;
    SortBy m_sortField;
    bool m_sortReversed;

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

private Q_SLOTS:
    void loadDataMainView();
    void loadDataFileDialog();

Q_SIGNALS:
    void newDataLoadedMainView();
    void newDataLoadedFileDialog();

    void advancedSortingComplete();

    void countMainViewChanged();
    void countFileDialogChanged();
    void entriesMainViewChanged();
    void entriesFileDialogChanged();
    void fileInFolderMainViewChanged();
    void folderFileDialogChanged();
    void nameFiltersChanged();
    void defaultNameFiltersChanged();
    void filenameFiltersChanged();
    void mimeTypeFiltersChanged();
    void imageResolutionFilterChanged();
    void fileSizeFilterChanged();
    void showHiddenChanged();
    void sortFieldChanged();
    void sortReversedChanged();
    void readDocumentOnlyChanged();
    void readArchiveOnlyChanged();
    void includeFilesInSubFoldersChanged();
    void advancedSortDoneChanged();

};

#endif
