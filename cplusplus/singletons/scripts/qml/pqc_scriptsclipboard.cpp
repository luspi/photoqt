/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

#include <QMimeData>
#include <QApplication>
#include <QClipboard>
#include <QUrl>
#include <QTextDocumentFragment>
#include <pqc_loadimage_archive.h>
#include <pqc_configfiles.h>
#include <scripts/qml/pqc_scriptsclipboard.h>
#include <scripts/cpp/pqc_scriptsimages.h>

PQCScriptsClipboard::PQCScriptsClipboard() {
    clipboard = qApp->clipboard();
    connect(clipboard, &QClipboard::dataChanged, this, &PQCScriptsClipboard::clipboardUpdated);
}

PQCScriptsClipboard::~PQCScriptsClipboard() {}

bool PQCScriptsClipboard::areFilesInClipboard() {

    const QMimeData *mimeData = clipboard->mimeData();

    if(mimeData == nullptr)
        return false;

    if(!mimeData->hasUrls())
        return false;

    return true;
}

void PQCScriptsClipboard::copyFilesToClipboard(QStringList files) {

    qDebug() << "args: files =" << files;

    if(files.length() == 0)
        return;

    QMimeData* mimeData = new QMimeData();

    QList<QUrl> allurls;
    for(auto &f : std::as_const(files)) {

        // if we are looking at an image in an archive we need to copy it somewhere dedicated first and copy that one.
        if(f.contains("::ARC::")) {

            QString fname = PQCScriptsImages::get().extractArchiveFileToTempLocation(f);

            if(fname != "")
                allurls.push_back(QUrl::fromLocalFile(fname));
            else
                allurls.push_back(QUrl::fromLocalFile(f));

        } else if(f.contains("::PDF::")) {

            QString fname = PQCScriptsImages::get().extractDocumentPageToTempLocation(f);

            if(fname != "")
                allurls.push_back(QUrl::fromLocalFile(fname));
            else
                allurls.push_back(QUrl::fromLocalFile(f));

        } else

            allurls.push_back(QUrl::fromLocalFile(f));
    }
    mimeData->setUrls(allurls);
    clipboard->setMimeData(mimeData);

}

QStringList PQCScriptsClipboard::getListOfFilesInClipboard() {

    qDebug() << "";

    const QMimeData *mimeData = clipboard->mimeData();

    if(mimeData == nullptr)
        return QStringList();

    if(!mimeData->hasUrls())
        return QStringList();

    QList<QUrl> allurls = mimeData->urls();

    QStringList ret;
    for(auto &u : std::as_const(allurls))
        ret << u.toLocalFile();

    return ret;

}

void PQCScriptsClipboard::copyTextToClipboard(QString txt, bool removeHTML) {

    qDebug() << "args: txt.length =" << txt.length();
    qDebug() << "args: removeHTML =" << removeHTML;

    if(removeHTML)
        txt = QTextDocumentFragment::fromHtml(txt).toPlainText();

    clipboard->setText(txt, QClipboard::Clipboard);

}

QString PQCScriptsClipboard::getTextFromClipboard() {

    qDebug() << "";

    return clipboard->text();

}
