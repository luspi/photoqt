#include "loaddir.h"

LoadDir::LoadDir(bool verbose) : QObject() {
	this->verbose = verbose;
	settings = new Settings;
	fileformats = new FileFormats(verbose);
}

LoadDir::~LoadDir() {
	delete settings;
	delete fileformats;
}

QFileInfoList LoadDir::loadDir(QString filepath, QString filter) {

	if(verbose)
		LOG << CURDATE << "LoadDir::loadDir(): Loading filepath '" << filepath.toStdString() << "'" << NL;

	QDir dir(QFileInfo(filepath).absolutePath());

	// Set appropriate filter
	if(filter.trimmed() == "") {
		// These are the images known by PhotoQt
		QStringList flt1 = fileformats->formats_qt+fileformats->formats_gm+fileformats->formats_gm_ghostscript
				+fileformats->formats_extras+fileformats->formats_untested+fileformats->formats_raw;
		QStringList flt2 = flt1;
		for(int i = 0; i < flt2.length(); ++i)
			flt2[i] = flt2.at(i).toUpper();
		dir.setNameFilters(flt1+flt2);
	} else {
		if(verbose)
			LOG << CURDATE << "LoadDir::loaddir(): Filter set: '" << filter.toStdString() << "'" << NL;
		QStringList new_flt;
		foreach(QString f, filter.split(" ")) {
			if(f.startsWith("."))
				new_flt.append("*" + f);
			else
				new_flt.append("*" + f + "*");
		}
		dir.setNameFilters(new_flt);
	}

	// Store a QFileInfoList and a QStringList with the filenames
	allImgsInfo = dir.entryInfoList(QDir::Files,QDir::IgnoreCase);

	// When opening an unknown file (i.e., one that doesn't match any set format), then we need to manually add it to the list of loaded images
	if(!allImgsInfo.contains(QFileInfo(filepath))) {
		if(filter.trimmed() == "")
			allImgsInfo.append(QFileInfo(filepath));
		else if(allImgsInfo.length() > 0)
			filepath = allImgsInfo.at(0).filePath();
		else
			return QFileInfoList();
	}

	// Sort images...
	bool asc = settings->sortbyAscending;
	QString sortby = settings->sortby;
	if(sortby == "name") {
		if(verbose)
			LOG << CURDATE << "LoadDir::loaddir(): Sorting by name" << NL;
		std::sort(allImgsInfo.begin(),allImgsInfo.end(),(asc ? sort_name : sort_name_desc));
	}
	if(sortby == "naturalname") {
		if(verbose)
			LOG << CURDATE << "LoadDir::loaddir(): Sorting by natural name" << NL;
		std::sort(allImgsInfo.begin(),allImgsInfo.end(),(asc ? sort_naturalname : sort_naturalname_desc));
	}
	if(sortby == "date") {
		if(verbose)
			LOG << CURDATE << "LoadDir::loaddir(): Sorting by date" << NL;
		std::sort(allImgsInfo.begin(),allImgsInfo.end(),(asc ? sort_date : sort_date_desc));
	}
	if(sortby == "size") {
		if(verbose)
			LOG << CURDATE << "LoadDir::loaddir(): Sorting by size" << NL;
		std::sort(allImgsInfo.begin(),allImgsInfo.end(),(asc ? sort_size : sort_size_desc));
	}

	return allImgsInfo;

}


// FOR SORTING, WE HAVE ALL FUNCTIONS FOR DESCENDING AND ASCENDING CASE, AS THIS IS FASTER THAN REVERSING THE ORDER
// AFTERWARDS (PARTICULARLY FOR DIRECTORIES WITH A LARGE NUMBER OF FILES

bool LoadDir::sort_name(const QFileInfo &s1fileinfo, const QFileInfo &s2fileinfo) {
	return(s1fileinfo.fileName().compare(s2fileinfo.fileName(), Qt::CaseInsensitive) <= 0);
}
bool LoadDir::sort_name_desc(const QFileInfo &s1fileinfo, const QFileInfo &s2fileinfo) {
	return(s2fileinfo.fileName().compare(s1fileinfo.fileName(), Qt::CaseInsensitive) <= 0);
}
bool LoadDir::sort_date(const QFileInfo &s1fileinfo, const QFileInfo &s2fileinfo) {
	return(s1fileinfo.created().secsTo(s2fileinfo.created()) > 0);
}
bool LoadDir::sort_date_desc(const QFileInfo &s1fileinfo, const QFileInfo &s2fileinfo) {
	return(s1fileinfo.created().secsTo(s2fileinfo.created()) < 0);
}
bool LoadDir::sort_size(const QFileInfo &s1fileinfo, const QFileInfo &s2fileinfo) {
	return(s1fileinfo.size() >= s2fileinfo.size());
}
bool LoadDir::sort_size_desc(const QFileInfo &s1fileinfo, const QFileInfo &s2fileinfo) {
	return(s1fileinfo.size() < s2fileinfo.size());
}

