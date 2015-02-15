#include "metadata.h"

GetMetaData::GetMetaData(QObject *parent) : QObject(parent) {

	// These QMaps hold the translation for some fields
	mapAll.clear();

	// The light source "translated" into a human-readable format
	QMap<QString,QString> mapLightSource;
	//: This string refers to the light source
	mapLightSource.insert("0",tr("Unknown"));
	//: This string refers to the light source
	mapLightSource.insert("1",tr("Daylight"));
	//: This string refers to the light source
	mapLightSource.insert("2",tr("Fluorescent"));
	//: This string refers to the light source
	mapLightSource.insert("3",tr("Tungsten (incandescent light)"));
	//: This string refers to the light source
	mapLightSource.insert("4",tr("Flash"));
	//: This string refers to the light source
	mapLightSource.insert("9",tr("Fine weather"));
	//: This string refers to the light source
	mapLightSource.insert("10",tr("Cloudy Weather"));
	//: This string refers to the light source
	mapLightSource.insert("11",tr("Shade"));
	//: This string refers to the light source
	mapLightSource.insert("12",tr("Daylight fluorescent (D 5700 - 7100K)"));
	//: This string refers to the light source
	mapLightSource.insert("13",tr("Day white fluorescent (N 4600 - 5400K)"));
	//: This string refers to the light source
	mapLightSource.insert("14",tr("Cool white fluorescent") + "(W 3900 - 4500K)");
	//: This string refers to the light source
	mapLightSource.insert("15",tr("White fluorescent") + "(WW 3200 - 3700K)");
	//: This string refers to the light source
	mapLightSource.insert("17",tr("Standard light") + " A");
	mapLightSource.insert("18",tr("Standard light") + " B");
	mapLightSource.insert("19",tr("Standard light") + " C");
	mapLightSource.insert("20","D55");
	mapLightSource.insert("21","D65");
	mapLightSource.insert("22","D75");
	mapLightSource.insert("23","D50");
	//: This string refers to the light source
	mapLightSource.insert("24",tr("ISO studio tungsten"));
	//: This string refers to the light source
	mapLightSource.insert("255",tr("Other light source"));

	//: This string identifies that flash was fired
	QString fYes = tr("yes");
	//: This string identifies that flash wasn't fired
	QString fNo = tr("no");
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

	// The flash "translated" into a human-readable format
	QMap<QString,QString> mapFlash;
	mapFlash.insert("0",fYes);
	mapFlash.insert("1",fNo);
	mapFlash.insert("5",fNoStrobe);
	mapFlash.insert("6",fYesStrobe);
	mapFlash.insert("9",fYes + " (" + fComp + ")");
	mapFlash.insert("13",fYes + " (" + fComp + ", " + fNoReturn + ")");
	mapFlash.insert("15",fYes + " (" + fComp + ", " + fYesReturn + ")");
	mapFlash.insert("16",fNo + " (" + fComp + ")");
	mapFlash.insert("24",fNo + " (" + fAuto + ")");
	mapFlash.insert("25",fYes + " (" + fAuto + ")");
	mapFlash.insert("29",fYes + " (" + fAuto + ", " + fNoReturn + ")");
	mapFlash.insert("31",fYes + " (" + fAuto + ", " + fYesReturn + ")");
	//: This string refers to a flash mode
	mapFlash.insert("32",tr("No flash function"));
	mapFlash.insert("65",fYes + " (" + fRed + ")");
	mapFlash.insert("69",fYes + " (" + fRed + ", " + fNoReturn + ")");
	mapFlash.insert("71",fYes + " (" + fRed + ", " + fYesReturn + ")");
	mapFlash.insert("73",fYes + " (" + fComp + ", " + fRed + ")");
	mapFlash.insert("77",fYes + " (" + fComp + ", " + fRed + ", " + fNoReturn + ")");
	mapFlash.insert("79",fYes + " (" + fComp + ", " + fRed + ", " + fYesReturn + ")");
	mapFlash.insert("89",fYes + " (" + fAuto + ", " + fRed + ")");
	mapFlash.insert("93",fYes + " (" + fAuto + ", " + fNoReturn + ", " + fRed + ")");
	mapFlash.insert("95",fYes + " (" + fAuto + ", " + fYesReturn + ", " + fRed + ")");

	// The scene type "translated" into a human-readable format
	QMap<QString,QString> mapSceneType;
	//: This string refers to a scene type
	mapSceneType.insert("0",tr("Standard"));
	//: This string refers to a scene type
	mapSceneType.insert("1",tr("Landscape"));
	//: This string refers to a scene type
	mapSceneType.insert("2",tr("Portrait"));
	//: This string refers to a scene type
	mapSceneType.insert("3",tr("Night Scene"));

	// Store these maps in a global map with the internal ids as accessor
	mapAll.insert("Exif.Photo.LightSource",mapLightSource);
	mapAll.insert("Exif.Photo.Flash",mapFlash);
	mapAll.insert("Exif.Photo.SceneCaptureType",mapSceneType);


	// These two maps are used to read out the exif data
	exifKeysValues.clear();
	units.clear();
	exifKeysValues.insert("Exif.Image.Make","make");
	exifKeysValues.insert("Exif.Image.Model","model");
	exifKeysValues.insert("Exif.Image.Software","software");
	exifKeysValues.insert("Exif.Photo.DateTimeOriginal","datetime");
	exifKeysValues.insert("Exif.Photo.ExposureTime","exposuretime");
	units.insert("Exif.Photo.ExposureTime","1 s");
	exifKeysValues.insert("Exif.Photo.Flash","flash");
	exifKeysValues.insert("Exif.Photo.ISOSpeedRatings","iso");
	exifKeysValues.insert("Exif.Photo.SceneCaptureType","scene");
	exifKeysValues.insert("Exif.Photo.FocalLength","focal");
	units.insert("Exif.Photo.FocalLength","1 mm");
	exifKeysValues.insert("Exif.Photo.FNumber","fnumber");
	units.insert("Exif.Photo.FNumber","0F");
	exifKeysValues.insert("Exif.Photo.LightSource","light");
	exifKeysValues.insert("Exif.GPSInfo.GPSLatitudeRef","gps");
	exifKeysValues.insert("Exif.GPSInfo.GPSLatitude","gpsDec");
	exifKeysValues.insert("Exif.GPSInfo.GPSLongitudeRef","gps");
	exifKeysValues.insert("Exif.GPSInfo.GPSLongitude","gpsDec");

}

