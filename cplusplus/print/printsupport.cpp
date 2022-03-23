/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

void PQPrintSupport::printFile(QString filename) {

    PQTabImageOptions *imageoptions = new PQTabImageOptions;

    // show the printer dialog with additional options tab
    QPrinter printer(QPrinter::HighResolution);
    QPrintDialog printDialog(&printer, nullptr);
    printDialog.setWindowTitle(tr("Print Photo"));
    printDialog.setOptionTabs({imageoptions});
    if(printDialog.exec() != QDialog::Accepted)
        return;

    // Make sure image provider exists
    if(imageprovider == nullptr)
         imageprovider = new PQImageProviderFull;

    // Get the image
    QPixmap pixmap = QPixmap::fromImage(imageprovider->requestImage(filename, new QSize, QSize()));

    // this is only used to figure out the proper scaling of the viewport below
    QPrinter screenprinter(QPrinter::ScreenResolution);

    // create a painter and create handles for some much used properties
    QPainter painter(&printer);
    QRect viewport = painter.viewport();
    QSize pixsize = pixmap.size()*(printer.resolution()/screenprinter.resolution());

    // scale image to fit to page (if requested)
    if(imageoptions->getScalingFitToPage()) {
        if(pixsize.width() > viewport.width() || pixsize.height() > viewport.height() || imageoptions->getScalingEnlargeSmaller())
            pixsize.scale(viewport.size(), Qt::KeepAspectRatio);
    }

    // get the image position the user selected in the options tab
    int imgPos = imageoptions->getImagePosition();

    // the final position of the image on the page is stored in these
    // these default values are horizontal left and vcertical top
    int x = 0;
    int y = 0;

    // horizontal center
    if((imgPos+1)%3 == 0)
        x = (viewport.width()-pixsize.width())/2;
    // horizontal right
    else if(imgPos%3 == 0)
        x = viewport.width()-pixsize.width();

    // vertical center
    if(imgPos > 3 && imgPos < 7)
        y = (viewport.height()-pixsize.height())/2;
    // vertical bottom
    else if(imgPos > 6)
        y = viewport.height()-pixsize.height();

    // set properties to painter
    painter.setViewport(x, y, pixsize.width(), pixsize.height());
    painter.setWindow(pixmap.rect());

    // and draw final image
    painter.drawPixmap(0, 0, pixmap);

    // done!
    painter.end();

}