// Algorithm used for sorting a directory using natural sort
// Credits to: http://www.qtcentre.org/archive/index.php/t-21411.html
bool LoadDir::sort_naturalname(const QFileInfo& s1fileinfo,const QFileInfo& s2fileinfo) {

	const QString s1 = s1fileinfo.fileName();
	const QString s2 = s2fileinfo.fileName();

	// ignore common prefix..
	int i = 0;

	while ((i < s1.length()) && (i < s2.length()) && (s1.at(i).toLower() == s2.at(i).toLower()))
		++i;
	++i;

	// something left to compare?
	if ((i < s1.length()) && (i < s2.length())) {

		// get number prefix from position i - doesnt matter from which string
		int k = i-1;

		//If not number return native comparator
		if(!s1.at(k).isNumber() || !s2.at(k).isNumber()) {

			//Two next lines
			//E.g. 1_... < 12_...
			if(s1.at(k).isNumber())
				return false;
			if(s2.at(k).isNumber())
				return true;
			return QString::compare(s1, s2, Qt::CaseSensitive) < 0;
		}

		QString n = "";
		k--;

		while ((k >= 0) && (s1.at(k).isNumber())) {
			n = s1.at(k)+n;
			--k;
		}

		// get relevant/signficant number string for s1
		k = i-1;
		QString n1 = "";
		while ((k < s1.length()) && (s1.at(k).isNumber())) {
			n1 += s1.at(k);
			++k;
		}

		// get relevant/signficant number string for s2
		//Decrease by
		k = i-1;
		QString n2 = "";
		while ((k < s2.length()) && (s2.at(k).isNumber())) {
			n2 += s2.at(k);
			++k;
		}

		// got two numbers to compare?
		if (!n1.isEmpty() && !n2.isEmpty())
			return (n+n1).toInt() < (n+n2).toInt();
		else {
			// not a number has to win over a number.. number could have ended earlier... same prefix..
			if (!n1.isEmpty())
				return false;
			if (!n2.isEmpty())
				return true;
			return s1.at(i) < s2.at(i);
		}
	} else {
		// shortest string wins
		return s1.length() < s2.length();
	}
}
bool LoadDir::sort_naturalname_desc(const QFileInfo& s1fileinfo,const QFileInfo& s2fileinfo) {

	const QString s2 = s1fileinfo.fileName();
	const QString s1 = s2fileinfo.fileName();

	// ignore common prefix..
	int i = 0;

	while ((i < s1.length()) && (i < s2.length()) && (s1.at(i).toLower() == s2.at(i).toLower()))
		++i;
	++i;

	// something left to compare?
	if ((i < s1.length()) && (i < s2.length())) {

		// get number prefix from position i - doesnt matter from which string
		int k = i-1;

		//If not number return native comparator
		if(!s1.at(k).isNumber() || !s2.at(k).isNumber()) {

			//Two next lines
			//E.g. 1_... < 12_...
			if(s1.at(k).isNumber())
				return false;
			if(s2.at(k).isNumber())
				return true;
			return QString::compare(s1, s2, Qt::CaseSensitive) < 0;
		}

		QString n = "";
		k--;

		while ((k >= 0) && (s1.at(k).isNumber())) {
			n = s1.at(k)+n;
			--k;
		}

		// get relevant/signficant number string for s1
		k = i-1;
		QString n1 = "";
		while ((k < s1.length()) && (s1.at(k).isNumber())) {
			n1 += s1.at(k);
			++k;
		}

		// get relevant/signficant number string for s2
		//Decrease by
		k = i-1;
		QString n2 = "";
		while ((k < s2.length()) && (s2.at(k).isNumber())) {
			n2 += s2.at(k);
			++k;
		}

		// got two numbers to compare?
		if (!n1.isEmpty() && !n2.isEmpty())
			return (n+n1).toInt() < (n+n2).toInt();
		else {
			// not a number has to win over a number.. number could have ended earlier... same prefix..
			if (!n1.isEmpty())
				return false;
			if (!n2.isEmpty())
				return true;
			return s1.at(i) < s2.at(i);
		}
	} else {
		// shortest string wins
		return s1.length() < s2.length();
	}
}
