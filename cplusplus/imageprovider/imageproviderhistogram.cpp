/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

#include "imageproviderhistogram.h"
#include "loadimage.h"

QPixmap PQImageProviderHistogram::requestPixmap(const QString &fpath, QSize *, const QSize &requestedSize) {

    // Obtain type of histogram
    bool color = false;
    QString tmp = fpath;
    if(tmp.startsWith("color")) {
        color = true;
        tmp = tmp.remove(0,5);
    } else if(tmp.startsWith("grey")) {
        color = false;
        tmp = tmp.remove(0,4);
    }

    // If no path specified, return empty transparent image
    if(tmp.trimmed() == "") {
        QPixmap pix = QPixmap(1,1);
        pix.fill(Qt::transparent);
        return pix;
    }

    bool recalcvalues_filepath = false;
    bool recalcvalues_color = false;
    if(tmp != filepath)
        recalcvalues_filepath = true;
    if(color != colorversion)
        recalcvalues_color = true;
    filepath = tmp;
    colorversion = color;

    // Get width and height
    int w = requestedSize.width();
    int h = requestedSize.height();
    if(w%256 != 0)
        w = (w/256 +1)*256;

    // Get the spacing of the data points
    int interval = w/256;

    if(recalcvalues_filepath || recalcvalues_color) {

        // Retrieve the current image
        if(recalcvalues_filepath) {
            QSize origSize;
            PQLoadImage::load(filepath, QSize(), &origSize, histimg);
        }

        // Read and store image dimensions
        int imgWidth = histimg.width();
        int imgHeight = histimg.height();

        // Prepare the lists for the levels
        levels_grey = new int[256]{};
        levels_red = new int[256]{};
        levels_green = new int[256]{};
        levels_blue = new int[256]{};

        // Loop over all rows of the image
        for(int i = 0; i < imgHeight; ++i) {

            // Get the pixel data of row i of the image
            QRgb *rowData = (QRgb*)histimg.scanLine(i);

            // Loop over all columns
            for(int j = 0; j < imgWidth; ++j) {

                // Get pixel data of pixel at column j in row i
                QRgb pixelData = rowData[j];

                // Get RGB values
                int red = qRed(pixelData);
                int green = qGreen(pixelData);
                int blue = qBlue(pixelData);

                // Add a pixel at current gray level
                if(!colorversion) {
                    // Compute the gray level
                    int gray_level = qGray(red,green,blue);
                    ++levels_grey[gray_level];
                } else {
                    ++levels_red[red];
                    ++levels_green[green];
                    ++levels_blue[blue];
                }

            }

        }

        // Figure out the greatest value for normalisation
        greatestvalue = 0;
        if(!colorversion)
            greatestvalue = *std::max_element(levels_grey, levels_grey+256);
        else {
            int allgreat[3];
            allgreat[0] = *std::max_element(levels_red, levels_red+256);
            allgreat[1] = *std::max_element(levels_green, levels_green+256);
            allgreat[2] = *std::max_element(levels_blue, levels_blue+256);
            greatestvalue = *std::max_element(allgreat, allgreat+3);
        }

    }

    // Set up the needed polygons for filling them with color
    // This has to ALWAYS been done even if only the size changed, as then the interval changes, too
    polyGREY.clear();
    polyRED.clear();
    polyGREEN.clear();
    polyBLUE.clear();
    if(!colorversion) {
        polyGREY << QPoint(0,h);
        for(int i = 0; i < 256; ++i)
            polyGREY << QPoint(i*interval,h*(1-((double)levels_grey[i]/(double)greatestvalue)));
        polyGREY << QPoint(w,h);
    } else {
        polyRED << QPoint(0,h);
        for(int i = 0; i < 256; ++i)
            polyRED << QPoint(i*interval,h*(1-((double)levels_red[i]/(double)greatestvalue)));
        polyRED << QPoint(w,h);
        polyGREEN << QPoint(0,h);
        for(int i = 0; i < 256; ++i)
            polyGREEN << QPoint(i*interval,h*(1-((double)levels_green[i]/(double)greatestvalue)));
        polyGREEN << QPoint(w,h);
        polyBLUE << QPoint(0,h);
        for(int i = 0; i < 256; ++i)
            polyBLUE << QPoint(i*interval,h*(1-((double)levels_blue[i]/(double)greatestvalue)));
        polyBLUE << QPoint(w,h);
    }

    if(recalcvalues_filepath || recalcvalues_color) {
        if(!colorversion)
            delete[] levels_grey;
        else {
            delete[] levels_red;
            delete[] levels_green;
            delete[] levels_blue;
        }
    }

    // Create pixmap...
    QPixmap pix(w,h);
    // ... and fill it with transparent color
    pix.fill(QColor(0,0,0,0));

    // Start painter on return pixmap
    QPainter paint(&pix);

    // set lightly grey colored pen
    paint.setPen(QColor(255,255,255,50));

    // draw outside rectangle
    paint.drawRect(1,1,w-2,h-2);

    // draw mesh lines
    int verticallines = 10;
    int horizontallines = 5;
    for(int i = 0; i < verticallines; ++i)
        paint.drawLine(QPointF((i+1)*(w/(verticallines+1)), 0), QPointF((i+1)*(w/(verticallines+1)), h));
    for(int i = 0; i < horizontallines; ++i)
        paint.drawLine(QPointF(0, (i+1)*(h/(horizontallines+1))), QPointF(w, (i+1)*(h/(horizontallines+1))));

    if(!colorversion) {

        // set pen color
        paint.setPen(QPen(QColor(50,50,50,255),2));
        // draw values
        paint.drawPolygon(polyGREY);
        QPainterPath pathGREY;
        pathGREY.addPolygon(polyGREY);
        paint.fillPath(pathGREY,QColor(150,150,150,180));

    } else {

        // draw red part
        paint.setPen(QPen(QColor(50,50,50,255),2));
        paint.drawPolygon(polyRED);
        QPainterPath pathRED;
        pathRED.addPolygon(polyRED);
        paint.fillPath(pathRED,QColor(255,0,0,120));

        // draw green part
        paint.setPen(QPen(QColor(50,50,50,255),2));
        paint.drawPolygon(polyGREEN);
        QPainterPath pathGREEN;
        pathGREEN.addPolygon(polyGREEN);
        paint.fillPath(pathGREEN,QColor(0,255,0,120));

        // draw blue part
        paint.setPen(QPen(QColor(50,50,50,255),2));
        paint.drawPolygon(polyBLUE);
        QPainterPath pathBLUE;
        pathBLUE.addPolygon(polyBLUE);
        paint.fillPath(pathBLUE,QColor(0,0,255,120));

    }

    paint.end();

    return pix;

}
