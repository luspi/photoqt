#ifndef MPVRENDERER_H_
#define MPVRENDERER_H_

#include <QtQuick/QQuickFramebufferObject>

#include <mpv/client.h>
#include <mpv/render_gl.h>
#include "mpvqthelper.h"

class PQMPVRenderer;

class PQMPVObject : public QQuickFramebufferObject
{
    Q_OBJECT

    mpv_handle *mpv;
    mpv_render_context *mpv_gl;

    friend class PQMPVRenderer;

public:
    static void on_update(void *ctx);

    PQMPVObject(QQuickItem * parent = 0);
    virtual ~PQMPVObject();
    virtual Renderer *createRenderer() const;

public Q_SLOTS:
    void command(const QVariant& params);
    void setProperty(const QString& name, const QVariant& value);

Q_SIGNALS:
    void onUpdate();

private Q_SLOTS:
    void doUpdate();
};

#endif
