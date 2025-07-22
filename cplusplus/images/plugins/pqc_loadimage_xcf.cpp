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

#include <pqc_loadimage_xcf.h>
#include <pqc_imagecache.h>
#include <scripts/cpp/pqc_scriptsimages.h>
#include <scripts/cpp/pqc_scriptscolorprofiles.h>
#include <pqc_notify_cpp.h>
#include <QProcess>
#include <QDir>
#include <QImageReader>

PQCLoadImageXCF::PQCLoadImageXCF() {}

// loads the png and returns the size
QSize PQCLoadImageXCF::loadSize(QString filename) {

    qDebug() << "args: filename =" << filename;

    // We first check if xcftools is actually installed
    QProcess which;
    which.setStandardOutputFile(QProcess::nullDevice());
    which.start("which", QStringList() << "xcf2png");
    which.waitForFinished();
    // If it isn't -> display error
    if(which.exitCode()) {
        qWarning() << "'xcftools' not found";
        return QSize();
    }

    // Convert xcf to png using xcf2png (part of xcftools)
    QProcess p;
    p.execute("xcf2png", QStringList() << filename << "-o" << QString(QDir::tempPath() + "/photoqt_xcf.png"));
    // And load it
    QImageReader reader(QDir::tempPath() + "/photoqt_xcf.png");
    const QSize orig = reader.size();

    QFile::remove(QDir::tempPath() + "/photoqt_xcf.png");

    return orig;

}

// loads the png and returns it
QString PQCLoadImageXCF::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: maxSize =" << maxSize;

    QString errormsg = "";

    // We first check if xcftools is actually installed
    QProcess which;
    which.setStandardOutputFile(QProcess::nullDevice());
    which.start("which", QStringList() << "xcf2png");
    which.waitForFinished();
    // If it isn't -> display error
    if(which.exitCode()) {
        errormsg = "'xcftools' not found";
        qWarning() << errormsg;
        return errormsg;
    }

    // Convert xcf to png using xcf2png (part of xcftools)
    QProcess p;
    p.execute("xcf2png", QStringList() << filename << "-o" << QString(QDir::tempPath() + "/photoqt_xcf.png"));

    // And load it
    QImageReader reader(QDir::tempPath() + "/photoqt_xcf.png");

    origSize = reader.size();

    // Make sure image fits into size specified by maxSize
    if(maxSize.width() > 5 && maxSize.height() > 5) {
        QSize dispSize = reader.size();

        if(dispSize.width() > maxSize.width() || dispSize.height() > maxSize.height())
            dispSize = dispSize.scaled(maxSize, Qt::KeepAspectRatio);

        reader.setScaledSize(dispSize);
    }

    img = reader.read();

    if(img.isNull()) {
        errormsg = "Invalid PNG image rendered by xcftools.";
        qWarning() << errormsg;
        return errormsg;
    }

    if(img.size() == origSize) {
        PQCScriptsColorProfiles::get().applyColorProfile(filename, img);
        PQCImageCache::get().saveImageToCache(filename, PQCScriptsColorProfiles::get().getColorProfileFor(filename), &img);
    }

    return "";

}
