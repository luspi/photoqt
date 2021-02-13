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
        FileIsDirRole
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

        // should be unreachable code
        return QVariant();

    }

    Q_PROPERTY(QString folder READ getFolder WRITE setFolder)
    QString getFolder() { return m_folder; }
    void setFolder(QString val) { m_folder = val; loadDelay->start(); }

    Q_PROPERTY(bool naturalOrdering READ getNaturalOrdering WRITE setNaturalOrdering)
    bool getNaturalOrdering() { return m_naturalOrdering; }
    void setNaturalOrdering(bool val) { m_naturalOrdering = val; loadDelay->start(); }

    Q_PROPERTY(QStringList nameFilters READ getNameFilters WRITE setNameFilters)
    QStringList getNameFilters() { return m_nameFilters; }
    void setNameFilters(QStringList val) { m_nameFilters = val; loadDelay->start(); }

    Q_PROPERTY(QStringList mimeTypeFilters READ getMimeTypeFilters WRITE setMimeTypeFilters)
    QStringList getMimeTypeFilters() { return m_mimeTypeFilters; }
    void setMimeTypeFilters(QStringList val) { m_mimeTypeFilters = val; loadDelay->start(); }

    Q_PROPERTY(bool showHidden READ getShowHidden WRITE setShowHidden)
    bool getShowHidden() { return m_showHidden; }
    void setShowHidden(bool val) { m_showHidden = val; loadDelay->start(); }

    Q_PROPERTY(SortBy sortField READ getSortField WRITE setSortField)
    SortBy getSortField() { return m_sortField; }
    void setSortField(SortBy val) { m_sortField = val; loadDelay->start(); }

    Q_PROPERTY(bool sortReversed READ getSortReversed WRITE setSortReversed)
    bool getSortReversed() { return m_sortReversed; }
    void setSortReversed(bool val) { m_sortReversed = val; loadDelay->start(); }

    Q_PROPERTY(int count READ getCount)
    int getCount() { return m_count; }

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

    Q_INVOKABLE bool getFileIsDir(int index) {
        if(index >= 0 && index < entries.length())
            return entries[index]->fileIsDir;
        return false;
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

    Q_INVOKABLE QStringList loadFilesInFolder(QString path, bool showHidden, QStringList nameFilters, QStringList mimeTypeFilters, SortBy sortField, bool sortReversed) {
        allImageFilesInOrder = getAllImagesInFolder(path, showHidden, nameFilters, mimeTypeFilters, sortField, sortReversed);
        return getCopyOfAllFiles();
    }
    Q_INVOKABLE QStringList loadFilesInSubFolders(QString path, bool showHidden, QStringList nameFilters, QStringList mimeTypeFilters, SortBy sortField, bool sortReversed) {
        return getAllImagesInSubFolders(path, showHidden, nameFilters, mimeTypeFilters, sortField, sortReversed);
    }

    static QFileInfoList getAllFoldersInFolder(QString path, bool showHidden, SortBy sortfield, bool sortReversed);
    static QFileInfoList getAllImagesInFolder(QString path, bool showHidden, QStringList nameFilters, QStringList mimeTypeFilters, SortBy sortfield, bool sortReversed);
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
        return roles;
    }

private:
    QList<PQFileFolderEntry*> entries;

    QString m_folder;
    bool m_naturalOrdering;
    QStringList m_nameFilters;
    QStringList m_mimeTypeFilters;
    bool m_showHidden;
    SortBy m_sortField;
    bool m_sortReversed;
    int m_count;

    QTimer *loadDelay;

    QFileSystemWatcher *watcher;

    QFileInfoList allImageFilesInOrder;

    PQHandlingFileDialog handlingFileDialog;

private slots:
    void loadData();

};

#endif