/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

#include "loadimage_xcf.h"

PQLoadImageXCF::PQLoadImageXCF() {
    errormsg = "";
}

QImage PQLoadImageXCF::load(QString filename, QSize maxSize, QSize *origSize) {

    errormsg = "";

    // We first check if xcftools is actually installed
    QProcess which;
    which.setStandardOutputFile(QProcess::nullDevice());
    which.start("which", QStringList() << "xcf2png");
    which.waitForFinished();
    // If it isn't -> display error
    if(which.exitCode()) {
        errormsg = "'xcftools' not found";
        LOG << CURDATE << "PQLoadImageXCF::load(): " << errormsg.toStdString() << NL;
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

    if(img.isNull()) {
        errormsg = "Invalid PNG image rendered by xcftools.";
        LOG << CURDATE << "PQLoadImageXCF::load(): " << errormsg.toStdString() << NL;
    }

    return img;

}
