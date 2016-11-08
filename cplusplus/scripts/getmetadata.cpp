#include "getmetadata.h"

GetMetaData::GetMetaData(QObject *parent) : QObject(parent) {

}


QVariantMap GetMetaData::getExiv2(QString path) {

	QVariantMap returnMap;

	// Clean path
	if(path.startsWith("image://full/"))
		path = path.remove(0,13);
	else if(path.startsWith("file:/"))
		path = path.remove(0,6);

	path = QUrl::fromPercentEncoding(path.toUtf8());
	QFileInfo info(path);

	if(!QFile(path).exists()) {

		returnMap.insert("validfile","0");
		return returnMap;

	} else {

		returnMap.insert("validfile","1");
		returnMap.insert("filesize",QString("%1").arg(info.size()/1024) + " KB");

		// Obtain dimensions (if supported by ImageReader)
		if(QImageReader::supportedImageFormats().contains(info.suffix().toLower().toUtf8())) {
			QSize s = QImageReader(path).size();
			if(s.width() > 0 && s.height() > 0)
				returnMap.insert("dimensions",QString("%1x%2").arg(s.width()).arg(s.height()));
		}

		// These formats known by PhotoQt are supported by exiv2
		QStringList formats;
		formats << "jpeg" << "jpg" << "tif" << "tiff"
			<< "png" << "psd" << "jpeg2000" << "jp2"
			<< "j2k" << "jpc" << "jpf" << "jpx"
			<< "jpm" << "mj2" << "bmp" << "bitmap"
			<< "gif" << "tga";

		// "Unsupported"
		if(!formats.contains(info.suffix().toLower())) {

			returnMap.insert("supported","0");
			return returnMap;

		// "Supported"
		} else {

			returnMap.insert("supported","1");

			returnMap.insert("Exif.Image.Make","");
			returnMap.insert("Exif.Image.Model","");
			returnMap.insert("Exif.Image.Software","");
			returnMap.insert("Exif.Image.Orientation","");
			returnMap.insert("Exif.Photo.DateTimeOriginal","");
			returnMap.insert("Exif.Photo.ExposureTime","");
			returnMap.insert("Exif.Photo.Flash","");
			returnMap.insert("Exif.Photo.ISOSpeedRatings","");
			returnMap.insert("Exif.Photo.SceneCaptureType","");
			returnMap.insert("Exif.Photo.FocalLength","");
			returnMap.insert("Exif.Photo.FNumber","");
			returnMap.insert("Exif.Photo.LightSource","");
			returnMap.insert("Exif.Photo.PixelXDimension","");
			returnMap.insert("Exif.Photo.PixelYDimension","");
			returnMap.insert("Exif.GPSInfo.GPSLatitudeRef","");
			returnMap.insert("Exif.GPSInfo.GPSLatitude","");
			returnMap.insert("Exif.GPSInfo.GPSLongitudeRef","");
			returnMap.insert("Exif.GPSInfo.GPSLongitude","");

			returnMap.insert("Iptc.Application2.Keywords","");
			returnMap.insert("Iptc.Application2.City","");
			returnMap.insert("Iptc.Application2.CountryName","");
			returnMap.insert("Iptc.Application2.Copyright","");

#ifdef EXIV2

			// Obtain METADATA

			Exiv2::Image::AutoPtr image;
			try {
				image  = Exiv2::ImageFactory::open(path.toStdString());
				image->readMetadata();
			} catch (Exiv2::Error& e) {
				LOG << CURDATE << "getmetadata - ERROR reading exiv data (caught exception): " << e.what() << NL;
				returnMap.clear();
				returnMap.insert("validfile","0");
				return returnMap;
			}

			/*******************
			* Obtain EXIF data *
			********************/

			Exiv2::ExifData &exifData = image->exifData();
			Exiv2::ExifData::const_iterator exifEnd = exifData.end();
			for (Exiv2::ExifData::const_iterator it_exif = exifData.begin(); it_exif != exifEnd; ++it_exif) {

				// Key/Value
				QString key = QString::fromStdString(it_exif->key());

				if(returnMap.keys().contains(key)) {

					QString value = QString::fromStdString(Exiv2::toString(it_exif->value()));

					// Compose data

					if(key == "Exif.Photo.ExposureTime")
						value = exifExposureTime(value) + " s";

					else if(key == "Exif.Photo.FocalLength")
						value = exifFNumberFLength(value) + " mm";

					else if(key == "Exif.Photo.FNumber")
						value = "F" + exifFNumberFLength(value);

					else if(key == "Exif.Photo.DateTimeOriginal")
						value = exifPhotoTaken(value);

					else if(key == "Exif.Photo.LightSource")
						value = exifLightSource(value);

					else if(key == "Exif.Photo.Flash")
						value = exifFlash(value);

					else if(key == "Exif.Photo.SceneCaptureType")
						value = exifSceneType(value);

					// Store values

					returnMap[key] = value;

				}

			}

			// If GPS is set, compose into one string

			if(returnMap["Exif.GPSInfo.GPSLatitudeRef"] != ""
					&& returnMap["Exif.GPSInfo.GPSLatitude"] != ""
					&& returnMap["Exif.GPSInfo.GPSLongitudeRef"] != ""
					&& returnMap["Exif.GPSInfo.GPSLongitude"] != "") {

				QStringList l = exifGps(returnMap["Exif.GPSInfo.GPSLongitudeRef"].toString(),
							returnMap["Exif.GPSInfo.GPSLongitude"].toString(),
							returnMap["Exif.GPSInfo.GPSLatitudeRef"].toString(),
							returnMap["Exif.GPSInfo.GPSLatitude"].toString());
				returnMap["Exif.GPSInfo.GPSLongitudeRef"] = l.at(0);
				returnMap["Exif.GPSInfo.GPSLatitudeRef"] = l.at(1);

			}

			/*******************
			* Obtain IPTC data *
			********************/

			Exiv2::IptcData &iptcData = image->iptcData();

			Exiv2::IptcData::iterator iptcEnd = iptcData.end();
			for (Exiv2::IptcData::iterator it_iptc = iptcData.begin(); it_iptc != iptcEnd; ++it_iptc) {

				// Key/Value
				QString key = QString::fromStdString(it_iptc->key());

				if(returnMap.keys().contains(key)) {

					QString value = QString::fromStdString(Exiv2::toString(it_iptc->value()));
					returnMap[key] = value;

				}

			}

			QString city = returnMap["Iptc.Application2.City"].toString();
			QString country = returnMap["Iptc.Application2.CountryName"].toString();

			returnMap["Iptc.Application2.City"] = city + ((city != "" && country != "") ? ", " : "") + country;

#endif

			return returnMap;

		}

	}

}



