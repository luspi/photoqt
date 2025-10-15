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

#ifndef PQC_PHOTOSPHERERENDERER
#define PQC_PHOTOSPHERERENDERER

#ifdef PQMPHOTOSPHERE

#include <QQuickFramebufferObject>
#include <QMatrix4x4>

#include <pqc_photosphere.h>
#include <pqc_photosphereitem.h>

class QOpenGLShaderProgram;
class QOpenGLTexture;

class PQCPhotoSphereRenderer : public QQuickFramebufferObject::Renderer {

public:
    PQCPhotoSphereRenderer();
    ~PQCPhotoSphereRenderer();

    QOpenGLFramebufferObject *createFramebufferObject(const QSize &size) override;

    void render() override;

    void synchronize(QQuickFramebufferObject *item) override;

    QOpenGLShaderProgram *shader;
    QQuickWindow* window;

    QByteArray source;
    QByteArray oldSource;

    QOpenGLFramebufferObject *frameBufferObject;
    QMatrix4x4 theMatrix;

    PQCPhotoSphereItem sphere;
    QOpenGLTexture *texturePhotoSphere;

};

#endif

#endif
