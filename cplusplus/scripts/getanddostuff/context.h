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

#ifndef GETANDDOSTUFFCONTEXT_H
#define GETANDDOSTUFFCONTEXT_H

#include "../../logger.h"
#include <iostream>
#include <QObject>
#include <QStringList>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QVariant>
#include <QDir>
#include <QProcess>
#include <QDateTime>

class GetAndDoStuffContext : public QObject {

    Q_OBJECT

public:
    explicit GetAndDoStuffContext(QObject *parent = 0);
    ~GetAndDoStuffContext();

    QStringList getDefaultContextMenuEntries();
    QStringList getContextMenu();
    void saveContextMenu(QVariantList m);
    bool checkIfBinaryExists(QString exec);

};


#endif // GETANDDOSTUFFCONTEXT_H
