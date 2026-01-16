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

#include "pqc_photosphereitem.h"

#include <QOpenGLFunctions>

PQCPhotoSphereItem::PQCPhotoSphereItem() {

    const int sectors = 64;
    const int stacks = 32;

    const double di = 0.015625; // == 1/64 -> 64 sectors
    const double dj = 0.03125;   // == 1/32 -> 32 stacks

    const double dAzi = di * 2.0 * M_PI;
    const double dElev = dj * M_PI;

    // horizontal
    for(int iSectors = 0; iSectors < sectors; iSectors += 1) {

        // vertical
        for(int iStacks = 0; iStacks < stacks; iStacks += 1)  {

            const double curSector = iSectors*di;
            const double curStack = iStacks*dj;

            // rotated 90 degrees to make 0 point to north
            double azimuth = (curSector * 2 * M_PI) + (M_PI_2);

            double elevation = (M_PI_2) - curStack * M_PI;

            QVector3D bottom_left(cos(azimuth) * cos(elevation - dElev),
                                  sin(elevation - dElev),
                                  -sin(azimuth) * cos(elevation - dElev));

            QVector3D bottom_right(cos(azimuth + dAzi) * cos(elevation - dElev),
                                   sin(elevation - dElev),
                                   -sin(azimuth + dAzi) * cos(elevation - dElev));

            QVector3D top_right(cos(azimuth + dAzi) * cos(elevation),
                                sin(elevation),
                                -sin(azimuth + dAzi) * cos(elevation));

            QVector3D top_left(cos(azimuth) * cos(elevation),
                               sin(elevation),
                               -sin(azimuth) * cos(elevation));

            // set values to zero that are within epsilon of zero
            for(int c = 0 ; c < 3; ++c) {
                if(qFuzzyIsNull(bottom_left[c]))
                    bottom_left[c] = 0;
                if(qFuzzyIsNull(bottom_right[c]))
                    bottom_right[c] = 0;
                if(qFuzzyIsNull(top_right[c]))
                    top_right[c] = 0;
                if(qFuzzyIsNull(top_left[c]))
                    top_left[c] = 0;
            }

            QVector2D texture_bottom_left(1.0-curSector,
                                          curStack+dj);
            QVector2D texture_bottom_right(1.0-curSector-di,
                                           curStack+dj);
            QVector2D texture_top_right(1.0-curSector-di,
                                        curStack);
            QVector2D texture_top_left(1.0-curSector,
                                       curStack);

            sphereVertices << bottom_left
                           << top_left
                           << top_right
                           << bottom_left
                           << top_right
                           << bottom_right;

            textureCoords << texture_bottom_left
                          << texture_top_left
                          << texture_top_right
                          << texture_bottom_left
                          << texture_top_right
                          << texture_bottom_right;
        }
    }
}

void PQCPhotoSphereItem::setup() {

    // only do it once
    if(isSetup)
        return;
    isSetup = true;

    // create vertices buffer
    vertexDataBuffer.create();
    vertexDataBuffer.bind();
    vertexDataBuffer.allocate(&sphereVertices.front(), sphereVertices.size() * sizeof(QVector3D));
    vertexDataBuffer.setUsagePattern(QOpenGLBuffer::StaticDraw);
    vertexDataBuffer.release();

    // create texture coordinates
    textureCoordinateBuffer.create();
    textureCoordinateBuffer.bind();
    textureCoordinateBuffer.allocate(&textureCoords.front(), textureCoords.size() * sizeof(QVector2D));
    textureCoordinateBuffer.setUsagePattern(QOpenGLBuffer::StaticDraw);
    textureCoordinateBuffer.release();

    QOpenGLVertexArrayObject::Binder vertexArrowObjectBinder(&vertexArrowObject); // creates
    QOpenGLFunctions *func = QOpenGLContext::currentContext()->functions();

    vertexDataBuffer.bind();
    func->glEnableVertexAttribArray(0);
    func->glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
    vertexDataBuffer.release();

    textureCoordinateBuffer.bind();
    func->glEnableVertexAttribArray(1);
    func->glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, 0);
    textureCoordinateBuffer.release();

}

void PQCPhotoSphereItem::drawSphere() {
    QOpenGLVertexArrayObject::Binder vertexArrowBinderBinder(&vertexArrowObject);
    QOpenGLContext::currentContext()->functions()->glDrawArrays(GL_TRIANGLES, 0, sphereVertices.size());
}

#endif
