#ifndef PQLOADIMAGEUNRAR_H
#define PQLOADIMAGEUNRAR_H

#include <QProcess>
#include <QDir>

#include "../../logger.h"
#include "../../scripts/handlingfiledialog.h"

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
            PQHandlingFileDialog handling;
            QStringList cont = handling.listArchiveContent(archivefile);
            if(cont.length() == 0) {
                errormsg = "Error: unable to list contents of archive file...";
                LOG << CURDATE << "PQLoadImage::UNRAR::load(): " << errormsg.toStdString() << NL;
                return QImage();
            }
            compressedFilename = cont.at(0).split("::ARC::").at(0);
        }

        if(!QFileInfo(archivefile).exists()) {
            errormsg = "ERROR loading RAR archive, file doesn't seem to exist...";
            LOG << CURDATE << "PQLoadImage::UNRAR::load(): " << errormsg.toStdString() << NL;
            return QImage();
        }

        // We first check if unrar is actually installed
        QProcess which;
        which.setStandardOutputFile(QProcess::nullDevice());
        which.start("which", QStringList() << "unrar");
        which.waitForFinished();
        // If it isn't -> display error
        if(which.exitCode()) {
            errormsg = "PQLoadImage::UNRAR::load(): Error: unrar not found";
            LOG << CURDATE << errormsg.toStdString() << NL;
            return QImage();
        }

        // Extract file to standard output (the -ierr flag moves any other output by unrar to standard error output -> ignored)
        QProcess p;
        p.start("unrar", QStringList() << "-ierr" << "p" << archivefile << compressedFilename);

        // Make sure everything starts off well
        if(!p.waitForStarted()) {
            errormsg = "PQLoadImage::UNRAR::load(): ERROR starting unrar to extract file, unable to start process...";
            LOG << CURDATE << errormsg.toStdString() << NL;
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
            errormsg = "PQLoadImage::UNRAR::load(): Error! Extracted file is not valid image file...";
            LOG << CURDATE << errormsg.toStdString() << NL;
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
