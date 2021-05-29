/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

#ifndef FILEFOLDERMODEL_H
#define FILEFOLDERMODEL_H

#include <QObject>
#include <QDateTime>
#include <QTimer>
#include <QCollator>
#include <QMimeDatabase>
#include <QDirIterator>
#include "../settings/settings.h"
#include "../logger.h"
#include "../settings/imageformats.h"
#include "../scripts/handlingfiledir.h"
#include "filefoldermodelcache.h"

#ifdef POPPLER
#include <poppler/qt5/poppler-qt5.h>
#endif

class PQFileFolderModel : public QObject {

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
    Q_ENUMS(SortBy)

    PQFileFolderModel(QObject *parent = nullptr);
    ~PQFileFolderModel();

    Q_PROPERTY(QString fileInFolderMainView READ getFileInFolderMainView WRITE setFileInFolderMainView NOTIFY fileInFolderMainViewChanged)
    QString getFileInFolderMainView() { return m_fileInFolderMainView; }
    void setFileInFolderMainView(QString val) { m_fileInFolderMainView = val; emit fileInFolderMainViewChanged(); loadDelayMainView->start(); }

    Q_PROPERTY(QString folderFileDialog READ getFolderFileDialog WRITE setFolderFileDialog NOTIFY folderFileDialogChanged)
    QString getFolderFileDialog() { return m_folderFileDialog; }
    void setFolderFileDialog(QString val) { m_folderFileDialog = val; emit folderFileDialogChanged(); loadDelayFileDialog->start(); }

    Q_PROPERTY(int countMainView READ getCountMainView WRITE setCountMainView NOTIFY countMainViewChanged)
    int getCountMainView() { return m_countMainView; }
    void setCountMainView(int c) { m_countMainView = c; countMainViewChanged(); }

    Q_PROPERTY(int countFileDialog READ getCountFileDialog WRITE setCountFileDialog NOTIFY countFileDialogChanged)
    int getCountFileDialog() { return m_countFileDialog; }
    void setCountFileDialog(int c) { m_countFileDialog = c; countFileDialogChanged(); }


    Q_PROPERTY(int readDocumentOnly READ getReadDocumentOnly WRITE setReadDocumentOnly)
    int getReadDocumentOnly() { return m_readDocumentOnly; }
    void setReadDocumentOnly(int c) { m_readDocumentOnly = c; }

    Q_PROPERTY(int readArchiveOnly READ getReadArchiveOnly WRITE setReadArchiveOnly)
    int getReadArchiveOnly() { return m_readArchiveOnly; }
    void setReadArchiveOnly(int c) { m_readArchiveOnly = c; }

    Q_PROPERTY(int includeFilesInSubFolders READ getIncludeFilesInSubFolders WRITE setIncludeFilesInSubFolders)
    int getIncludeFilesInSubFolders() { return m_includeFilesInSubFolders; }
    void setIncludeFilesInSubFolders(int c) { m_includeFilesInSubFolders = c; loadDelayMainView->start(); }


    Q_PROPERTY(QStringList defaultNameFilters READ getDefaultNameFilters WRITE setDefaultNameFilters NOTIFY defaultNameFiltersChanged)
    QStringList getDefaultNameFilters() { return m_defaultNameFilters; }
    void setDefaultNameFilters(QStringList val) { m_defaultNameFilters = val; emit defaultNameFiltersChanged(); loadDelayMainView->start(); loadDelayFileDialog->start(); }

    Q_PROPERTY(QStringList nameFilters READ getNameFilters WRITE setNameFilters NOTIFY nameFiltersChanged)
    QStringList getNameFilters() { return m_nameFilters; }
    void setNameFilters(QStringList val) { m_nameFilters = val; emit nameFiltersChanged(); loadDelayMainView->start(); loadDelayFileDialog->start(); }

    Q_PROPERTY(QStringList filenameFilters READ getFilenameFilters WRITE setFilenameFilters NOTIFY filenameFiltersChanged)
    QStringList getFilenameFilters() { return m_filenameFilters; }
    void setFilenameFilters(QStringList val) { m_filenameFilters = val; emit filenameFiltersChanged(); loadDelayMainView->start(); loadDelayFileDialog->start(); }

    Q_PROPERTY(QStringList mimeTypeFilters READ getMimeTypeFilters WRITE setMimeTypeFilters NOTIFY mimeTypeFiltersChanged)
    QStringList getMimeTypeFilters() { return m_mimeTypeFilters; }
    void setMimeTypeFilters(QStringList val) { m_mimeTypeFilters = val; emit mimeTypeFiltersChanged(); loadDelayMainView->start(); loadDelayFileDialog->start(); }

    Q_PROPERTY(bool showHidden READ getShowHidden WRITE setShowHidden NOTIFY showHiddenChanged)
    bool getShowHidden() { return m_showHidden; }
    void setShowHidden(bool val) { m_showHidden = val; emit showHiddenChanged(); loadDelayMainView->start(); loadDelayFileDialog->start(); }

