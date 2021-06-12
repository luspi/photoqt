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

#ifndef PQLOADIMAGEUNRAR_H
#define PQLOADIMAGEUNRAR_H

#include <QProcess>
#include <QDir>

#include "../../logger.h"
#include "../../scripts/handlingfiledir.h"

class PQLoadImageUNRAR {

public:
    PQLoadImageUNRAR() {
        errormsg = "";
    }

    QImage load(QString filename, QSize maxSize, QSize *origSize) {

        errormsg = "";

        // filter out name of archivefile and of compressed file inside
        QString archivefile = filename;
        QString compressedFilename = "";
        if(archivefile.contains("::ARC::")) {
            QStringList parts = archivefile.split("::ARC::");
            archivefile = parts.at(1);
            compressedFilename = parts.at(0);
        } else {
            PQHandlingFileDir handling;
            QStringList cont = handling.listArchiveContent(archivefile);
            if(cont.length() == 0) {
                errormsg = "Unable to list contents of archive file...";
                LOG << CURDATE << "PQLoadImageUNRAR::load() (1): " << errormsg.toStdString() << NL;
                return QImage();
            }
            compressedFilename = cont.at(0).split("::ARC::").at(0);
        }

        if(!QFileInfo::exists(archivefile)) {
            errormsg = "Unable to load RAR archive, file doesn't seem to exist...";
            LOG << CURDATE << "PQLoadImageUNRAR::load() (2): " << errormsg.toStdString() << NL;
            return QImage();
        }

        // We first check if unrar is actually installed
        QProcess which;
        which.setStandardOutputFile(QProcess::nullDevice());
        which.start("which", QStringList() << "unrar");
        which.waitForFinished();
        // If it isn't -> display error
        if(which.exitCode()) {
            errormsg = "'unrar' not found";
            LOG << CURDATE << "PQLoadImageUNRAR::load() (3): " << errormsg.toStdString() << NL;
            return QImage();
        }

        // Extract file to standard output (the -ierr flag moves any other output by unrar to standard error output -> ignored)
        QProcess p;
        p.start("unrar", QStringList() << "-ierr" << "p" << archivefile << compressedFilename);

        // Make sure everything starts off well
        if(!p.waitForStarted()) {
            errormsg = "Unable to start 'unrar' process...";
            LOG << CURDATE << "PQLoadImageUNRAR::load() (4): " << errormsg.toStdString() << NL;
            return QImage();
        }

        // This will hold the accumulated image data
        QByteArray imgdata = "";

        // if there is something to read, read it
        while(p.waitForReadyRead())
            imgdata.append(p.readAll());

        // And load image from the read data
        QImage img = QImage::fromData(imgdata);

        *origSize = img.size();

        // If image data is invalid or something went wrong, show error image
        if(img.isNull()) {
            errormsg = "Extracted file is not valid image file...";
            LOG << CURDATE << "PQLoadImageUNRAR::load() (5): " << errormsg.toStdString() << NL;
            return QImage();
        }

        // Make sure image fits into size specified by maxSize
        if(maxSize.width() > 5 && maxSize.height() > 5)
            return img.scaled(maxSize, ::Qt::KeepAspectRatio);

        return img;

    }

    QString errormsg;

};

#endif // PQLOADIMAGEUNRAR_H
