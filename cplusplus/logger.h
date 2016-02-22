 #ifndef LOGGER_H
#define LOGGER_H

#include <iostream>
#include <sstream>
#include <QDateTime>

class Logger {

public:
	Logger() {}

	template <class T>

	Logger &operator<<(const T &v) {

		std::stringstream str;
		str << v;
		if(str.str() == "[[[DATE]]]")
			std::clog << "[" << QDateTime::currentDateTime().toString("dd/MM/yyyy HH:mm:ss:zzz").toStdString() << "] ";
		else
			std::clog << v;
		return *this;

	}

	Logger &operator<<(std::ostream&(*f)(std::ostream&)) {
		std::clog << f;
		return *this;
	}

};

#define LOG Logger()
#define DATE "[[[DATE]]]"

#endif // LOGGER_H