// Format exposure time
QString GetMetaData::exifExposureTime(QString value) {

	if(value.contains("/")) {
		QStringList split = value.split("/");
		if(split.at(0) != "1") {
			int t1 = split.at(0).toInt();
			float t2 = split.at(1).toFloat();
			// I got a bug report of PhotoQt crashing for certain images that have an exposure time
			// of "1/0". So we have to check for it, or we get a division by zero, i.e., crash
			if(t1 == 0) {
				t1 = 0;
				t2 = 0;
				value = "0";
			} else if(t1 != 1) {
				t1 = t1/t1;
				t2 = t2/t1;
				value = QString("%1/%2").arg(t1).arg(t2);
			} else {
				value = QString("%1/%2").arg(t1).arg(t2);
			}
		}

	}

	return value;

}

// Format Focal Length
QString GetMetaData::exifFNumberFLength(QString value) {

	if(value.contains("/")) {
		QStringList split = value.split("/");
		float t1 = split.at(0).toFloat();
		float t2 = split.at(1).toFloat();
		t1 = t1/t2;
		value = QString("%1").arg(t1);
	}

	return value;

}

// Format time the photo was taken
QString GetMetaData::exifPhotoTaken(QString value) {

	QStringList split = value.split(" ");
	QStringList split2 = split.at(0).split(":");
	if(split.length() > 1 && split2.length() > 2)
		value = split2.at(2) + "/" + split2.at(1) + "/" + split2.at(0) + ", " + split.at(1);

	return value;

}

