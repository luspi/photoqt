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

#include <QAbstractListModel>
#include <QDateTime>
#include <QDir>
#include <QTimer>
#include <QCollator>
#include <QFileSystemWatcher>
#include "../logger.h"
#include "../settings/settings.h"
#include "handlingfiledialog.h"
#include "../settings/imageformats.h"

#ifdef POPPLER
#include <poppler/qt5/poppler-qt5.h>
#endif

class PQFileFolderEntry {

public:
    QString fileName;
    QString filePath;
    qint64 fileSize;
    QDateTime fileModified;
    bool fileIsDir;
    QString fileType;
};

class PQFileFolderModel : public QAbstractListModel {

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

    int rowCount(const QModelIndex &parent = QModelIndex()) const {
        if(parent.isValid())
            return 0;
        return entries.size();
    }

    QVariant data(const QModelIndex &index, int role) const {

        if(index.row() < 0 || index.row() >= entries.size())
            return QVariant();

        PQFileFolderEntry* entry = entries[index.row()];
        if (role == FileNameRole)
            return QVariant::fromValue(entry->fileName);
        else if (role == FilePathRole || role == PathRole)
            return QVariant::fromValue(entry->filePath);
        else if (role == FileSizeRole)
            return QVariant::fromValue(entry->fileSize);
        else if (role == FileModifiedRole)
            return QVariant::fromValue(entry->fileModified);
        else if (role == FileIsDirRole)
            return QVariant::fromValue(entry->fileIsDir);
        else if (role == FileTypeRole)
            return QVariant::fromValue(entry->fileType);

        // should be unreachable code
        return QVariant();

    }

    Q_PROPERTY(QString folder READ getFolder WRITE setFolder NOTIFY folderChanged)
    QString getFolder() { return m_folder; }
    void setFolder(QString val) { m_folder = val; emit folderChanged(); loadDelay->start(); }

    Q_PROPERTY(bool ignoreDirs READ getIgnoreDirs WRITE setIgnoreDirs NOTIFY ignoreDirsChanged)
    bool getIgnoreDirs() { return m_ignoreDirs; }
    void setIgnoreDirs(bool val) { m_ignoreDirs = val; emit ignoreDirsChanged(); }

    Q_PROPERTY(bool naturalOrdering READ getNaturalOrdering WRITE setNaturalOrdering NOTIFY naturalOrderingChanged)
    bool getNaturalOrdering() { return m_naturalOrdering; }
    void setNaturalOrdering(bool val) { m_naturalOrdering = val; emit naturalOrderingChanged(); loadDelay->start(); }

    Q_PROPERTY(QStringList nameFilters READ getNameFilters WRITE setNameFilters NOTIFY nameFiltersChanged)
    QStringList getNameFilters() { return m_nameFilters; }
    void setNameFilters(QStringList val) { m_nameFilters = val; emit nameFiltersChanged(); loadDelay->start(); }

    Q_PROPERTY(QStringList filenameFilters READ getFilenameFilters WRITE setFilenameFilters NOTIFY filenameFiltersChanged)
    QStringList getFilenameFilters() { return m_filenameFilters; }
    void setFilenameFilters(QStringList val) { m_filenameFilters = val; emit filenameFiltersChanged(); loadDelay->start(); }

    Q_PROPERTY(QStringList mimeTypeFilters READ getMimeTypeFilters WRITE setMimeTypeFilters NOTIFY mimeTypeFiltersChanged)
    QStringList getMimeTypeFilters() { return m_mimeTypeFilters; }
    void setMimeTypeFilters(QStringList val) { m_mimeTypeFilters = val; emit mimeTypeFiltersChanged(); loadDelay->start(); }

    Q_PROPERTY(bool showHidden READ getShowHidden WRITE setShowHidden NOTIFY showHiddenChanged)
    bool getShowHidden() { return m_showHidden; }
    void setShowHidden(bool val) { m_showHidden = val; emit showHiddenChanged(); loadDelay->start(); }

    Q_PROPERTY(SortBy sortField READ getSortField WRITE setSortField NOTIFY sortFieldChanged)
    SortBy getSortField() { return m_sortField; }
    void setSortField(SortBy val) { m_sortField = val; emit sortFieldChanged(); loadDelay->start(); }

    Q_PROPERTY(bool sortReversed READ getSortReversed WRITE setSortReversed NOTIFY sortReversedChanged)
    bool getSortReversed() { return m_sortReversed; }
    void setSortReversed(bool val) { m_sortReversed = val; emit sortReversedChanged(); loadDelay->start(); }

