#ifndef PQLOADIMAGE_H
#define PQLOADIMAGE_H

#include <QSize>
#include <QFileInfo>
#include "../settings/imageformats.h"
#include "loader/loadimage_qt.h"
#include "loader/loadimage_gm.h"
#include "loader/loadimage_xcf.h"
#include "loader/loadimage_poppler.h"
#include "loader/loadimage_raw.h"
#include "loader/loadimage_devil.h"
#include "loader/loadimage_freeimage.h"
#include "loader/loadimage_archive.h"
#include "loader/loadimage_unrar.h"

namespace PQLoadImage {

    static int foundExternalUnrar = -1;

    static QString load(QString filename, QSize requestedSize, QSize *origSize, QImage &img) {

        if(filename.trimmed() == "")
            return "";

        QFileInfo info(filename);

        /***********************************************************/
        // Qt image plugins

        if(info.suffix().toLower() == "svg" || info.suffix().toLower() == "svgz" ||
           PQImageFormats::get().getEnabledFileformatsQt().contains("*." + info.suffix().toLower())) {
            img = PQLoadImage::Qt::load(filename, requestedSize, origSize);
            return PQLoadImage::Qt::errormsg;
        }

        if(PQImageFormats::get().getEnabledFileformatsXCF().contains("*." + info.suffix().toLower())) {
            img = PQLoadImage::XCF::load(filename, requestedSize, origSize);
            return PQLoadImage::XCF::errormsg;
        }

        if(PQImageFormats::get().getEnabledFileformatsPoppler().contains("*." + info.suffix().toLower())) {
            img = PQLoadImage::PDF::load(filename, requestedSize, origSize);
            return PQLoadImage::PDF::errormsg;
        }

        if(PQImageFormats::get().getEnabledFileformatsGm().contains("*." + info.suffix().toLower())) {
            img = PQLoadImage::GraphicsMagick::load(filename, requestedSize, origSize);
            return PQLoadImage::GraphicsMagick::errormsg;
        }

        if(PQImageFormats::get().getEnabledFileformatsRAW().contains("*." + info.suffix().toLower())) {
            img = PQLoadImage::Raw::load(filename, requestedSize, origSize);
            return PQLoadImage::Raw::errormsg;
        }

        if(PQImageFormats::get().getEnabledFileformatsDevIL().contains("*." + info.suffix().toLower())) {
            img = PQLoadImage::DevIL::load(filename, requestedSize, origSize);
            return PQLoadImage::DevIL::errormsg;
        }

        if(PQImageFormats::get().getEnabledFileformatsFreeImage().contains("*." + info.suffix().toLower())) {
            img = PQLoadImage::FreeImage::load(filename, requestedSize, origSize);
            return PQLoadImage::FreeImage::errormsg;
        }

        if(info.suffix().toLower() == "rar" || info.suffix().toLower() == "cbr") {
            if(foundExternalUnrar == -1) {
                QProcess which;
                which.setStandardOutputFile(QProcess::nullDevice());
                which.start("which unrar");
                which.waitForFinished();
                foundExternalUnrar = which.exitCode() ? 0 : 1;
            }
            if(foundExternalUnrar == 1) {
                img = PQLoadImage::UNRAR::load(filename, requestedSize, origSize);
                return PQLoadImage::UNRAR::errormsg;
            }
        }

        if(PQImageFormats::get().getEnabledFileformatsArchive().contains("*." + info.suffix().toLower())) {
            img = PQLoadImage::Archive::load(filename, requestedSize, origSize);
            return PQLoadImage::Archive::errormsg;
        }

//        if(PQImageFormats::get().getEnabledFileformatsVideo().contains("*." + info.suffix().toLower()))
//            return "video";

        img = PQLoadImage::Qt::load(filename, requestedSize, origSize);
        return PQLoadImage::Qt::errormsg;

    }

}

#endif // PQLOADIMAGE_H
