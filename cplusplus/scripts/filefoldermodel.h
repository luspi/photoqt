#ifndef FILEFOLDERMODEL_H
#define FILEFOLDERMODEL_H

#include <QAbstractListModel>
#include <QDateTime>
#include <QDir>
#include <QtDebug>
#include <QTimer>
#include <QCollator>
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
        else if (role == FilePathRole)
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
    void setFolder(QString val) { qDebug() << "folder changed"; m_folder = val; loadDelay->start(); }

    Q_PROPERTY(bool naturalOrdering READ getNaturalOrdering WRITE setNaturalOrdering)
    bool getNaturalOrdering() { return m_naturalOrdering; }
    void setNaturalOrdering(bool val) { qDebug() << "naturalOrdering changed"; m_naturalOrdering = val; loadDelay->start(); }

    Q_PROPERTY(QStringList nameFilters READ getNameFilters WRITE setNameFilters)
    QStringList getNameFilters() { return m_nameFilters; }
    void setNameFilters(QStringList val) { qDebug() << "nameFilters changed"; m_nameFilters = val; loadDelay->start(); }

    Q_PROPERTY(bool showHidden READ getShowHidden WRITE setShowHidden)
    bool getShowHidden() { return m_showHidden; }
    void setShowHidden(bool val) { qDebug() << "showHidden changed"; m_showHidden = val; loadDelay->start(); }

    Q_PROPERTY(SortBy sortField READ getSortField WRITE setSortField)
    SortBy getSortField() { return m_sortField; }
    void setSortField(SortBy val) { qDebug() << "sortField changed"; m_sortField = val; loadDelay->start(); }

    Q_PROPERTY(bool sortReversed READ getSortReversed WRITE setSortReversed)
    bool getSortReversed() { return m_sortReversed; }
    void setSortReversed(bool val) { qDebug() << "sortReversed changed"; m_sortReversed = val; loadDelay->start(); }

protected:
    QHash<int, QByteArray> roleNames() const {
        QHash<int, QByteArray> roles;
        roles[FileNameRole] = "fileName";
        roles[FilePathRole] = "filePath";
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

    QTimer *loadDelay;

private slots:
    void loadData();

};

#endif
