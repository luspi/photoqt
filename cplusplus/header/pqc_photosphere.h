/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

#ifndef PQPHOTOSPHERE_H
#define PQPHOTOSPHERE_H

// This is the QML type

#include <QQuickFramebufferObject>

class PQCPhotoSphere : public QQuickFramebufferObject {

    Q_OBJECT
    QML_ELEMENT

public:
    PQCPhotoSphere(QQuickItem *parent = nullptr);

    Q_PROPERTY(double azimuth READ getAzimuth WRITE setAzimuth NOTIFY azimuthChanged)
    double getAzimuth();
    void setAzimuth(double azimuth);

    Q_PROPERTY(double elevation READ getElevation WRITE setElevation NOTIFY elevationChanged)
    double getElevation();
    void setElevation(double elevation);

    Q_PROPERTY(double fieldOfView READ getFieldOfView WRITE setFieldOfView NOTIFY fieldOfViewChanged)
    double getFieldOfView();
    void setFieldOfView(double fieldOfView);

    Q_PROPERTY(QString source READ getSource WRITE setSource NOTIFY sourceChanged)
    QString getSource();
    void setSource(QString path);

    QByteArray getImage();
    bool getPartial();
    QSize getCroppedSize();
    QSize getFullSize();

Q_SIGNALS:
    void azimuthChanged();
    void elevationChanged();
    void fieldOfViewChanged();
    void sourceChanged();

protected:
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *data) override;
    Renderer *createRenderer() const override;
    void updateSphere();

private:
    QByteArray image;
    bool partial;
    QSize croppedSize;
    QSize fullSize;

    double m_azimuth;
    double m_elevation;
    double m_fieldOfView;
    QString m_imageUrl;

    bool recreateRenderer = false;

};

#endif // PQPHOTOSPHERE_H
