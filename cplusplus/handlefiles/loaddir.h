#ifndef LOADDIR_H
#define LOADDIR_H

#include <QObject>
#include <QDir>
#include <QDateTime>
#include <QHash>
#include <QAbstractListModel>
#include "../settings/settings.h"
#include "../settings/fileformats.h"
#include <QtDebug>
#include "../logger.h"

class MyCppModel;

class LoadDir : public QObject {

	Q_OBJECT

public:
	explicit LoadDir(bool verbose);
	~LoadDir();

	QFileInfoList loadDir(QByteArray filepath, QString filter);

private:

	bool verbose;

	Settings *settings;
	FileFormats *fileformats;

	QStringList imageFilter;

	QFileInfoList allImgsInfo;

	static bool sort_name(const QFileInfo &s1fileinfo, const QFileInfo &s2fileinfo);
	static bool sort_name_desc(const QFileInfo &s1fileinfo, const QFileInfo &s2fileinfo);
	static bool sort_naturalname(const QFileInfo &s1fileinfo, const QFileInfo &s2fileinfo);
	static bool sort_naturalname_desc(const QFileInfo &s1fileinfo, const QFileInfo &s2fileinfo);
	static bool sort_date(const QFileInfo &s1fileinfo, const QFileInfo &s2fileinfo);
	static bool sort_date_desc(const QFileInfo &s1fileinfo, const QFileInfo &s2fileinfo);
	static bool sort_size(const QFileInfo &s1fileinfo, const QFileInfo &s2fileinfo);
	static bool sort_size_desc(const QFileInfo &s1fileinfo, const QFileInfo &s2fileinfo);

};

#endif // LOADDIR_H
