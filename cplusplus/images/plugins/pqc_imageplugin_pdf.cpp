/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

#include <pqc_imageplugin_pdf.h>
#include <pqc_settingscpp.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <pqc_imagecache.h>

#include <QFile>
#include <QtDebug>

#ifdef PQMPOPPLER
#include <poppler/qt6/poppler-qt6.h>
#endif

#ifdef PQMQTPDF
#include <QtPdf/QPdfDocument>
#include <QtPdf/QtPdf>
#endif

PQCImagePluginPDF::PQCImagePluginPDF(QString settingsDir) : m_settingsDir(settingsDir) {

    m_composedWritableSuffixes = false;

    loadFormats();

}

const QString PQCImagePluginPDF::getDescription(QString suffix) {
    return suffix2description.value(suffix.toLower(), "");
}

const QSet<QString> PQCImagePluginPDF::getSuffixesForFormatByDescription(QString description) {
    QSet<QString> ret;
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            ret.insert(suf);
    }
    return ret;
}

const bool PQCImagePluginPDF::supportsFormatByDescription(QString description) {
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            return true;
    }
    return false;
}

const bool PQCImagePluginPDF::isEnabled(QString description) {
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            return m_suffixes.contains(suf);
    }
    return false;
}

const QSet<QString> PQCImagePluginPDF::getWritableSuffixes() {

    return {};

}

const bool PQCImagePluginPDF::writeImage(QImage img, QString targetPath) {
    return false;
}

const QSize PQCImagePluginPDF::loadSize(QString path) {

    // extract page and totalpage value from path (prepended to path (after filepath))
    int page = 0;
    const int idx = path.indexOf("::PDF::");
    if(idx != -1) {
        page = path.mid(0,idx).toInt();
        path = path.mid(idx+7);
    }

#ifdef PQMPOPPLER

    // Load poppler document and render to QImage
    std::unique_ptr<Poppler::Document> document = Poppler::Document::load(path);
    if(!document || document->isLocked()) {
        qWarning() << "Invalid PDF document, unable to load!";
        return QSize();
    }

    std::unique_ptr<Poppler::Page> p = document->page(page);
    if(p == nullptr) {
        qWarning() << QString("Unable to read page %1").arg(page);
        return QSize();
    }

    return (p->pageSizeF()*(PQCSettingsCPP::get().getFiletypesPDFQuality()/72.0)).toSize();

#endif

#ifdef PQMQTPDF
    QPdfDocument doc;
    doc.load(path);

    QPdfDocument::Error err = doc.error();
    if(err != QPdfDocument::Error::None) {
        qWarning() << "Error occurred loading PDF";
        return QSize();
    }

    QSizeF _pageSize = (doc.pagePointSize(page)/72.0*qApp->primaryScreen()->physicalDotsPerInch())*(PQCSettingsCPP::get().getFiletypesPDFQuality()/72.0);

    return _pageSize.toSize();

#endif

    return QSize();

}

const QImage PQCImagePluginPDF::loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: requestedSize =" << requestedSize;

#if defined(PQMPOPPLER) || defined(PQMQTPDF)
    // extract page and totalpage value from path (prepended to path (after filepath))
    int page = 0;
    const int idx = path.indexOf("::PDF::");
    if(idx != -1) {
        page = path.mid(0,idx).toInt();
        path = path.mid(idx+7);
    }
#endif

#ifdef PQMPOPPLER

    // Load poppler document and render to QImage
    std::unique_ptr<Poppler::Document> document = Poppler::Document::load(path);
    if(!document || document->isLocked()) {
        const QString msg = "Invalid PDF document, unable to load!";;
        error += msg % "\n";
        qWarning() << msg;
        return QImage();
    }
    document->setRenderHint(Poppler::Document::TextAntialiasing);
    document->setRenderHint(Poppler::Document::Antialiasing);
    document->setRenderHint(Poppler::Document::ThinLineShape);
    std::unique_ptr<Poppler::Page> p = document->page(page);
    if(p == nullptr) {
        const QString msg = QString("Unable to read page %1").arg(page);
        error = msg;
        qWarning() << msg;
        return QImage();
    }

    const double quality = PQCSettingsCPP::get().getFiletypesPDFQuality();
    double useQuality = quality;
    if(!requestedSize.isEmpty()) {
        double factor1 = static_cast<qreal>(requestedSize.width())/p->pageSizeF().width();
        double factor2 = static_cast<qreal>(requestedSize.height())/p->pageSizeF().height();
        double factor = qMin(factor1, factor2);
        useQuality = 72.0*factor;
    }

    QImage img = p->renderToImage(useQuality, useQuality);

    if(!img.isNull()) {
        PQCScriptsColorProfiles::get().applyColorProfile(path, img);
        if(requestedSize.isEmpty())
            PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().getColorProfileFor(path), &img);
    }

    origSize = p->pageSize()*(quality/72.0);

    // return render image
    return img;

