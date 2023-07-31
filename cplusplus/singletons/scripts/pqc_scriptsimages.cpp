#include <QtLogging>
#include <QtDebug>
#include <QIcon>
#include <QFile>
#include <QBuffer>
#include <QFileInfo>
#include <QProcess>
#include <QStringConverter>
#include <QImageReader>
#include <scripts/pqc_scriptsimages.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <pqc_settings.h>
#include <pqc_imageformats.h>
#include <pqc_loadimage.h>

#ifdef LIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif

PQCScriptsImages::PQCScriptsImages() {

}

PQCScriptsImages::~PQCScriptsImages() {

}

QSize PQCScriptsImages::getCurrentImageResolution(QString filename) {

    return PQCLoadImage::get().load(filename);

}

bool PQCScriptsImages::isItAnimated(QString filename) {
    QImageReader reader(filename);
    return (reader.supportsAnimation()&&reader.imageCount()>1);
}

QString PQCScriptsImages::getIconPathFromTheme(QString binary) {

    qDebug() << "args: binary =" << binary;

    // We go through all the themeSearchPath elements
    for(int i = 0; i < QIcon::themeSearchPaths().length(); ++i) {

        // Setup path (this is the most likely directory) and format (PNG)
        QString path = QIcon::themeSearchPaths().at(i) + "/hicolor/32x32/apps/" + binary.trimmed() + ".png";
        if(QFile(path).exists())
            return "file:///" + path;
        else {
            // Also check a smaller version
            path = path.replace("32x32","22x22");
            if(QFile(path).exists())
                return "file:///" + path;
            else {
                // And check 24x24, if not in the two before, it most likely is in here (e.g., shotwell on my system)
                path = path.replace("22x22","24x24");
                if(QFile(path).exists())
                    return "file:///" + path;
            }
        }

        // Do the same checks as above for SVG

        path = path.replace("22x22","32x32").replace(".png",".svg");
        if(QFile(path).exists())
            return "file:///" + path;
        else {
            path = path.replace("32x32","22x22");
            if(QFile(path).exists())
                return "file:///" + path;
            else {
                path = path.replace("22x22","24x24");
                if(QFile(path).exists())
                    return "file:///" + path;
            }
        }
    }

    // Nothing found
    return "";

}

QString PQCScriptsImages::loadImageAndConvertToBase64(QString filename) {

    qDebug() << "args: filename =" << filename;

    filename = PQCScriptsFilesPaths::get().cleanPath(filename);

    QPixmap pix;
    pix.load(filename);
    if(pix.width() > 64 || pix.height() > 64)
        pix = pix.scaled(64,64,Qt::KeepAspectRatio);
    QByteArray bytes;
    QBuffer buffer(&bytes);
    buffer.open(QIODevice::WriteOnly);
    pix.save(&buffer, "PNG");
    return bytes.toBase64();

}

QStringList PQCScriptsImages::listArchiveContent(QString path) {

    qDebug() << "args: path =" << path;

    QStringList ret;

    const QFileInfo info(path);

#ifndef Q_OS_WIN
    QProcess which;
    which.setStandardOutputFile(QProcess::nullDevice());
    which.start("which", QStringList() << "unrar");
    which.waitForFinished();

    if(!which.exitCode() && PQCSettings::get()["filetypesExternalUnrar"].toBool() && (info.suffix() == "cbr" || info.suffix() == "rar")) {

        QProcess p;
        p.start("unrar", QStringList() << "lb" << info.absoluteFilePath());

        if(p.waitForStarted()) {

            QByteArray outdata = "";

            while(p.waitForReadyRead())
                outdata.append(p.readAll());

            auto toUtf16 = QStringDecoder(QStringDecoder::Utf8);
            QStringList allfiles = QString(toUtf16(outdata)).split('\n', Qt::SkipEmptyParts);

            allfiles.sort();
            for(const QString &f : qAsConst(allfiles)) {
                if(PQCImageFormats::get().getEnabledFormatsQt().contains(QFileInfo(f).suffix()))
                    ret.append(QString("%1::ARC::%2").arg(f, path));
            }

        }

    }

    // this either means there is nothing in that archive
    // or something went wrong above with unrar
    if(ret.length() == 0) {

#endif

#ifdef LIBARCHIVE

        // Create new archive handler
        struct archive *a = archive_read_new();

        // We allow any type of compression and format
        archive_read_support_filter_all(a);
        archive_read_support_format_all(a);

        // Read file
        int r = archive_read_open_filename(a, info.absoluteFilePath().toLocal8Bit().data(), 10240);

        // If something went wrong, output error message and stop here
        if(r != ARCHIVE_OK) {
            qWarning() << "ERROR: archive_read_open_filename() returned code of" << r;
            return ret;
        }

        // Loop over entries in archive
        struct archive_entry *entry;
        QStringList allfiles;
        while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

            // Read the current file entry
            // We use the '_w' variant here, as otherwise on Windows this call causes a segfault when a file in an archive contains non-latin characters
            QString filenameinside = QString::fromWCharArray(archive_entry_pathname_w(entry));

            // If supported file format, append to temporary list
            if((PQCImageFormats::get().getEnabledFormatsQt().contains(QFileInfo(filenameinside).suffix())))
                allfiles.append(filenameinside);

        }

        // Sort the temporary list and add to global list
        allfiles.sort();
        for(const QString &f : qAsConst(allfiles))
            ret.append(QString("%1::ARC::%2").arg(f, path));

        // Close archive
        r = archive_read_free(a);
        if(r != ARCHIVE_OK)
            qWarning() << "ERROR: archive_read_free() returned code of" << r;

#endif

#ifndef Q_OS_WIN
    }
#endif

    QCollator collator;
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    collator.setIgnorePunctuation(true);
    collator.setNumericMode(true);

    if(PQCSettings::get()["imageviewSortImagesAscending"].toBool())
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
    else
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });

    return ret;

}

QString PQCScriptsImages::convertSecondsToPosition(int t) {

    int m = t/60;
    int s = t%60;

    QString minutes;
    QString seconds;

    if(m < 10)
        minutes = QString("0%1").arg(m);
    else
        minutes = QString("%1").arg(m);

    if(s < 10)
        seconds = QString("0%1").arg(s);
    else
        seconds = QString("%1").arg(s);

    return QString("%1:%2").arg(minutes, seconds);

}
