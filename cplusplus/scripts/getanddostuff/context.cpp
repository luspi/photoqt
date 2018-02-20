/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

#include "context.h"

GetAndDoStuffContext::GetAndDoStuffContext(QObject *parent) : QObject(parent) { }
GetAndDoStuffContext::~GetAndDoStuffContext() { }

QStringList GetAndDoStuffContext::getDefaultContextMenuEntries() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffContext::setDefaultContextMenuEntries()" << NL;

#ifdef Q_OS_WIN
    return QStringList();
#endif

    // These are the possible entries
    QStringList m;
    //: Used as in 'Edit with tool abc'
    m << tr("Edit with") + " Gimp" << "gimp %f"
         //: Used as in 'Edit with tool abc'
      << tr("Edit with") + " Krita" << "krita %f"
         //: Used as in 'Edit with tool abc'
      << tr("Edit with") + " KolourPaint" << "kolourpaint %f"
         //: Used as in 'Open in tool abc'
      << tr("Open in") + " GwenView" << "gwenview %f"
         //: Used as in 'Open in tool abc'
      << tr("Open in") + " showFoto" << "showfoto %f"
         //: Used as in 'Open in tool abc'
      << tr("Open in") + " Shotwell" << "shotwell %f"
         //: Used as in 'Open in tool abc'
      << tr("Open in") + " GThumb" << "gthumb %f"
         //: Used as in 'Open in tool abc'
      << tr("Open in") + " Eye of Gnome" << "eog %f";

    QStringList ret;
    // Check for all entries
    for(int i = 0; i < m.size()/2; ++i)
        if(checkIfBinaryExists(m[2*i+1]))
            ret << m[2*i+1] << "0" << m[2*i];

    return ret;

}

QStringList GetAndDoStuffContext::getContextMenu() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffContext::getContextMenu()" << NL;

#ifdef Q_OS_WIN
    return QStringList();
#endif

    QFile file(ConfigFiles::CONTEXTMENU_FILE());

    if(!file.exists()) return getDefaultContextMenuEntries();

    if(!file.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << "GetAndDoStuffContext: ERROR: Can't open contextmenu file" << NL;
        return QStringList();
    }

    QTextStream in(&file);

    QStringList all = in.readAll().split("\n");
    int numRow = 0;
    QStringList ret;
    for(QString line : all) {
        QString tmp = line;
        if(numRow == 0) {
            ret.append(tmp.remove(0,1));
            ret.append(line.remove(1,line.length()));
            ++numRow;
        } else if(numRow == 1) {
            ret.append(line);
            ++numRow;
        } else
            numRow = 0;
    }

    return ret;

}

bool GetAndDoStuffContext::checkIfBinaryExists(QString exec) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffContext::checkIfBinaryExists() - " << exec.toStdString() << NL;

#ifdef Q_OS_WIN
    return false;
#endif

    QProcess p;
    p.setStandardOutputFile(QProcess::nullDevice());
    p.start("which " + exec);
    p.waitForFinished();
    return p.exitCode() == 1;
}

void GetAndDoStuffContext::saveContextMenu(QVariantList l) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffContext::saveContextMenu() - # items in list: " << l.count() << NL;

#ifdef Q_OS_WIN
    return;
#endif

    QMap<int,QVariantList> adj;

    // We re-order the data (use actual position in list as keys), if not deleted
    for(QVariant map : l) {
        QVariantMap data = map.toMap();
        // Invalid data can be caused by deletion
        if(data.value("description").isValid())
            adj.insert(data.value("index").toInt(),QList<QVariant>() << data.value("executable") << data.value("description") << data.value("quit"));
    }

    // Open file
    QFile file(ConfigFiles::CONTEXTMENU_FILE());

    if(file.exists() && !file.remove()) {
        LOG << CURDATE << "GetAndDoStuffContext: ERROR: Failed to remove old contextmenu file" << NL;
        return;
    }

    if(!file.open(QIODevice::WriteOnly)) {
        LOG << CURDATE << "GetAndDoStuffContext: ERROR: Failed to write to contextmenu file" << NL;
        return;
    }

    QTextStream out(&file);

    QList<int> keys = adj.keys();
    std::sort(keys.begin(),keys.end());

    // And save data
    for(int i = 0; i < keys.length(); ++i) {
        int key = keys[i];	// We need to check for the actual keys, as some integers might be skipped (due to deletion)
        QString bin = adj[key][0].toString();
        QString desc = adj[key][1].toString();
        // We need to check for that, as deleting an item otherwise could lead to an empty entry
        if(bin != "" && desc != "") {
            if(i != 0) out << "\n\n";
            out << adj[key][2].toInt() << bin << "\n";
            out << desc;
        }
    }

    file.close();

}
