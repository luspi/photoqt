/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#include "printsupport.h"
#include "tabimageoptions.h"

/****************************************************************************************/
/* a lot of the logic of this function is in part inspired by GwenView's print handling */
/****************************************************************************************/

void PQPrintSupport::printFile(QString filename) {

    // Make sure image provider exists
    if(imageprovider == nullptr)
         imageprovider = new PQImageProviderFull;

    // Get the image
    const QImage img = imageprovider->requestImage(filename, new QSize, QSize());

    // show the printer dialog with additional options tab
    QPrinter printer(QPrinter::HighResolution);

    // get the starting output filename (directory stored, filename based on image filename)
    QFileInfo info(filename);
    QString fdir = set.value("printOutputDirectory", QDir::currentPath()).toString();
    printer.setOutputFileName(QString("%1/%2.pdf").arg(fdir, info.baseName()));

    // the additional image options tab
    PQTabImageOptions *imageoptions = new PQTabImageOptions(printer.pageLayout().pageSize().rect(QPageSize::Millimeter).size());

    // The print dialog
    QPrintDialog printDialog(&printer, nullptr);
    printDialog.setWindowTitle(tr("Print"));
    printDialog.setOptionTabs({imageoptions});
    if(printDialog.exec() != QDialog::Accepted) {
        delete imageoptions;
        return;
    }

    // store all the settings
    imageoptions->storeNewSettings();
    info.setFile(printer.outputFileName());
    set.setValue("printOutputDirectory", info.absolutePath());

    // create a painter and create handles for some much used properties
    QPainter painter(&printer);
    QRect viewport = painter.viewport();
    QSize imgsize = img.size();

    // scale the image to fit into the page
    if(imageoptions->getScalingFitToPage()) {

        bool imageBiggerThanPaper = imgsize.width() > viewport.width() || imgsize.height() > viewport.height();

        if (imageBiggerThanPaper || imageoptions->getScalingEnlargeSmaller())
            imgsize.scale(viewport.size(), Qt::KeepAspectRatio);

    // scale the image to a certain width/height
    } else if(imageoptions->getScalingScaleTo()) {

        double wImg = imageoptions->getScalingScaleToSize().width();
        double hImg = imageoptions->getScalingScaleToSize().height();
        imgsize.setWidth(int(wImg * printer.resolution()));
        imgsize.setHeight(int(hImg * printer.resolution()));

    // do not scale the image
    } else {

        const double INCHES_PER_METER = 100. / 2.54;
        const int dpmX = img.dotsPerMeterX();
        const int dpmY = img.dotsPerMeterY();

        if (dpmX > 0 && dpmY > 0) {
            double wImg = double(imgsize.width()) / double(dpmX) * INCHES_PER_METER;
            double hImg = double(imgsize.height()) / double(dpmY) * INCHES_PER_METER;
            imgsize.setWidth(int(wImg * printer.resolution()));
            imgsize.setHeight(int(hImg * printer.resolution()));
        }

    }


    // get the image position the user selected in the options tab
    int imgPos = imageoptions->getImagePosition();

    // we are done with this, so delete
    delete imageoptions;

    // the final position of the image on the page is stored in these
    // these default values are horizontal left and vertical top
    int x = 0;
    int y = 0;

    // horizontal center
    if((imgPos-1)%3 == 0)
        x = (viewport.width()-imgsize.width())/2;
    // horizontal right
    else if((imgPos+1)%3 == 0)
        x = viewport.width()-imgsize.width();

    // vertical center
    if(imgPos > 2 && imgPos < 6)
        y = (viewport.height()-imgsize.height())/2;
    // vertical bottom
    else if(imgPos > 5)
        y = viewport.height()-imgsize.height();

    // set properties to painter
    painter.setViewport(x, y, imgsize.width(), imgsize.height());
    painter.setWindow(img.rect());

    // and draw final image
    painter.drawImage(0, 0, img);

    // done!
    painter.end();

}
