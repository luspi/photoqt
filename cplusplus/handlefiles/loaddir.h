#ifndef LOADDIR_H
#define LOADDIR_H

#include <QObject>
#include <QDir>
#include <QDateTime>
#include <QHash>
#include <QAbstractListModel>
#include <QSettings>
#include <QtDebug>

class MyCppModel;

class LoadDir : public QObject {

	Q_OBJECT

public:
	explicit LoadDir();
	~LoadDir();

	QFileInfoList loadDir(QByteArray filepath);

private:

	QSettings *settings;

	QString currentfile;
	QStringList imageFilter;

	int counttot;
	int countpos;
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
