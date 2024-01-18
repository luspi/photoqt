/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 ** Adapted from: https://github.com/mpv-player/mpv-examples/            **
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

#ifndef MPVRENDERER_H_
#define MPVRENDERER_H_

#ifdef PQMVIDEOMPV

#include <QtQuick/QQuickFramebufferObject>

#include <mpv/client.h>
#include <mpv/render_gl.h>
#include <pqc_mpvqthelper.h>

class PQCMPVRenderer;

class PQCMPVObject : public QQuickFramebufferObject {

    Q_OBJECT

    mpv_handle *mpv;
    mpv_render_context *mpv_gl;

    friend class PQCMPVRenderer;

public:
    static void on_update(void *ctx);

    PQCMPVObject(QQuickItem * parent = 0);
    virtual ~PQCMPVObject();
    virtual Renderer *createRenderer() const;

public Q_SLOTS:
    void command(const QVariant& params);
    void setProperty(const QString& name, const QVariant& value);
    QVariant getProperty(const QString& name);

Q_SIGNALS:
    void onUpdate();

private Q_SLOTS:
    void doUpdate();
};

#endif

#endif