#endif

#ifdef PQMQTPDF

    QPdfDocument doc;
    QPdfDocument::Error ret = doc.load(path);
    if(ret != QPdfDocument::Error::None) {
        const QString msg = QString("Unable to load pdf using QtPDF: %1").arg(static_cast<int>(ret));
        error += msg % "\n";
        qWarning() << msg;
        return QImage();
    }

    QPdfDocument::Error err = doc.error();
    if(err != QPdfDocument::Error::None) {
        const QString msg = "Error occurred loading PDF";
        error += msg % "\n";
        qWarning() << msg;
        return QImage();
    }

    QSizeF _pageSize = doc.pagePointSize(page)*(PQCSettingsCPP::get().getFiletypesPDFQuality()/72.0);
    origSize = _pageSize.toSize();

    QImage p = doc.render(page, (!requestedSize.isEmpty() ?
                                     origSize.scaled(requestedSize, Qt::KeepAspectRatio) :
                                     origSize));

    if(p.isNull()) {
        const QString msg = QString("Unable to read page %1").arg(page);
        error += msg % "\n";
        qWarning() << msg;
        return QImage();
    }

    // some pdfs don't specify a background
    // in that case the resulting image will have a transparent background
    // to "fix" this we simply draw the image on top of a white image
    QImage img(p.size(), p.format());
    img.fill(Qt::white);
    QPainter paint(&img);
    paint.drawImage(0, 0, p);
    paint.end();

    if(!img.isNull() && requestedSize.isEmpty())
        PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().getColorProfileFor(path), &img);

    return img;

#endif

    return QImage();

}

void PQCImagePluginPDF::setEnabled(QString description, bool enabled) {

}

/***********************************************/

void PQCImagePluginPDF::loadFormats() {

    m_suffixes.clear();
    m_toggledSuffixes.clear();
    m_allSuffixes.clear();

#if defined(PQMPOPPLER) || defined(PQMQTPDF)

    // first we read the toggled suffixes from the settings file
    const QString suffixFilename = m_settingsDir % "/pdf_suffixes";
    QFile suffixFile(suffixFilename);
    if(!suffixFile.open(QIODevice::ReadOnly|QIODevice::Text)) {

        qDebug() << "Failed to open settings file at:" << suffixFilename;

        // these are the ones DISABLED BY DEFAULT
        m_toggledSuffixes << "pdf";

    } else {

        QTextStream suffixIn(&suffixFile);
        const QStringList tmp = suffixIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_toggledSuffixes = QSet<QString>(tmp.begin(), tmp.end());
        suffixFile.close();

    }

    // then we store ALL supported suffixes
    m_allSuffixes = {"pdf"};

    // these are the currently enabled ones
    m_suffixes = m_allSuffixes - m_toggledSuffixes;

    suffix2description = {
        {"pdf", "PDF: Adobe Portable Document Format"}
    };

    /********************************/

    m_mimetypes.clear();
    m_toggledMimetypes.clear();
    m_allMimetypes.clear();

    const QString mimeFilename = m_settingsDir % "/pdf_mimetypes";
    QFile mimeFile(mimeFilename);
    if(!mimeFile.open(QIODevice::ReadOnly|QIODevice::Text)) {

        qDebug() << "Failed to open settings file at:" << mimeFilename;

        // these are the ones DISABLED BY DEFAULT
        m_toggledMimetypes << "application/pdf"
                           << "application/x-pdf"
                           << "application/x-bzpdf"
                           << "application/x-gzpdf";

    } else {

        QTextStream mimeIn(&mimeFile);
        const QStringList tmp = mimeIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_toggledMimetypes = QSet<QString>(tmp.begin(), tmp.end());
        mimeFile.close();

    }

    // then we store ALL supported mimetypes
    m_allMimetypes = {"application/pdf", "application/x-pdf", "application/x-bzpdf", "application/x-gzpdf"};

    // these are the currently enabled ones
    m_mimetypes = m_allMimetypes - m_toggledMimetypes;

    mimetype2description = {
        {"application/pdf",     "PDF: Adobe Portable Document Format"},
        {"application/x-pdf",   "PDF: Adobe Portable Document Format"},
        {"application/x-bzpdf", "PDF: Adobe Portable Document Format"},
        {"application/x-gzpdf", "PDF: Adobe Portable Document Format"}
    };

    Q_EMIT formatsUpdated();

#endif

}

void PQCImagePluginPDF::saveFormats() {

    // TODO

}
