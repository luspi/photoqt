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

#ifndef GMIMAGEMAGICK_H
#define GMIMAGEMAGICK_H

#include <QString>
#include <iostream>
#include <GraphicsMagick/Magick++.h>

/******************************************************************
 * This class does only one thing, setting the image.magick flag. *
 * This is required in at least two places in the code,           *
 * and is likely to get adjustments in the future.                *
 *																  *
 *          IT IS ONLY TO BE INCLUDED IF 'GM' IS SET !!!          *
 *																  *
 ******************************************************************/

class GmImageMagick {

public:

    explicit GmImageMagick() {}

    Magick::Image setImageMagick(Magick::Image image, QString suf) {

        std::string magick = getImageMagickString(suf.toLower());

        if(magick != "")
            image.magick(magick);

        if(suf == "mono")
            image.size(Magick::Geometry(4000,3000));

        return image;

    }

    std::string getImageMagickString(QString suf) {

        std::string magick = suf.toUpper().toStdString();

        if(suf == "x")

            magick = "AVS";

        else if(suf == "cal" || suf == "dcl"  || suf == "ras")

            magick = "CALS";

        else if(suf == "acr" || suf == "dicom" || suf == "dic")

            magick = "DCM";

        else if(suf == "pct" || suf == "pic")

            magick = "PICT";

        else if(suf == "pal")

            magick = "PIX";

        else if(suf == "wbm")

            magick = "WBMP";

        return magick;
    }
};

#endif // GMIMAGEMAGICK_H
