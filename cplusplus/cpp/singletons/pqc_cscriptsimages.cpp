#include <cpp/pqc_cscriptsimages.h>
#include <cpp/pqc_imageformats.h>

#include <QtDebug>
#include <QIcon>
#include <QFile>
#include <QBuffer>
#include <QFileInfo>
#include <QCollator>

#ifdef PQMLIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif

PQCCScriptsImages::PQCCScriptsImages() {}

QString PQCCScriptsImages::getIconPathFromTheme(QString binary) {

    qDebug() << "args: binary =" << binary;

    // We go through all the themeSearchPath elements
    for(int i = 0; i < QIcon::themeSearchPaths().length(); ++i) {

        // Setup path (this is the most likely directory) and format (PNG)
        QString path = QIcon::themeSearchPaths().at(i) + "/hicolor/32x32/apps/" + binary.trimmed() + ".png";
        if(QFile(path).exists())
            return "file:" + path;
        else {
            // Also check a smaller version
            path = path.replace("32x32","22x22");
            if(QFile(path).exists())
                return "file:" + path;
            else {
                // And check 24x24, if not in the two before, it most likely is in here (e.g., shotwell on my system)
                path = path.replace("22x22","24x24");
                if(QFile(path).exists())
                    return "file:" + path;
            }
        }

        // Do the same checks as above for SVG

        path = path.replace("22x22","32x32").replace(".png",".svg");
        if(QFile(path).exists())
            return "file:" + path;
        else {
            path = path.replace("32x32","22x22");
            if(QFile(path).exists())
                return "file:" + path;
            else {
                path = path.replace("22x22","24x24");
                if(QFile(path).exists())
                    return "file:" + path;
            }
        }

    }

    // Nothing found
    return "";

}

QString PQCCScriptsImages::loadImageAndConvertToBase64(QString filename) {

    qDebug() << "args: filename =" << filename;

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

QStringList PQCCScriptsImages::listArchiveContentWithoutThread(QString path, QString cacheKey, bool insideFilenameOnly) {

    QStringList ret;

    const QFileInfo info(path);

    if(cacheKey == "") {
        cacheKey = QString("%1::%2::%3::%4").arg(info.lastModified().toMSecsSinceEpoch())
                                            .arg(path)
                                            .arg(true)
                                            // TODO!!!
                                            // .arg(PQCSettingsCPP::get().getImageviewSortImagesAscending())
                                            .arg(insideFilenameOnly);
    }

#ifndef Q_OS_WIN

    // TODO!!!
    // if(PQCSettingsCPP::get().getFiletypesExternalUnrar() && (info.suffix() == "cbr" || info.suffix() == "rar")) {

    //     QProcess which;
    //     which.setStandardOutputFile(QProcess::nullDevice());
    //     which.start("which", QStringList() << "unrar");
    //     which.waitForFinished();

    //     if(!which.exitCode()) {

    //         QProcess p;
    //         p.start("unrar", QStringList() << "lb" << info.absoluteFilePath());

    //         if(p.waitForStarted()) {

    //             QByteArray outdata = "";

    //             while(p.waitForReadyRead())
    //                 outdata.append(p.readAll());

    //             auto toUtf16 = QStringDecoder(QStringDecoder::Utf8);
    //             QStringList allfiles = QString(toUtf16(outdata)).split('\n', Qt::SkipEmptyParts);

    //             allfiles.sort();

    //             if(insideFilenameOnly) {
    //                 for(const QString &f : std::as_const(allfiles)) {
    //                     if(PQCImageFormats::get().getEnabledFormats().contains(QFileInfo(f).suffix().toLower()))
    //                         ret.append(f);
    //                 }
    //             } else {
    //                 for(const QString &f : std::as_const(allfiles)) {
    //                     if(PQCImageFormats::get().getEnabledFormats().contains(QFileInfo(f).suffix().toLower()))
    //                         ret.append(QString("%1::ARC::%2").arg(f, path));
    //                 }
    //             }

    //         }

    //     }

    // }

    // this either means there is nothing in that archive
    // or something went wrong above with unrar
    if(ret.length() == 0) {

#endif

#ifdef PQMLIBARCHIVE

        // Create new archive handler
        struct archive *a = archive_read_new();

        // We allow any type of compression and format
        archive_read_support_filter_all(a);
        archive_read_support_format_all(a);

// Read file
#ifdef Q_OS_WIN
        int r = archive_read_open_filename_w(a, reinterpret_cast<const wchar_t*>(info.absoluteFilePath().utf16()), 10240);
#else
        int r = archive_read_open_filename(a, info.absoluteFilePath().toLocal8Bit().data(), 10240);
#endif

        // If something went wrong, output error message and stop here
        if(r != ARCHIVE_OK) {
            qWarning() << "ERROR: archive_read_open_filename() returned code of" << r;
            qWarning() << "Archive:" << info.absoluteFilePath();
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
            const QFileInfo info(filenameinside);
            if(PQCImageFormats::get().getEnabledFormats().contains(info.suffix().toLower()) || PQCImageFormats::get().getEnabledFormats().contains(info.completeSuffix().toLower()))
                allfiles.append(filenameinside);

        }

        // Sort the temporary list and add to global list
        allfiles.sort();

        if(insideFilenameOnly) {
            ret = allfiles;
        } else {
            for(const QString &f : std::as_const(allfiles))
                ret.append(QString("%1::ARC::%2").arg(f, path));
        }

        // Close archive
        r = archive_read_free(a);
        if(r != ARCHIVE_OK)
            qWarning() << "ERROR: archive_read_free() returned code of" << r;

#endif

#ifndef Q_OS_WIN
    }
#endif

    QCollator collator;
#ifndef PQMWITHOUTICU
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    collator.setIgnorePunctuation(true);
    collator.setNumericMode(true);
#endif

    // TODO!!!
    // if(PQCSettingsCPP::get().getImageviewSortImagesAscending())
        std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
    // else
        // std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });

    archiveContentCache.insert(cacheKey, ret);

    return ret;

}
