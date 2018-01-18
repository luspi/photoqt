/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef LOADDIR_H
#define LOADDIR_H

#include <QObject>
#include <QDir>
#include <QDateTime>
#include <QHash>
#include <QCollator>
#include <QAbstractListModel>
#include "../settings/settings.h"
#include "../settings/fileformats.h"
#include "../logger.h"

class MyCppModel;

class LoadDir : public QObject {

    Q_OBJECT

public:
    explicit LoadDir(bool verbose);
    ~LoadDir();

    QFileInfoList loadDir(QString filepath, QString filter);

    void sortList(QFileInfoList *list, QString sortby, bool sortbyAscending);

private:

    bool verbose;

    Settings *settings;
    FileFormats *fileformats;

    QStringList imageFilter;

    QFileInfoList allImgsInfo;

};

#endif // LOADDIR_H
