#ifndef FILEFOLDERMODEL_H
#define FILEFOLDERMODEL_H

#include <QAbstractListModel>
#include <QDateTime>
#include <QDir>
#include <QtDebug>
#include <QTimer>
#include <QCollator>
#include <QFileSystemWatcher>
#include "../logger.h"

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
        if(index >= 0 && index < m_count)
            return entries[index]->filePath;
        return "";
    }

    Q_INVOKABLE QString getFileName(int index) {
        if(index >= 0 && index < m_count)
            return entries[index]->fileName;
        return "";
    }

    Q_INVOKABLE bool getFileIsDir(int index) {
        if(index >= 0 && index < m_count)
            return entries[index]->fileIsDir;
        return false;
    }

    Q_INVOKABLE QStringList getCopyOfAllFiles() {
        QStringList ret;
        ret.reserve(allImageFilesInOrder.size());
        for(QFileInfo info : allImageFilesInOrder)
            ret.push_back(info.filePath());
        return ret;
    }

    Q_INVOKABLE QStringList loadFilesInFolder(QString path, bool showHidden, QStringList nameFilters, SortBy sortField, bool sortReversed) {
        allImageFilesInOrder = getAllImagesInFolder(path, showHidden, nameFilters, sortField, sortReversed);
        return getCopyOfAllFiles();
    }

    static QFileInfoList getAllFoldersInFolder(QString path, bool showHidden, SortBy sortfield, bool sortReversed);
    static QFileInfoList getAllImagesInFolder(QString path, bool showHidden, QStringList nameFilters, SortBy sortfield, bool sortReversed);

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
    bool m_showHidden;
    SortBy m_sortField;
    bool m_sortReversed;
    int m_count;

    QTimer *loadDelay;

    QFileSystemWatcher *watcher;

    QFileInfoList allImageFilesInOrder;

private slots:
    void loadData();

};

#endif
