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

#include <QProcess>
#include <QDir>

#include "../../logger.h"
#include "errorimage.h"
#include <thread>

namespace PLoadImage {

    namespace UNRAR {

        static QImage load(QString filename, QSize maxSize) {

            if(qgetenv("PHOTOQT_DEBUG") == "yes")
                LOG << CURDATE << "PLoadImage::UNRAR::load(): Load image using unrar: " << QFileInfo(filename).fileName().toStdString() << NL;

            // If no archive info is stored, return error image
            if(!filename.contains("::ARCHIVE1::") || !filename.contains("::ARCHIVE2::")) {

                QString suffix = QFileInfo(filename).suffix();

                QStringList knownSuffix = QStringList() << "cbz" << "cbr" << "cbt" << "cb7" << "zip" << "rar" << "tar" << "7z";

                QImage ret;

                if(knownSuffix.contains(suffix))
                    ret = QImage(QString(":/img/openfile/archive/%1.png").arg(suffix));
                else
                    ret = QImage(":/img/openfile/archive/zip.png");

                // This is to make sure that this type of thumbnail is not cached (pretends to be error image)
                ret.setText("error", "error");

                // If image needs to be scaled down, return scaled down version
                if(maxSize.width() > 5 && maxSize.height() > 5)
                    if(ret.width() > maxSize.width() || ret.height() > maxSize.height())
                        return ret.scaled(maxSize, ::Qt::KeepAspectRatio);

                return ret;

            }

            // filter out name of archivefile and of compressed file inside
            QString archivefile = filename.split("::ARCHIVE1::").at(1).split("::ARCHIVE2::").at(0);
            QString compressedFilename = filename.split("::ARCHIVE2::").at(1);

            if(!QFileInfo(archivefile).exists()) {
                std::stringstream ss;
                ss << "ERROR loading RAR archive, file doesn't seem to exist...";
                LOG << CURDATE << ss.str() << NL;
                return ErrorImage::load(QString::fromStdString(ss.str()));
            }

            // Extract suffix and remove (added on to signal archive compressed file, not part of actual compressed filename)
            QString suffix = QFileInfo(filename).suffix();
            compressedFilename = compressedFilename.remove(compressedFilename.length()-suffix.length()-1, compressedFilename.length());

            // We first check if unrar is actually installed
            QProcess which;
            which.setStandardOutputFile(QProcess::nullDevice());
            which.start("which unrar");
            which.waitForFinished();
            // If it isn't -> display error
            if(which.exitCode()) {
                LOG << CURDATE << "PLoadImage::UNRAR::load(): Error: unrar not found" << NL;
                return PLoadImage::ErrorImage::load("'unrar' not found, unable to load RAR archive.");
            }

            // Extract file to standard output (the -ierr flag moves any other output by unrar to standard error output -> ignored)
            QProcess p;
            p.start(QString("unrar -ierr p \"%1\" \"%2\"").arg(archivefile).arg(compressedFilename));

            // Make sure everything starts off well
            if(!p.waitForStarted()) {
                std::stringstream ss;
                ss << "PLoadImage::UNRAR::load(): ERROR starting unrar to extract file, unable to start process...";
                LOG << CURDATE << ss.str() << NL;
                return ErrorImage::load(QString::fromStdString(ss.str()));
            }

            // This will hold the accumulated image data
            QByteArray imgdata = "";

            // if there is something to read, read it
            while(p.waitForReadyRead())
                imgdata.append(p.readAll());

            // And load image from the read data
            QImage img = QImage::fromData(imgdata);

            // If image data is invalid or something went wrong, show error image
            if(img.isNull()) {
                std::stringstream ss;
                ss << "PLoadImage::UNRAR::load(): Error! Extracted file is not valid image file...";
                LOG << CURDATE << ss.str() << NL;
                return ErrorImage::load(QString::fromStdString(ss.str()));
            }

            // Make sure image fits into size specified by maxSize
            if(maxSize.width() > 5 && maxSize.height() > 5)
                return img.scaled(maxSize, ::Qt::KeepAspectRatio);

            return img;

        }

    }

}
