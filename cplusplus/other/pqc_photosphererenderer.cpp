#include <pqc_photosphererenderer.h>

#include <QOpenGLFramebufferObjectFormat>
#include <QOpenGLFunctions>
#include <QQuickOpenGLUtils>
#include <QOpenGLShaderProgram>
#include <QOpenGLTexture>

PQCPhotoSphereRenderer::PQCPhotoSphereRenderer() {
    shader = nullptr;
    frameBufferObject = nullptr;
    texturePhotoSphere = nullptr;
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
    shader->setUniformValue("samImage", 0);
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
        shader->addShaderFromSourceCode(QOpenGLShader::Vertex, QByteArray("attribute highp vec4 vCoord;\n attribute highp vec2 vTexCoord;\n uniform highp mat4 matrix;\n varying highp vec2 texCoord;\n void main()\n {\n texCoord = vTexCoord.xy;\n gl_Position = matrix * vCoord;\n }\n \n"));
        shader->addShaderFromSourceCode(QOpenGLShader::Fragment, QByteArray("#define texture texture2D\n varying highp vec2 texCoord;\n uniform highp vec4 color;\n uniform sampler2D samImage; \n void main() {\n lowp vec4 texColor = texture(samImage, texCoord.xy);\n gl_FragColor = vec4(texColor.rgb, color.a); \n }\n \n"));
        shader->bindAttributeLocation("vCoord", 0);
        shader->link();

        texturePhotoSphere = new QOpenGLTexture(QOpenGLTexture::Target2D);
    }

    PQCPhotoSphere *sphereItem = qobject_cast<PQCPhotoSphere *>(item);
    oldState = state;
    state.azimuth = sphereItem->getAzimuth();
    state.elevation = sphereItem->getElevation();
    state.fieldOfView = sphereItem->getFieldOfView();
    state.viewportWidth = sphereItem->width();
    state.viewportHeight = sphereItem->height();
    state.source = sphereItem->image;

    if(state == oldState)
        return;

    if (state.viewportHeight != oldState.viewportHeight
        || state.viewportWidth != oldState.viewportWidth)
        invalidateFramebufferObject();

    const double w_h = static_cast<double>(state.viewportWidth)/static_cast<double>(state.viewportHeight);

    QMatrix4x4 matrixProjection;
    matrixProjection.perspective(state.fieldOfView, w_h, 0.001, 200);

    QMatrix4x4 matrixAzimuth;
    matrixAzimuth.rotate(state.azimuth, 0, 1, 0);

    QMatrix4x4 matrixElevation;
    matrixElevation.rotate(state.elevation, -1, 0, 0);


    theMatrix = QMatrix4x4() * matrixProjection * matrixElevation * matrixAzimuth;

    if(oldState.source != state.source) {

        const QImage image = QImage::fromData(state.source);

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
