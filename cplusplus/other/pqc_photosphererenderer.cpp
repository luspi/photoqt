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

#ifdef PQMPHOTOSPHERE

#include <pqc_photosphererenderer.h>

#include <QOpenGLFramebufferObjectFormat>
#include <QOpenGLFunctions>
#include <QQuickOpenGLUtils>
#include <QOpenGLShaderProgram>
#include <QOpenGLTexture>
#include <QPainter>

PQCPhotoSphereRenderer::PQCPhotoSphereRenderer() {

    shader = nullptr;
    frameBufferObject = nullptr;
    texturePhotoSphere = nullptr;
    window = nullptr;
    source = "";
    oldSource = "";

}

PQCPhotoSphereRenderer::~PQCPhotoSphereRenderer() {
    delete texturePhotoSphere;
}

QOpenGLFramebufferObject *PQCPhotoSphereRenderer::createFramebufferObject(const QSize &size) {

    QOpenGLFramebufferObjectFormat format;
    format.setAttachment(QOpenGLFramebufferObject::CombinedDepthStencil);
    format.setSamples(1);
    frameBufferObject =  new QOpenGLFramebufferObject(size, format);

    return frameBufferObject;

}

void PQCPhotoSphereRenderer::render() {

    QOpenGLFunctions *func = QOpenGLContext::currentContext()->functions();

    const bool texturing = (texturePhotoSphere->isStorageAllocated() && texturePhotoSphere->width()>1);

    func->glClearColor(0, 0, 0, 0);
    func->glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    func->glEnable(GL_DEPTH_TEST);
    func->glDepthFunc(GL_LESS);
    func->glDepthMask(true);

    shader->bind();
    shader->setUniformValue("matrix", theMatrix);
    shader->setUniformValue("samplerImage", 0);
    shader->setUniformValue("color", QColor(0,0,0,255));

    if(texturing) {
        texturePhotoSphere->bind(0);
        sphere.drawSphere();
        texturePhotoSphere->release();
    } else
        sphere.drawSphere();

    shader->release();

    if(window)
        QQuickOpenGLUtils::resetOpenGLState();

}

void PQCPhotoSphereRenderer::synchronize(QQuickFramebufferObject *item) {

    // setup
    if(!shader) {

        shader = new QOpenGLShaderProgram;
        window = item->window();
        sphere.setup();

        // Create shaders
        shader->addShaderFromSourceCode(QOpenGLShader::Vertex, QByteArray("attribute highp vec4 verticalCoordinates;\n attribute highp vec2 verticalTextureCoord;\n uniform highp mat4 matrix;\n varying highp vec2 textureCoordinates;\n void main()\n {\n textureCoordinates = verticalTextureCoord.xy;\n gl_Position = matrix * verticalCoordinates;\n }\n \n"));
        shader->addShaderFromSourceCode(QOpenGLShader::Fragment, QByteArray("#define texture texture2D\n varying highp vec2 textureCoordinates;\n uniform highp vec4 color;\n uniform sampler2D samplerImage; \n void main() {\n lowp vec4 textureColor = texture(samplerImage, textureCoordinates.xy);\n gl_FragColor = vec4(textureColor.rgb, color.a); \n }\n \n"));
        shader->bindAttributeLocation("verticalCoordinates", 0);
        shader->link();

        texturePhotoSphere = new QOpenGLTexture(QOpenGLTexture::Target2D);
    }

    PQCPhotoSphere *sphereItem = qobject_cast<PQCPhotoSphere *>(item);

    // backup previous source
    oldSource = source;

    // store current source
    source = sphereItem->getImage();

    if(!oldSource.isSharedWith(source))
        invalidateFramebufferObject();

    const double w_h = static_cast<double>(sphereItem->width())/static_cast<double>(sphereItem->height());

    QMatrix4x4 matrixProjection;
    matrixProjection.perspective(sphereItem->getFieldOfView(), w_h, 0.001, 200);

    QMatrix4x4 matrixAzimuth;
    matrixAzimuth.rotate(sphereItem->getAzimuth(), 0, 1, 0);

    QMatrix4x4 matrixElevation;
    matrixElevation.rotate(sphereItem->getElevation(), -1, 0, 0);


    theMatrix = QMatrix4x4() * matrixProjection * matrixElevation * matrixAzimuth;

    if(!oldSource.isSharedWith(source)) {

        QImage image;

        // if the stored image is less than the full sphere we pad it with black data
        if(sphereItem->getPartial()) {

            QImage partialImage = QImage::fromData(source);

            image = QImage(sphereItem->getFullSize(), QImage::Format_RGB32);
            image.fill(Qt::black);
            QPainter painter(&image);
            painter.drawImage((sphereItem->getFullSize().width()-sphereItem->getCroppedSize().width())/2, (sphereItem->getFullSize().height()-sphereItem->getCroppedSize().height())/2, partialImage);

        } else
            image = QImage::fromData(source);

        if (image.isNull() || !image.width() || !image.height())
            return;

        texturePhotoSphere->destroy();
        texturePhotoSphere->setData(image);
        texturePhotoSphere->setAutoMipMapGenerationEnabled(true);
        texturePhotoSphere->setMaximumAnisotropy(16);
        texturePhotoSphere->setMinificationFilter(QOpenGLTexture::LinearMipMapLinear);
        texturePhotoSphere->setMagnificationFilter(QOpenGLTexture::Linear);

    }
}

#endif
