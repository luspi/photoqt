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

#ifndef FILEDIALOG_H
#define FILEDIALOG_H

#include <QObject>
#include <QFileDialog>

class FileDialog : public QObject {

    Q_OBJECT

public:
    explicit FileDialog(QObject *parent = 0) : QObject(parent) {
        filedialog = nullptr;
    }

    Q_INVOKABLE void getFilename(QString windowTitle, QString startFile) {

        // Delete old filedialog when one already exists. Otherwise the accepted signal will be fired for each once created filedialog
        if(filedialog != nullptr)
            delete filedialog;

        // store suffix to make sure new file has the same suffix
        this->suffix = QFileInfo(startFile).suffix();

        // Create and open the filedialog (not modal_
        filedialog = new QFileDialog;
        filedialog->setWindowTitle(windowTitle);
        filedialog->setDirectory(QFileInfo(startFile).absolutePath());
        filedialog->selectFile(startFile);
        filedialog->setModal(false);
        filedialog->setNameFilter("*." + suffix);
        filedialog->open();

        // We pass the rejected signal right on, but intercept the accepted one for checking the returned filename
        connect(filedialog, &QFileDialog::rejected, this, &FileDialog::rejected);
        connect(filedialog, &QFileDialog::accepted, this, &FileDialog::diagAccepted);

    }

    Q_INVOKABLE void close() {
        filedialog->close();
    }

private:
    QFileDialog *filedialog;
    QString suffix;

private slots:
    void diagAccepted() {

        // Make sure the new filename has the same suffix as the old filename
        QString fp = filedialog->selectedFiles().at(0);
        if(QFileInfo(fp).suffix() != suffix)
            fp += "." + suffix;

        accepted(fp);

    }

signals:
    void accepted(QString file);
    void rejected();

};

#endif // FILEDIALOG_H
