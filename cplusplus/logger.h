#ifndef LOGGER_H
#define LOGGER_H

#include <iostream>
#include <sstream>
#include <QDateTime>
#include <QDir>
#include <QTextStream>

class Logger {

public:
	Logger() {
		if(QFile(CONFIG_DIR + QString("/verboselog")).exists()) {
			logFile.setFileName(QDir::tempPath() + "/photoqt.log");
			writeToFile = true;
		} else
			writeToFile = false;
	}

	template <class T>

	Logger &operator<<(const T &v) {

		std::stringstream str;
		str << v;

		if(str.str() == "[[[DATE]]]")
			std::clog << "[" << QDateTime::currentDateTime().toString("dd/MM/yyyy HH:mm:ss:zzz").toStdString() << "] ";
		else
			std::clog << v;

		if(writeToFile) {

			QTextStream out(&logFile);
			logFile.open(QIODevice::WriteOnly | QIODevice::Append);
			if(str.str() == "[[[DATE]]]")
				out << "[" << QDateTime::currentDateTime().toString("dd/MM/yyyy HH:mm:ss:zzz") << "] ";
			else
				out << QString::fromStdString(str.str());

			logFile.close();
		}

		return *this;

	}

	Logger &operator<<(std::ostream&(*f)(std::ostream&)) {
		std::clog << f;
		return *this;
	}

private:
	QFile logFile;
	bool writeToFile;

};

#define LOG Logger()
#define DATE "[[[DATE]]]"
#define NL "\n"

#endif // LOGGER_H