// Compose GPS data
QStringList GetMetaData::exifGps(QString gpsLonRef, QString gpsLon, QString gpsLatRef, QString gpsLat) {

	// Format the latitude string
	QStringList split = gpsLat.split(" ");
	// Some photos have the GPS minutes stored as decimal. That needs to be converted into:
	// - Integer value for minute
	// - Decimal value *60 for seconds
	// This float holds the decimal value (if any)
	float calcSecs = 0;
	for(int i = 0; i < split.length(); ++i) {
		if(split.at(i).contains("/")) {
			float t1 = split.at(i).split("/").at(0).toFloat();
			float t2 = split.at(i).split("/").at(1).toFloat();
			float division = t1/t2;
			// If there's a decimal value...
			if(i == 1 && t2 > 1) {
				calcSecs = division-int(division);
				division = int(division);
			}
			split.replace(i,QString("%1").arg(division));
		}

	}
	// And calculate seconds and set them into third position
	if(calcSecs > 0 && split.length() >= 3)
		split.replace(2,QString::number(split.at(2).toFloat()+calcSecs*60));

	gpsLat = split.at(0) + "°" + split.at(1) + "'" + split.at(2) + "''";

	float secL = (split.at(1).toFloat()*60+split.at(2).toFloat())/3600.0;
	float left = split.at(0).toFloat() + secL;
	if(gpsLatRef == "S") left *= -1;


	// Format the longitude string
	split = gpsLon.split(" ");
	// See above for this float's role
	calcSecs = 0;
	for(int i = 0; i < split.length(); ++i) {
		if(split.at(i).contains("/")) {
			float t1 = split.at(i).split("/").at(0).toFloat();
			float t2 = split.at(i).split("/").at(1).toFloat();
			float division = t1/t2;
			// If there's a decimal value...
			if(i == 1 && t2 > 1) {
				calcSecs = division-int(division);
				division = int(division);
			}
			split.replace(i,QString("%1").arg(division));
		}
	}
	// And calculate seconds and set them into third position
	if(calcSecs > 0 && split.length() >= 3)
		split.replace(2,QString::number(split.at(2).toFloat()+calcSecs*60));
	gpsLon = split.at(0) + "°" + split.at(1) + "'" + split.at(2) + "''";

	float secR = (split.at(1).toFloat()*60+split.at(2).toFloat())/3600.0;
	float right = split.at(0).toFloat() + secR;
	if(gpsLonRef == "W") right *= -1;

	QString value = gpsLat + " " + gpsLatRef + ", " + gpsLon + " " + gpsLonRef;

	QStringList allVal;
	allVal << value << QString("%1 %2").arg(left).arg(right);

	// Compose all the gps data into one string
	return allVal;

}

QString GetMetaData::exifLightSource(QString value) {

	if(value == "0")
		//: This string refers to the light source
		return tr("Unknown");
	else if(value == "1")
		//: This string refers to the light source
		return tr("Daylight");
	else if(value == "2")
		//: This string refers to the light source
		return tr("Fluorescent");
	else if(value == "3")
		//: This string refers to the light source
		return tr("Tungsten (incandescent light)");
	else if(value == "4")
		//: This string refers to the light source
		return tr("Flash");
	else if(value == "9")
		//: This string refers to the light source
		return tr("Fine weather");
	else if(value == "10")
		//: This string refers to the light source
		return tr("Cloudy Weather");
	else if(value == "11")
		//: This string refers to the light source
		return tr("Shade");
	else if(value == "12")
		//: This string refers to the light source
		return tr("Daylight fluorescent") + " (D 5700 - 7100K)";
	else if(value == "13")
		//: This string refers to the light source
		return tr("Day white fluorescent") + " (N 4600 - 5400K)";
	else if(value == "14")
		//: This string refers to the light source
		return tr("Cool white fluorescent") + " (W 3900 - 4500K)";
	else if(value == "15")
		//: This string refers to the light source
		return tr("White fluorescent") + " (WW 3200 - 3700K)";
	else if(value == "17")
		//: This string refers to the light source
		return tr("Standard light") + " A";
	else if(value == "18")
		//: This string refers to the light source
		return tr("Standard light") + " B";
	else if(value == "19")
		//: This string refers to the light source
		return tr("Standard light") + " C";
	else if(value == "20")
		//: This string refers to the light source
		return "D55";
	else if(value == "21")
		//: This string refers to the light source
		return "D65";
	else if(value == "22")
		//: This string refers to the light source
		return "D75";
	else if(value == "23")
		//: This string refers to the light source
		return tr("D50");
	else if(value == "24")
		//: This string refers to the light source
		return tr("ISO studio tungsten");
	else if(value == "255")
		//: This string refers to the light source
		return tr("Other light source");
	else
		//: This string refers to the light source
		return tr("Invalid light source") + " " + value;



}

