#ifndef PQLOADIMAGEXCF_H
#define PQLOADIMAGEXCF_H

#include <QProcess>
#include <QDir>
#include <QImageReader>

#include "../../logger.h"

class PQLoadImageXCF {

public:
    PQLoadImageXCF() {
        errormsg = "";
    }

    QImage load(QString filename, QSize maxSize, QSize *origSize) {

        errormsg = "";

        // We first check if xcftools is actually installed
        QProcess which;
        which.setStandardOutputFile(QProcess::nullDevice());
        which.start("which", QStringList() << "xcf2png");
        which.waitForFinished();
        // If it isn't -> display error
        if(which.exitCode()) {
            LOG << CURDATE << "LoadImageXCF: reader xcf - Error: xcftools not found" << NL;
            errormsg = "Error: xcftools not found";
            return QImage();
        }

        // Convert xcf to png using xcf2png (part of xcftools)
        QProcess p;
        p.execute("xcf2png", QStringList() << filename << "-o" << QString(QDir::tempPath() + "/photoqt_xcf.png"));

        // And load it
        QImageReader reader(QDir::tempPath() + "/photoqt_xcf.png");

        *origSize = reader.size();


        // Make sure image fits into size specified by maxSize
        if(maxSize.width() > 5 && maxSize.height() > 5) {
            double q = 1;
            if(reader.size().width() > maxSize.width())
                q = (double)maxSize.width()/(double)reader.size().width();
            if(reader.size().height()*q > maxSize.height())
                q = (double)maxSize.height()/(double)reader.size().height();
            reader.setScaledSize(reader.size()*q);
        }

        QImage img = reader.read();

        return img;

    }

    QString errormsg;

};

#endif // PQLOADIMAGEXCF_H
