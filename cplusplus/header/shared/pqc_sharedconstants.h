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
#pragma once

#include <QObject>
#include <QSharedMemory>
#include <QBuffer>
#include <QtDebug>
#include <QVariant>
#include <QImage>

class PQCSharedMemory : public QObject {

    Q_OBJECT

public:
    static PQCSharedMemory& get() {
        static PQCSharedMemory instance;
        return instance;
    }

    PQCSharedMemory(PQCSharedMemory const&) = delete;
    void operator=(PQCSharedMemory const&) = delete;

    // IMAGE FORMATS

    // formats and mime types
    void setImageFormats(QString cat, QStringList lst) { _writeToShared(lst, m_sharedImageformatsEnabledFormats.value(cat)); }
    void setImageFormatsMimeTypes(QString cat, QStringList lst) { _writeToShared(lst, m_sharedImageformatsEnabledMimeTypes.value(cat)); }
    QStringList getImageFormats(QString cat) { QStringList ret; _readFromShared(ret, m_sharedImageformatsEnabledFormats.value(cat)); return ret; }
    QStringList getImageFormatsMimeTypes(QString cat) { QStringList ret; _readFromShared(ret, m_sharedImageformatsEnabledMimeTypes.value(cat)); return ret; }

    void setImageFormatsAllFormats(QVariantList lst) { _writeToShared(lst, m_sharedImageformatsAllFormats); }
    QVariantList getImageFormatsAllFormats() { QVariantList ret; _readFromShared(ret, m_sharedImageformatsAllFormats); return ret; }

    // uniqudid -> endings list
    void setImageFormatsId2Endings(QHash<int, QStringList> lst) { _writeToShared(lst, m_sharedImageformatsId2Endings); }
    QHash<int, QStringList> getImageFormatsId2Endings() { QHash<int, QStringList> ret; _readFromShared(ret, m_sharedImageformatsId2Endings); return ret; }

    // uniqudid -> description
    void setImageFormatsId2Description(QHash<int, QString> lst) { _writeToShared(lst, m_sharedImageformatsId2Description); }
    QHash<int, QString> getImageFormatsId2Description() { QHash<int, QString> ret; _readFromShared(ret, m_sharedImageformatsId2Description); return ret; }

    // ending -> uniqueid
    void setImageFormatsEndings2Id(QHash<QString, int> lst) { _writeToShared(lst, m_sharedImageformatsEndings2Id); }
    QHash<QString, int> getImageFormatsEndings2Id() { QHash<QString, int> ret; _readFromShared(ret, m_sharedImageformatsEndings2Id); return ret; }

    // ending -> qt format name
    void setImageFormatsEnding2QtName(QHash<QString,QString> end) { _writeToShared(end, m_sharedImageformatsEnding2QtName); }
    QHash<QString,QString> getImageFormatsEnding2QtName() { QHash<QString,QString> ret; _readFromShared(ret, m_sharedImageformatsEnding2QtName); return ret; }

    // ending -> magick format name
    void setImageFormatsEnding2MagickName(QHash<QString,QStringList> end) { _writeToShared(end, m_sharedImageformatsEnding2MagickName); }
    QHash<QString,QStringList> getImageFormatsEnding2MagickName() { QHash<QString,QStringList> ret; _readFromShared(ret, m_sharedImageformatsEnding2MagickName); return ret; }

