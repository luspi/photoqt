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

#include <pqc_photosphere.h>

#ifdef PQMPHOTOSPHERE
#include <pqc_photosphererenderer.h>
#include <pqc_configfiles.h>
#include <pqc_loadimage.h>

#include <QSGNode>
#include <QImage>
#include <QBuffer>

#ifdef PQMEXIV2
#include <exiv2/exiv2.hpp>
#endif

PQCPhotoSphere::PQCPhotoSphere(QQuickItem *parent) : QQuickFramebufferObject(parent), recreateRenderer(false) {
#else
PQCPhotoSphere::PQCPhotoSphere(QQuickItem *parent) : QQuickItem(parent) {
#endif

    m_azimuth = 180;
    m_elevation = 0;
    m_fieldOfView = 90;

    partial = false;

#ifdef PQMPHOTOSPHERE
    setFlag(ItemHasContents);
    setTextureFollowsItemSize(true);
    setMirrorVertically(true);
#endif

}

double PQCPhotoSphere::getAzimuth() {
    return m_azimuth;
}

void PQCPhotoSphere::setAzimuth(double azimuth) {

    if(!qIsFinite(azimuth))
        return;

    azimuth = std::fmod(azimuth, double(360.0));
    if(azimuth < 0.0)
        azimuth += 360.0;

    if(azimuth == m_azimuth)
        return;

#ifdef PQMPHOTOSPHERE
    m_azimuth = azimuth;
    updateSphere();
#endif
    Q_EMIT azimuthChanged();

}

double PQCPhotoSphere::getElevation() {
    return m_elevation;
}

void PQCPhotoSphere::setElevation(double elevation) {

    if(elevation == m_elevation || !qIsFinite(elevation))
        return;

#ifdef PQMPHOTOSPHERE
    m_elevation = qBound<double>(-90.0, elevation, 90.0);
    updateSphere();
#endif
    Q_EMIT elevationChanged();

}

double PQCPhotoSphere::getFieldOfView() {
    return m_fieldOfView;
}

void PQCPhotoSphere::setFieldOfView(double fieldOfView) {

    if(fieldOfView == m_fieldOfView || fieldOfView < 3.0 || fieldOfView > 150.0)
        return;

#ifdef PQMPHOTOSPHERE
    m_fieldOfView = fieldOfView;
    updateSphere();
#endif

    Q_EMIT fieldOfViewChanged();

}

QString PQCPhotoSphere::getSource() {
    return m_imageUrl;
}

void PQCPhotoSphere::setSource(QString path) {

#ifdef PQMPHOTOSPHERE

    path = QUrl::fromPercentEncoding(path.toUtf8());

    if(path == "")
        return;

    if(path != m_imageUrl) {

        QFile file(path);
        if(!file.open(QIODevice::ReadOnly)) {
            qWarning() << "Unable to open file.";
            return;
        }

        // load full image and set as raw data

        QSize s;
        QImage img;
        PQCLoadImage::get().load(path, QSize(), s, img);

        QBuffer buffer(&image);
        buffer.open(QIODevice::WriteOnly);
        img.save(&buffer, "JPG");

        m_imageUrl = path;

#if defined(PQMEXIV2) && defined(PQMEXIV2_ENABLE_BMFF)

#if EXIV2_TEST_VERSION(0, 28, 0)
        Exiv2::Image::UniquePtr image;
#else
        Exiv2::Image::AutoPtr image;
#endif

        try {
            image = Exiv2::ImageFactory::open(path.toStdString());
            image->readMetadata();
        } catch (Exiv2::Error& e) {
            // An error code of kerFileContainsUnknownImageType (older version: 11) means unknown file type \
            // Since we always try to read any file's meta data, this happens a lot
#if EXIV2_TEST_VERSION(0, 28, 0)
            if(e.code() != Exiv2::ErrorCode::kerFileContainsUnknownImageType)
#else
            if(e.code() != 11)
#endif
                qWarning() << "ERROR reading exiv data (caught exception):" << e.what();
            else
                qDebug() << "ERROR reading exiv data (caught exception):" << e.what();

            return;
        }

        Exiv2::XmpData xmpData;
        try {
            xmpData = image->xmpData();
        } catch(Exiv2::Error &e) {
            qDebug() << "ERROR: Unable to read xmp metadata:" << e.what();
            return;
        }

        croppedSize = QSize(-1,-1);
        fullSize = QSize(-1,-1);

        for(Exiv2::XmpData::const_iterator it_xmp = xmpData.begin(); it_xmp != xmpData.end(); ++it_xmp) {

            QString familyName = QString::fromStdString(it_xmp->familyName());
            QString groupName = QString::fromStdString(it_xmp->groupName());
            QString tagName = QString::fromStdString(it_xmp->tagName());

            // check for actual and full dimensions of sphere
            if(familyName == "Xmp" && groupName == "GPano") {
                if(tagName == "CroppedAreaImageHeightPixels")
                    croppedSize.setHeight(QString::fromStdString(Exiv2::toString(it_xmp->value())).toInt());
                else if(tagName == "CroppedAreaImageWidthPixels")
                    croppedSize.setWidth(QString::fromStdString(Exiv2::toString(it_xmp->value())).toInt());
                else if(tagName == "FullPanoHeightPixels")
                    fullSize.setHeight(QString::fromStdString(Exiv2::toString(it_xmp->value())).toInt());
                else if(tagName == "FullPanoWidthPixels")
                    fullSize.setWidth(QString::fromStdString(Exiv2::toString(it_xmp->value())).toInt());
            }

        }

        // we add a small margin to allow for minor inaccuracies in creating the image
        // this will not affect the visible part of the image
        partial = (croppedSize.isValid() && fullSize.isValid() && (croppedSize.width() < fullSize.width()-10 || croppedSize.height() < fullSize.height()-10));

#else
        partial = false;
#endif

        updateSphere();
        Q_EMIT sourceChanged();
    }

    recreateRenderer = true;

#endif

}


QByteArray PQCPhotoSphere::getImage() {
    return image;
}

bool PQCPhotoSphere::getPartial() {
    return partial;
}

QSize PQCPhotoSphere::getCroppedSize() {
    return croppedSize;
}

QSize PQCPhotoSphere::getFullSize() {
    return fullSize;
}

#ifdef PQMPHOTOSPHERE
QSGNode *PQCPhotoSphere::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *updatePaintNodeData) {

    if(oldNode && recreateRenderer) {
        delete oldNode;
        oldNode = nullptr;
        releaseResources();
        recreateRenderer = false;
    }

    return QQuickFramebufferObject::updatePaintNode(oldNode, updatePaintNodeData);

}

QQuickFramebufferObject::Renderer *PQCPhotoSphere::createRenderer() const {
    return new PQCPhotoSphereRenderer;
}

void PQCPhotoSphere::updateSphere() {
    polish();
    update();
}
#endif
