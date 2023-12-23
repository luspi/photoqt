#include <pqc_photosphere.h>
#include <pqc_photosphererenderer.h>

#include <QSGNode>
#include <QFile>
#include <QFileInfo>

PQCPhotoSphere::PQCPhotoSphere(QQuickItem *parent) : QQuickFramebufferObject(parent), recreateRenderer(false) {
    setFlag(ItemHasContents);
    setTextureFollowsItemSize(true);
    setMirrorVertically(true);
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

    m_azimuth = azimuth;
    updateSphere();
    Q_EMIT azimuthChanged();

}

double PQCPhotoSphere::getElevation() {
    return m_elevation;
}

void PQCPhotoSphere::setElevation(double elevation) {

    if(elevation == m_elevation || !qIsFinite(elevation))
        return;

    elevation = qBound<double>(-90.0, elevation, 90.0);
    m_elevation = elevation;
    updateSphere();
    Q_EMIT elevationChanged();
}

double PQCPhotoSphere::getFieldOfView() {
    return m_fieldOfView;
}

void PQCPhotoSphere::setFieldOfView(double fieldOfView) {

    if(fieldOfView == m_fieldOfView || fieldOfView < 3.0 || fieldOfView > 150.0)
        return;

    m_fieldOfView = fieldOfView;
    updateSphere();
    Q_EMIT fieldOfViewChanged();
}

QString PQCPhotoSphere::getSource() {
    return m_imageUrl;
}

void PQCPhotoSphere::setSource(QString path) {

    qDebug() << "args: path =" << path;

    path = QUrl::fromPercentEncoding(path.toUtf8());

    if(path == "") {
        qDebug() << "Source is empty";
        return;
    }

    if(path != m_imageUrl) {

        QFile file(path);
        if(!file.open(QIODevice::ReadOnly)) {
            qWarning() << "Unable to open file.";
            return;
        }
        QFileInfo info(path);
        QDataStream in(&file);
        QByteArray data(info.size(), 0);
        in.readRawData(data.data(), info.size());

        m_imageUrl = path;
        image = data;

        updateSphere();
        Q_EMIT sourceChanged();
    }

    recreateRenderer = true;

}

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