    Q_PROPERTY(SortBy sortField READ getSortField WRITE setSortField NOTIFY sortFieldChanged)
    SortBy getSortField() { return m_sortField; }
    void setSortField(SortBy val) { m_sortField = val; emit sortFieldChanged(); loadDelayMainView->start(); loadDelayFileDialog->start(); }

    Q_PROPERTY(bool sortReversed READ getSortReversed WRITE setSortReversed NOTIFY sortReversedChanged)
    bool getSortReversed() { return m_sortReversed; }
    void setSortReversed(bool val) { m_sortReversed = val; emit sortReversedChanged(); loadDelayMainView->start(); loadDelayFileDialog->start(); }

    Q_INVOKABLE QVariantList getValuesFileDialog(int index);
    Q_INVOKABLE QString getFileNameFileDialog(int index) { if(index < 0 || index >= m_entriesFileDialog.length()) return ""; return QFileInfo(m_entriesFileDialog[index]).fileName(); }
    Q_INVOKABLE QString getFilePathFileDialog(int index) { if(index < 0 || index >= m_entriesFileDialog.length()) return ""; return m_entriesFileDialog[index]; }
    Q_INVOKABLE qint64 getFileSizeFileDialog(int index) { if(index < 0 || index >= m_entriesFileDialog.length()) return 0; return QFileInfo(m_entriesFileDialog[index]).size(); }
    Q_INVOKABLE QDateTime getFileModifiedFileDialog(int index) { if(index < 0 || index >= m_entriesFileDialog.length()) return QDateTime::currentDateTime(); return QFileInfo(m_entriesFileDialog[index]).lastModified(); }
    Q_INVOKABLE bool getFileIsDirFileDialog(int index) { if(index < 0 || index >= m_entriesFileDialog.length()) return false; return QFileInfo(m_entriesFileDialog[index]).isDir(); }
    Q_INVOKABLE QString getFileTypeFileDialog(int index) { if(index < 0 || index >= m_entriesFileDialog.length()) return ""; return db.mimeTypeForFile(m_entriesFileDialog[index]).name(); }

    Q_INVOKABLE QVariantList getValuesMainView(int index);
    Q_INVOKABLE QString getFileNameMainView(int index) { if(index < 0 || index >= m_entriesMainView.length()) return ""; return QFileInfo(m_entriesMainView[index]).fileName(); }
    Q_INVOKABLE QString getFilePathMainView(int index) { if(index < 0 || index >= m_entriesMainView.length()) return ""; return m_entriesMainView[index]; }
    Q_INVOKABLE qint64 getFileSizeMainView(int index) { if(index < 0 || index >= m_entriesMainView.length()) return 0; return QFileInfo(m_entriesMainView[index]).size(); }
    Q_INVOKABLE QDateTime getFileModifiedMainView(int index) { if(index < 0 || index >= m_entriesMainView.length()) return QDateTime::currentDateTime(); return QFileInfo(m_entriesMainView[index]).lastModified(); }
    Q_INVOKABLE bool getFileIsDirMainView(int index) { if(index < 0 || index >= m_entriesMainView.length()) return false; return QFileInfo(m_entriesMainView[index]).isDir(); }
    Q_INVOKABLE QString getFileTypeMainView(int index) { if(index < 0 || index >= m_entriesMainView.length()) return ""; return db.mimeTypeForFile(m_entriesMainView[index]).name(); }

    Q_INVOKABLE void removeEntryMainView(int index);

    Q_INVOKABLE int getIndexOfMainView(QString filepath) {
        for(int i = 0; i < m_entriesMainView.length(); ++i) {
            if(m_entriesMainView[i] == filepath)
                return i;
        }
        return -1;
    }

private:
    PQFileFolderModelCache cache;

    QString m_fileInFolderMainView;
    QString m_folderFileDialog;
    int m_countMainView;
    int m_countFileDialog;

    bool m_readDocumentOnly;
    bool m_readArchiveOnly;
    bool m_includeFilesInSubFolders;

    QStringList m_entriesMainView;
    QStringList m_entriesFileDialog;

    QStringList m_nameFilters;
    QStringList m_defaultNameFilters;
    QStringList m_filenameFilters;
    QStringList m_mimeTypeFilters;
    bool m_showHidden;
    SortBy m_sortField;
    bool m_sortReversed;

    QTimer *loadDelayMainView;
    QTimer *loadDelayFileDialog;

    QStringList getAllFolders(QString folder);
    QStringList getAllFiles(QString folder);

    QMimeDatabase db;

    QStringList listPDFPages(QString path);

private slots:
    void loadDataMainView();
    void loadDataFileDialog();

signals:
    void newDataLoadedMainView();
    void newDataLoadedFileDialog();

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
    void showHiddenChanged();
    void sortFieldChanged();
    void sortReversedChanged();

};

#endif
