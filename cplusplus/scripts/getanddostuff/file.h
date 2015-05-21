#ifndef GETANDDOSTUFFFILE_H
#define GETANDDOSTUFFFILE_H

#include <QObject>
#include <QFileDialog>
#include <QStringList>
#include <QIcon>

class GetAndDoStuffFile : public QObject {

	Q_OBJECT

public:
	explicit GetAndDoStuffFile(QObject *parent = 0);
	~GetAndDoStuffFile();

	QString removePathFromFilename(QString path, bool removeSuffix = false);
	QString removeFilenameFromPath(QString file);
	QString getSuffix(QString file);

	QString getFilenameQtImage();
	QString getFilename(QString caption, QString dir, QString filter = "");
	QString getIconPathFromTheme(QString binary);
	QString getSaveFilename(QString caption, QString file);

};

#endif // GETANDDOSTUFFFILE_H
