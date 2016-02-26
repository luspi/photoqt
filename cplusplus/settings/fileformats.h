#ifndef FILEFORMATS_H
#define FILEFORMATS_H

#include <QObject>
#include <QTextStream>
#include <iostream>
#include <QDir>
#include <QFileSystemWatcher>
#include <QTimer>
#include <QtDebug>

#include "fileformatsavailable.h"
#include "fileformatsdefaultenabled.h"
#include "../logger.h"

class FileFormats : public QObject {

	Q_OBJECT

private:
	QFileSystemWatcher *watcher;
	QTimer *saveFileformatsTimer;
	bool verbose;

public:

	FileFormats(bool verbose = false, QObject *parent = 0) : QObject(parent) {

		this->verbose = verbose;

		watcher = new QFileSystemWatcher;
		watcher->addPaths(QStringList() << QDir::homePath() + "/.photoqt/settings" << QDir::homePath() + "/.photoqt/fileformats.disabled");
		connect(watcher, SIGNAL(fileChanged(QString)), this, SLOT(loadFormats()));

		// When saving the settings, we don't want to write the settings file hundreds of time within a few milliseconds, but use a timer to save it once after all settings are set
		saveFileformatsTimer = new QTimer;
		saveFileformatsTimer->setInterval(400);
		saveFileformatsTimer->setSingleShot(true);
		connect(saveFileformatsTimer, SIGNAL(timeout()), this, SLOT(saveFormats()));

		connect(this, SIGNAL(formats_qtChanged(QStringList)), saveFileformatsTimer, SLOT(start()));
		connect(this, SIGNAL(formats_gmChanged(QStringList)), saveFileformatsTimer, SLOT(start()));
		connect(this, SIGNAL(formats_gm_ghostscriptChanged(QStringList)), saveFileformatsTimer, SLOT(start()));
		connect(this, SIGNAL(formats_extrasChanged(QStringList)), saveFileformatsTimer, SLOT(start()));
		connect(this, SIGNAL(formats_untestedChanged(QStringList)), saveFileformatsTimer, SLOT(start()));
		connect(this, SIGNAL(formats_rawChanged(QStringList)), saveFileformatsTimer, SLOT(start()));

		loadFormats();

	}

	~FileFormats() { delete watcher; }

	// Per default enabled image formats
	QStringList formats_qt;
	QStringList formats_gm;
	QStringList formats_gm_ghostscript;
	QStringList formats_extras;
	QStringList formats_untested;
	QStringList formats_raw;

	Q_PROPERTY(QStringList formats_qt MEMBER formats_qt NOTIFY formats_qtChanged)
	Q_PROPERTY(QStringList formats_gm MEMBER formats_gm NOTIFY formats_gmChanged)
	Q_PROPERTY(QStringList formats_gm_ghostscript MEMBER formats_gm_ghostscript NOTIFY formats_gm_ghostscriptChanged)
	Q_PROPERTY(QStringList formats_extras MEMBER formats_extras NOTIFY formats_extrasChanged)
	Q_PROPERTY(QStringList formats_untested MEMBER formats_untested NOTIFY formats_untestedChanged)
	Q_PROPERTY(QStringList formats_raw MEMBER formats_raw NOTIFY formats_rawChanged)

	void setAvailableFormats() {

		if(verbose) LOG << DATE << "Setting available file formats" << std::endl;

		formats_qt = FileFormatsHandler::AvailableFormats::getListForQt();
		formats_gm = FileFormatsHandler::AvailableFormats::getListForGm();
		formats_gm_ghostscript = FileFormatsHandler::AvailableFormats::getListForGmGhostscript();
		formats_extras = FileFormatsHandler::AvailableFormats::getListForExtras();
		formats_untested = FileFormatsHandler::AvailableFormats::getListForUntested();
		formats_raw = FileFormatsHandler::AvailableFormats::getListForRaw();

	}