    Q_PROPERTY(int count READ getCount WRITE setCount NOTIFY countChanged)
    int getCount() { return m_count; }
    void setCount(int c) { m_count = c; countChanged(); }

    Q_INVOKABLE QString getFilePath(int index) {
        if(index >= 0 && index < entries.length())
            return entries[index]->filePath;
        return "";
    }

    Q_INVOKABLE QString getFileName(int index) {
        if(index >= 0 && index < entries.length())
            return entries[index]->fileName;
        return "";
    }

    Q_INVOKABLE qint64 getFileSize(int index) {
        if(index >= 0 && index < entries.length())
            return entries[index]->fileSize;
        return 0;
    }

    Q_INVOKABLE QString getFileType(int index) {
        if(index >= 0 && index < entries.length())
            return entries[index]->fileType;
        return "";
    }

    Q_INVOKABLE bool getFileIsDir(int index) {
        if(index >= 0 && index < entries.length())
            return entries[index]->fileIsDir;
        return false;
    }

    Q_INVOKABLE int getIndexOfFile(QString filepath) {
        for(int i = 0; i < entries.length(); ++i) {
            if(entries[i]->filePath == filepath)
                return i;
        }
        return -1;
    }

    Q_INVOKABLE QStringList getCopyOfAllFiles() {
        QStringList ret;
        ret.reserve(allImageFilesInOrder.size());
        for(QFileInfo info : allImageFilesInOrder) {
#ifdef POPPLER
            if(!PQSettings::get().getPdfSingleDocument() && (info.suffix().toLower() == "pdf" || info.suffix().toLower() == "epdf"))
                ret += handlingFileDialog.listPDFPages(info.absoluteFilePath());
            else if(info.suffix().toLower() != "pdf" && info.suffix().toLower() != "epdf") {
                if(!PQSettings::get().getArchiveSingleFile() && PQImageFormats::get().getEnabledFormatsLibArchive().contains(info.suffix().toLower()))
                    ret += handlingFileDialog.listArchiveContent(info.absoluteFilePath());
                else if(!PQImageFormats::get().getEnabledFormatsLibArchive().contains(info.suffix().toLower()))
                    ret.push_back(info.absoluteFilePath());
            } else if(!PQImageFormats::get().getEnabledFormatsLibArchive().contains(info.suffix().toLower()))
#endif
                ret.push_back(info.absoluteFilePath());
        }
        return ret;
    }

    Q_INVOKABLE int setFolderAndImages(QString folder, QStringList allImages);

    QFileInfoList getAllFoldersInFolder();
    QFileInfoList getAllImagesInFolder();
    static QStringList getAllImagesInSubFolders(QString path, bool showHidden, QStringList nameFilters, QStringList mimeTypeFilters, SortBy sortfield, bool sortReversed);

protected:
    QHash<int, QByteArray> roleNames() const {
        QHash<int, QByteArray> roles;
        roles[FileNameRole] = "fileName";
        roles[FilePathRole] = "filePath";
        roles[PathRole] = "path";   // this property *might* be necessary for the drag&drop in PQFileView
        roles[FileSizeRole] = "fileSize";
        roles[FileModifiedRole] = "fileModified";
        roles[FileIsDirRole] = "fileIsDir";
        roles[FileTypeRole] = "fileType";
        return roles;
    }

private:
    QList<PQFileFolderEntry*> entries;

    QString m_folder;
    bool m_ignoreDirs;
    bool m_naturalOrdering;
    QStringList m_nameFilters;
    QStringList m_filenameFilters;
    QStringList m_mimeTypeFilters;
    bool m_showHidden;
    SortBy m_sortField;
    bool m_sortReversed;
    int m_count;

    QTimer *loadDelay;

    QFileSystemWatcher *watcher;

    QFileInfoList allImageFilesInOrder;

    PQHandlingFileDialog handlingFileDialog;

    void loadData(bool setCopyOfData, QStringList allImages, QStringList allDirs);

private slots:
    void loadDataSlot();

signals:
    void newDataLoaded();
    void countChanged();
    void folderChanged();
    void nameFiltersChanged();
    void filenameFiltersChanged();
    void ignoreDirsChanged();
    void naturalOrderingChanged();
    void mimeTypeFiltersChanged();
    void showHiddenChanged();
    void sortFieldChanged();
    void sortReversedChanged();

};

#endif
