#ifndef SHORTCUTSNOTIFIER_H
#define SHORTCUTSNOTIFIER_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include "../logger.h"

class ShortcutsNotifier : public QObject {

	Q_OBJECT

public:
	explicit ShortcutsNotifier(QObject *parent = 0) : QObject(parent) {
		hiddenareas.clear();
		file.setFileName(QDir::homePath()+ "/.photoqt/shortcutsstates");
		if(file.exists()) {
			if(file.open(QIODevice::ReadOnly)){
				QTextStream in(&file);
				QString line;
				while(in.readLineInto(&line))
					hiddenareas.append(line.trimmed());
				file.close();
			} else
				LOG << DATE << "ERROR: Unable to retrieve initial states of shortcuts notifiers: " << file.errorString().trimmed().toStdString() << std::endl;
		}
	}

	Q_INVOKABLE bool isShown(QString area) {
		return !hiddenareas.contains(area);
	}
	Q_INVOKABLE void setHidden(QString area) {
		if(file.open(QIODevice::WriteOnly)) {
			QTextStream out(&file);
			out << (area+"\n");
			file.close();
		} else
			LOG << DATE << "ERROR: Unable to save state of shortcuts notifier of area '" << area.toStdString() << "': " << file.errorString().trimmed().toStdString() << std::endl;
		hiddenareas.append(area);
	}

private:
	QFile file;
	QStringList hiddenareas;

};


#endif // SHORTCUTSNOTIFIER_H
