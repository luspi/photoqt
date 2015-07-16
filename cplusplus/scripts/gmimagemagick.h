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

		std::string magick = getImageMagickString(suf);

		if(magick != "")
			image.magick(magick);

		if(suf == "mono")
			image.size(Magick::Geometry(4000,3000));

		return image;

	}

	std::string getImageMagickString(QString suf) {

		if(suf == "x" || suf == "avs")

			return "AVS";

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