	void setDefaultFormats() {

		setAvailableFormats();

		if(verbose) LOG << DATE << "Filtering out default file formats" << std::endl;

		QStringList defaultEnabled = FileFormatsHandler::DefaultFormats::getList();

		QStringList tmp;
		foreach(QString f, formats_qt)
			if(defaultEnabled.contains(f))
				tmp.append(f);
		formats_qt = tmp;

		tmp.clear();
		foreach(QString f, formats_gm)
			if(defaultEnabled.contains(f))
				tmp.append(f);
		formats_gm = tmp;

		tmp.clear();
		foreach(QString f, formats_gm_ghostscript)
			if(defaultEnabled.contains(f))
				tmp.append(f);
		formats_gm_ghostscript = tmp;

		tmp.clear();
		foreach(QString f, formats_extras)
			if(defaultEnabled.contains(f))
				tmp.append(f);
		formats_extras = tmp;

		tmp.clear();
		foreach(QString f, formats_untested)
			if(defaultEnabled.contains(f))
				tmp.append(f);
		formats_untested = tmp;

		tmp.clear();
		foreach(QString f, formats_raw)
			if(defaultEnabled.contains(f))
				tmp.append(f);
		formats_raw = tmp;

	}

public slots:

	void loadFormats() {

		if(verbose) LOG << DATE << "Loading disabled file formats from file" << std::endl;

		QFile file(QDir::homePath() + "/.photoqt/fileformats.disabled");

		// At first startup, this file might not (yet) exist, but we can simply set the
		// default formats as they are currently in the process of being set anyways
		if(!file.exists()) {
			setDefaultFormats();
			return;
		}

		if(!file.open(QIODevice::ReadOnly)) {
			LOG << DATE << "ERROR! Unable to open file to load disabled fileformats. Using default settings..." << std::endl;
			setDefaultFormats();
			return;
		}

		QTextStream in(&file);
		QStringList disabled = in.readAll().split("\n",QString::SkipEmptyParts);

		setAvailableFormats();

		QStringList tmp;
		foreach(QString f, formats_qt)
			if(!disabled.contains(f))
				tmp.append(f);
		formats_qt = tmp;

		tmp.clear();
		foreach(QString f, formats_gm)
			if(!disabled.contains(f))
				tmp.append(f);
		formats_gm = tmp;

		tmp.clear();
		foreach(QString f, formats_gm_ghostscript)
			if(!disabled.contains(f))
				tmp.append(f);
		formats_gm_ghostscript = tmp;

		tmp.clear();
		foreach(QString f, formats_extras)
			if(!disabled.contains(f))
				tmp.append(f);
		formats_extras = tmp;

		tmp.clear();
		foreach(QString f, formats_untested)
			if(!disabled.contains(f))
				tmp.append(f);
		formats_untested = tmp;

		tmp.clear();
		foreach(QString f, formats_raw)
			if(!disabled.contains(f))
				tmp.append(f);
		formats_raw = tmp;

	}

	void saveFormats() {

		if(verbose) LOG << DATE << "Saving disabled file formats to file" << std::endl;

		QStringList current_qt = formats_qt;
		QStringList current_gm = formats_gm;
		QStringList current_gm_ghostscript = formats_gm_ghostscript;
		QStringList current_extras = formats_extras;
		QStringList current_untested = formats_untested;
		QStringList current_raw = formats_raw;

		QStringList disabled;

		setAvailableFormats();

		foreach(QString f, formats_qt)
			if(!current_qt.contains(f))
				disabled.append(f);

		foreach(QString f, formats_gm)
			if(!current_gm.contains(f))
				disabled.append(f);

		foreach(QString f, formats_gm_ghostscript)
			if(!current_gm_ghostscript.contains(f))
				disabled.append(f);

		foreach(QString f, formats_extras)
			if(!current_extras.contains(f))
				disabled.append(f);

		foreach(QString f, formats_untested)
			if(!current_untested.contains(f))
				disabled.append(f);

		foreach(QString f, formats_raw)
			if(!current_raw.contains(f))
				disabled.append(f);

		QFile file(QDir::homePath() + "/.photoqt/fileformats.disabled");
		if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
			LOG << DATE << "ERROR! Unable to save update fileformats..." << std::endl;
			return;
		}

		QTextStream out(&file);
		out << disabled.join("\n");

	}

signals:
	void formats_qtChanged(QStringList val);
	void formats_gmChanged(QStringList val);
	void formats_gm_ghostscriptChanged(QStringList val);
	void formats_extrasChanged(QStringList val);
	void formats_untestedChanged(QStringList val);
	void formats_rawChanged(QStringList val);

};

#endif