// Read Exiv2 data
QVariantMap GetMetaData::getExiv2(QString path) {

	// Clean path
	if(path.startsWith("image://full/"))
		path = path.remove(0,12);

	// FileInfo
	QFileInfo info(path);

	// Return map
	QVariantMap ret;

	// Set generic data
	ret.insert("exiv2_type","");
	ret.insert("filename",info.fileName());
	ret.insert("filetype",info.suffix().toLower());
	ret.insert("filesize",QString("%1").arg(info.size()/1024) + " KB");
	bool dimensionSet = false;
	if(QImageReader::supportedImageFormats().contains(info.suffix().toLower().toLatin1())) {
		QSize s = QImageReader(path).size();
		if(s.width() > 0 && s.height() > 0) {
			ret.insert("dimensions",QString("%1x%2").arg(s.width()).arg(s.height()));
			dimensionSet = true;
		}
	}
	if(!dimensionSet)
		ret.insert("dimensions","<i>not set</i>");


	// Default values
	ret.insert("make","<i>not set</i>");
	ret.insert("model","<i>not set</i>");
	ret.insert("software","<i>not set</i>");
	ret.insert("datetime","<i>not set</i>");
	ret.insert("exposuretime","<i>not set</i>");
	ret.insert("flash","<i>not set</i>");
	ret.insert("iso","<i>not set</i>");
	ret.insert("scene","<i>not set</i>");
	ret.insert("focal","<i>not set</i>");
	ret.insert("fnumber","<i>not set</i>");
	ret.insert("light","<i>not set</i>");
	ret.insert("rotation","");
	ret.insert("flip","");
	ret.insert("gps","<i>not set</i>");
	ret.insert("gpsDec","<i>not set</i>");

	// These formats known by PhotoQt are supported by exiv2
	QStringList formats;
	formats << "jpeg"
		<< "jpg"
		<< "tif"
		<< "tiff"
		<< "png"
		<< "psd"
		<< "jpeg2000"
		<< "jp2"
		<< "jpc"
		<< "j2k"
		<< "jpf"
		<< "jpx"
		<< "jpm"
		<< "mj2"
		<< "bmp"
		<< "bitmap"
		<< "gif"
		<< "tga";

	// "Unsupported"
	if(!formats.contains(QFileInfo(path).suffix().toLower()))
		return ret;
	else {

		ret["exiv2_type"] = "Exif";

		Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(path.toStdString());
		image->readMetadata();
		Exiv2::ExifData &exifData = image->exifData();

		QString gpsLonRef = "";
		QString gpsLon = "";
		QString gpsLatRef = "";
		QString gpsLat = "";

		QMapIterator<QString,QString> i(exifKeysValues);
		while(i.hasNext()) {
			i.next();

			QString i_key = i.key();
			QString i_val = i.value();

			try {
				Exiv2::ExifKey k(i_key.toStdString());
				Exiv2::ExifData::const_iterator it = exifData.findKey(k);

				if(it != exifData.end()) {

					QString val = QString::fromStdString(Exiv2::toString(it->value()));

					// Check if value is known
					if(mapAll.contains(i_key)) {
						QMap<QString,QString> m = mapAll[i_key];
						if(m.keys().contains(val))
							val = m[val];
						// If data is in unknown format
						else
							val = "[" + tr("Unknown data") + "]";
					}

					// Some values need to be formatted a little

					if(i_key == "Exif.Photo.ExposureTime")
						val = exifExposureTime(val);

					if(i_key == "Exif.Photo.FocalLength" || i.key() == "Exif.Photo.FNumber")
						val = exifFNumberFLength(val);

					if(i_key == "Exif.Photo.DateTimeOriginal")
						val = exifPhotoTaken(val);

					// The GPS data is stored seperately and composed to one at end
					if(i_key == "Exif.GPSInfo.GPSLongitudeRef")
						gpsLonRef = val;
					else if(i_key == "Exif.GPSInfo.GPSLongitude")
						gpsLon = val;
					else if(i_key == "Exif.GPSInfo.GPSLatitudeRef")
						gpsLatRef = val;
					else if(i_key == "Exif.GPSInfo.GPSLatitude")
						gpsLat = val;


					// Store the unit for this data (set up in setupLabels() function)
					QString unit1 = "";
					QString unit2 = "";
					QString temp = units.value(i_key);
					if(temp != "") {
						if(temp.startsWith("1"))
							unit2 = temp.remove(0,1);
						else
							unit1 = temp.remove(0,1);
					}

					// Ignore GPS, set data to rest
					if(!i_key.startsWith("Exif.GPSInfo")) {

						ret[i_val] = unit1 + val + unit2;

					}


				} else {

					// If function gets here, then the corresponding value hasn't been set
					ret[i_val] = "<i>[not set]</i>";

				}

			} catch(const Exiv2::AnyError&) { }


		}

		// Default: not set
		QString gps = "<i>[" + tr("not set") + "]</i>";
		QString gpsDecimal = "";

		// If however set, compose it and store in 'gps'
		if(gpsLatRef != "" && gpsLat != "" && gpsLonRef != "" && gpsLon != "") {
			QStringList bothFormats = exifGps(gpsLonRef, gpsLon, gpsLatRef, gpsLat);
			gps = bothFormats.at(0);
			gpsDecimal = bothFormats.at(1);
		}

		ret["gps"] = gps;
		ret["gpsDec"] = gpsDecimal;


		int rotationDeg;
		bool flipHor;


		// Look for orientation (not displayed, but could rotate/flip image)
		Exiv2::ExifKey k("Exif.Image.Orientation");
		Exiv2::ExifData::const_iterator it = exifData.findKey(k);
		if(it != exifData.end()) {

			QString val = QString::fromStdString(Exiv2::toString(it->value()));

			flipHor = false;
			// 1 = No rotation/flipping
			if(val == "1")
				rotationDeg = 0;
			// 2 = Horizontally Flipped
			if(val == "2") {
				rotationDeg = 0;
				flipHor = true;
			// 3 = Rotated by 180 degrees
			} else if(val == "3")
				rotationDeg = 180;
			// 4 = Rotated by 180 degrees and flipped horizontally
			else if(val == "4") {
				rotationDeg = 180;
				flipHor = true;
			// 5 = Rotated by 270 degrees and flipped horizontally
			} else if(val == "5") {
				rotationDeg = 270;
				flipHor = true;
			// 6 = Rotated by 270 degrees
			} else if(val == "6")
				rotationDeg = 270;
			// 7 = Flipped Horizontally and Rotated by 90 degrees
			else if(val == "7") {
				rotationDeg = 90;
				flipHor = true;
			// 8 = Rotated by 90 degrees
			} else if(val == "8")
				rotationDeg = 90;

			if(rotationDeg != 0 || flipHor) {
				ret["rotation"] = rotationDeg;
				ret["flip"] = flipHor;
			}

		}

		if(!dimensionSet) {

			QString dimX = "";
			QString dimY = "";

			Exiv2::ExifKey k("Exif.Photo.PixelXDimension");
			Exiv2::ExifData::const_iterator it1 = exifData.findKey(k);
			if(it1 != exifData.end())
				dimX = QString::fromStdString(Exiv2::toString(it1->value()));

			Exiv2::ExifKey l("Exif.Photo.PixelYDimension");
			Exiv2::ExifData::const_iterator it2 = exifData.findKey(l);
			if(it2 != exifData.end())
				dimY = QString::fromStdString(Exiv2::toString(it2->value()));

			if(dimX != "" && dimY != "") {
				ret.insert("dimensions",QString("%1x%2").arg(dimX).arg(dimY));
			}
		}

	}

	return ret;

}

