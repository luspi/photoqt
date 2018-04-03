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
#include <QImageReader>

#include "../../logger.h"
#include "errorimage.h"

namespace PLoadImage {

    namespace XCF {

        static QImage load(QString filename, QSize maxSize) {

            if(qgetenv("PHOTOQT_DEBUG") == "yes")
                LOG << CURDATE << "LoadImageXCF: Load image using xcftools: " << QFileInfo(filename).fileName().toStdString() << NL;

            // We first check if xcftools is actually installed
            QProcess which;
            which.setStandardOutputFile(QProcess::nullDevice());
            which.start("which xcf2png");
            which.waitForFinished();
            // If it isn't -> display error
            if(which.exitCode()) {
                LOG << CURDATE << "LoadImageXCF: reader xcf - Error: xcftools not found" << NL;
                return PLoadImage::ErrorImage::load("PhotoQt relies on 'xcftools'' to display XCF images, but it wasn't found!");
            }

            // Convert xcf to png using xcf2png (part of xcftools)
            QProcess p;
            p.execute(QString("xcf2png \"%1\" -o %2").arg(filename).arg(QDir::tempPath() + "/photoqt_tmp.png"));

            // And load it
            QImageReader reader(QDir::tempPath() + "/photoqt_tmp.png");

            // Make sure image fits into size specified by maxSize
            if(maxSize.width() > 5 && maxSize.height() > 5) {
                double q = 1;
                if(reader.size().width() > maxSize.width())
                    q = (double)maxSize.width()/(double)reader.size().width();
                if(reader.size().height()*q > maxSize.height())
                    q = (double)maxSize.height()/(double)reader.size().height();
                reader.setScaledSize(reader.size()*q);
            }

            return reader.read();

        }

    }

}