QString GetMetaData::exifFlash(QString value) {

	//: This string identifies that flash was fired
	QString fYes = tr("yes");
	//: This string identifies that flash wasn't fired
	QString fNo = tr("no");
	//: This string refers to the absense of a flash
	QString fNoFlash = tr("No flash function");
	//: This string refers to a flash mode
	QString fNoStrobe = tr("strobe return light not detected");
	//: This string refers to a flash mode
	QString fYesStrobe = tr("strobe return light detected");
	//: This string refers to a flash mode
	QString fComp = tr("compulsory flash mode");
	//: This string refers to a flash mode
	QString fAuto = tr("auto mode");
	//: This string refers to a flash mode
	QString fRed = tr("red-eye reduction mode");
	//: This string refers to a flash mode
	QString fYesReturn = tr("return light detected");
	//: This string refers to a flash mode
	QString fNoReturn = tr("return light not detected");

	if(value == "0")
		return fYes;
	else if(value == "1")
		return fNo;
	else if(value == "5")
		return fNoStrobe;
	else if(value == "6")
		return fYesStrobe;
	else if(value == "9")
		return fYes + " (" + fComp + ")";
	else if(value == "13")
		return fYes + " (" + fComp + ", " + fNoReturn + ")";
	else if(value == "15")
		return fYes + " (" + fComp + ", " + fYesReturn + ")";
	else if(value == "16")
		return fNo + " (" + fComp + ")";
	else if(value == "24")
		return fNo + " (" + fAuto + ")";
	else if(value == "25")
		return fYes + " (" + fAuto + ")";
	else if(value == "29")
		return fYes + " (" + fAuto + ", " + fNoReturn + ")";
	else if(value == "31")
		return fYes + " (" + fAuto + ", " + fYesReturn + ")";
	else if(value == "32")
		return fNoFlash;
	else if(value == "65")
		return fYes + " (" + fRed + ")";
	else if(value == "69")
		return fYes + " (" + fRed + ", " + fNoReturn + ")";
	else if(value == "71")
		return fYes + " (" + fRed + ", " + fYesReturn + ")";
	else if(value == "73")
		return fYes + " (" + fComp + ", " + fRed + ")";
	else if(value == "77")
		return fYes + " (" + fComp + ", " + fRed + ", " + fNoReturn + ")";
	else if(value == "79")
		return fYes + " (" + fComp + ", " + fRed + ", " + fYesReturn + ")";
	else if(value == "89")
		return fYes + " (" + fAuto + ", " + fRed + ")";
	else if(value == "93")
		return fYes + " (" + fAuto + ", " + fNoReturn + ", " + fRed + ")";
	else if(value == "95")
		return fYes + " (" + fAuto + ", " + fYesReturn + ", " + fRed + ")";
	else
		return tr("Invalid flash") + " " + value;



}

QString GetMetaData::exifSceneType(QString value) {

	if(value == "0")
		//: This string refers to a type of scene
		return tr("Standard");
	else if(value == "1")
		//: This string refers to a type of scene
		return tr("Landscape");
	else if(value == "2")
		//: This string refers to a type of scene
		return tr("Portrait");
	else if(value == "3")
		//: This string refers to a type of scene
		return tr("Night Scene");
	else
		//: This string refers to a type of scene
		return tr("Invalid Scene Type") + " " + value;


}
