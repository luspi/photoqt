#include "loader.h"

QImage PLoadImage::Xcftools(QString filename, QSize maxSize) {

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
        return PErrorImage::load("PhotoQt relies on 'xcftools'' to display XCF images, but it wasn't found!");
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
            q = maxSize.width()/static_cast<double>(reader.size().width());
        if(reader.size().height()*q > maxSize.height())
            q = maxSize.height()/static_cast<double>(reader.size().height());
        reader.setScaledSize(reader.size()*q);
    }

    return reader.read();

}