    void setImage(QImage img) { _writeToShared(img, m_sharedImage); }
    QImage getImage() { QImage ret; _readFromShared(ret, m_sharedImage); return ret; }

private:
    PQCSharedMemory() {

        m_sharedImageformatsEnabledFormats.insert("enabled", new QSharedMemory("imageformatsEnabledFormats"));
        m_sharedImageformatsEnabledFormats.insert("poppler", new QSharedMemory("imageformatsEnabledFormatsPoppler"));
        m_sharedImageformatsEnabledFormats.insert("libarchive", new QSharedMemory("imageformatsEnabledFormatsLibArchive"));
        m_sharedImageformatsEnabledFormats.insert("qt", new QSharedMemory("imageformatsEnabledFormatsQt"));
        m_sharedImageformatsEnabledFormats.insert("resvg", new QSharedMemory("imageformatsEnabledFormatsResvg"));
        m_sharedImageformatsEnabledFormats.insert("magick", new QSharedMemory("imageformatsEnabledFormatsMagick"));
        m_sharedImageformatsEnabledFormats.insert("libmpv", new QSharedMemory("imageformatsEnabledFormatsLibmpv"));
        m_sharedImageformatsEnabledFormats.insert("video", new QSharedMemory("imageformatsEnabledFormatsVideo"));
        m_sharedImageformatsEnabledFormats.insert("libraw", new QSharedMemory("imageformatsEnabledFormatsLibraw"));
        m_sharedImageformatsEnabledFormats.insert("libvips", new QSharedMemory("imageformatsEnabledFormatsLibvips"));
        m_sharedImageformatsEnabledFormats.insert("devil", new QSharedMemory("imageformatsEnabledFormatsDevil"));
        m_sharedImageformatsEnabledFormats.insert("freeimage", new QSharedMemory("imageformatsEnabledFormatsFreeImage"));

        m_sharedImageformatsEnabledMimeTypes.insert("enabled", new QSharedMemory("imageformatsEnabledMimeTypes"));
        m_sharedImageformatsEnabledMimeTypes.insert("poppler", new QSharedMemory("imageformatsEnabledMimeTypesPoppler"));
        m_sharedImageformatsEnabledMimeTypes.insert("libarchive", new QSharedMemory("imageformatsEnabledMimeTypesLibArchive"));
        m_sharedImageformatsEnabledMimeTypes.insert("qt", new QSharedMemory("imageformatsEnabledMimeTypesQt"));
        m_sharedImageformatsEnabledMimeTypes.insert("resvg", new QSharedMemory("imageformatsEnabledMimeTypesResvg"));
        m_sharedImageformatsEnabledMimeTypes.insert("magick", new QSharedMemory("imageformatsEnabledMimeTypesMagick"));
        m_sharedImageformatsEnabledMimeTypes.insert("libmpv", new QSharedMemory("imageformatsEnabledMimeTypesLibmpv"));
        m_sharedImageformatsEnabledMimeTypes.insert("video", new QSharedMemory("imageformatsEnabledMimeTypesVideo"));
        m_sharedImageformatsEnabledMimeTypes.insert("libraw", new QSharedMemory("imageformatsEnabledMimeTypesLibraw"));
        m_sharedImageformatsEnabledMimeTypes.insert("libvips", new QSharedMemory("imageformatsEnabledMimeTypesLibvips"));
        m_sharedImageformatsEnabledMimeTypes.insert("devil", new QSharedMemory("imageformatsEnabledMimeTypesDevil"));
        m_sharedImageformatsEnabledMimeTypes.insert("freeimage", new QSharedMemory("imageformatsEnabledMimeTypesFreeImage"));

        m_sharedImageformatsAllFormats = new QSharedMemory("imageformatsAllFormats");

        m_sharedImageformatsEnding2QtName = new QSharedMemory("imageformatsEnding2Qt");
        m_sharedImageformatsEnding2MagickName = new QSharedMemory("imageformatsEnding2Magick");

        m_sharedImageformatsId2Endings = new QSharedMemory("imageformatsId2Endings");
        m_sharedImageformatsId2Description = new QSharedMemory("imageformatsId2Description");
        m_sharedImageformatsEndings2Id = new QSharedMemory("imageformatsEndings2Id");

        m_sharedImage = new QSharedMemory("image");

    }
    ~PQCSharedMemory() {
        for(QSharedMemory *m : std::as_const(m_sharedImageformatsEnabledFormats))
            delete m;
        for(QSharedMemory *m : std::as_const(m_sharedImageformatsEnabledMimeTypes))
            delete m;

        delete m_sharedImageformatsAllFormats;
        delete m_sharedImageformatsEnding2QtName;
        delete m_sharedImageformatsEnding2MagickName;
        delete m_sharedImageformatsId2Endings;
        delete m_sharedImageformatsId2Description;
        delete m_sharedImageformatsEndings2Id;
        delete m_sharedImage;
    }

    template <typename T>
    bool _writeToShared(T &lst, QSharedMemory *mem) {

        QByteArray byteArray;
        QBuffer buffer(&byteArray);
        buffer.open(QIODevice::WriteOnly);

        QDataStream out(&buffer);
        out << lst;
        buffer.close();

        // this is necessary on Linux!
        // When the application crashes, the memory might not be released causing the create to fail
        // These two calls fail in that case (we don't care about that though) but release the memory.
        mem->attach();
        mem->detach();

        if(!mem->create(byteArray.size())) {
            qFatal() << "ERROR allocation shared memory:" << mem->errorString();
            return false;
        }
        mem->lock();
        std::memcpy(mem->data(), byteArray.data(), byteArray.size());
        mem->unlock();

        return true;

    }

    template <typename T>
    bool _readFromShared(T &lst, QSharedMemory *mem) {

        mem->lock();
        QByteArray byteArray((char*)mem->constData(), mem->size());
        mem->unlock();

        QBuffer buffer(&byteArray);
        buffer.open(QIODevice::ReadOnly);

        QDataStream in(&buffer);
        in >> lst;
        buffer.close();

        return true;

    }

    QHash<QString, QSharedMemory*> m_sharedImageformatsEnabledFormats;
    QHash<QString, QSharedMemory*> m_sharedImageformatsEnabledMimeTypes;
    QSharedMemory *m_sharedImageformatsAllFormats;
    QSharedMemory *m_sharedImageformatsEnding2QtName;
    QSharedMemory *m_sharedImageformatsEnding2MagickName;
    QSharedMemory *m_sharedImageformatsId2Endings;
    QSharedMemory *m_sharedImageformatsId2Description;
    QSharedMemory *m_sharedImageformatsEndings2Id;

    QSharedMemory *m_sharedImage;

};