// Format exposure time
QString GetMetaData::exifExposureTime(QString value) {

	QString temp = value;

	if(value.contains("/")) {
		QStringList split = value.split("/");
		if(split.at(0) != "1") {
			int t1 = split.at(0).toInt();
			float t2 = split.at(1).toFloat();
			// I got a bug report of PhotoQt crashing for certain images that have an exposure time of "0/1". So we have to check for it, or we get a division by zero, i.e. crash
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

//	if(verbose) TOFILE << "exif: exposuretime: " << temp.toStdString() << " - " << value.toStdString() << std::endl;

	return value;

}

// Format Focal Length
QString GetMetaData::exifFNumberFLength(QString value) {

	QString temp = value;

	if(value.contains("/")) {
		QStringList split = value.split("/");
		float t1 = split.at(0).toFloat();
		float t2 = split.at(1).toFloat();
		t1 = t1/t2;
		value = QString("%1").arg(t1);
	}

//	if(verbose) TOFILE << "exif: fnumberlength: " << temp.toStdString() << " - " << value.toStdString() << std::endl;

	return value;

}

// Format time the photo was taken
QString GetMetaData::exifPhotoTaken(QString value) {

	QString temp = value;

       QStringList split = value.split(" ");
       QStringList split2 = split.at(0).split(":");
       if(split.length() > 1 && split2.length() > 2)
	       value = split2.at(2) + "/" + split2.at(1) + "/" + split2.at(0) + ", " + split.at(1);

//       if(verbose) TOFILE << "exif: phototaken: " << temp.toStdString() << " - " << value.toStdString() << std::endl;

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

//	if(verbose) TOFILE << "exif: gps (1): " << temp.toStdString() << std::endl;
//	if(verbose) TOFILE << "exif: gps (2): " << value.toStdString() << std::endl;

	QStringList allVal;
	allVal << value << QString("%1 %2").arg(left).arg(right);

	// Compose all the gps data into one string
	return allVal;

}
