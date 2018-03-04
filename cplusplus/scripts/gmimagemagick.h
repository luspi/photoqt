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

        if(suf == "x" || suf == "avs")

            return "AVS";

        else if(suf == "art")

            return "ART";

        else if(suf == "cals" || suf == "cal" || suf == "dcl"  || suf == "ras")

            return "CALS";

        else if(suf == "cgm")

            return "CGM";

        else if(suf == "cut")

            return "CUT";

        else if(suf == "cur")

            return "CUR";

        else if(suf == "acr" || suf == "dcm" || suf == "dicom" || suf == "dic")

            return "DCM";

        else if(suf == "fax")

            return "FAX";

        else if(suf == "ico")

            return "ICO";

        else if(suf == "mono")

            return "MONO";

        else if(suf == "mtv")

            return "MTV";

        else if(suf == "otb")

            return "OTB";

        else if(suf == "palm")

            return "PALM";

        else if(suf == "pfb")

            return "PFB";

        else if(suf == "pict" || suf == "pct" || suf == "pic")

            return "PICT";

        else if(suf == "pix"
            || suf == "pal")

            return "PIX";

        else if(suf == "tga")

            return "TGA";

        else if(suf == "ttf")

            return "TTF";

        else if(suf == "txt")

            return "TXT";

        else if(suf == "wbm"
            || suf == "wbmp")

            return "WBMP";

        return "";
    }
};

#endif // GMIMAGEMAGICK_H
