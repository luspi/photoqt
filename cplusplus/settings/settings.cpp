#include "settings.h"

// Convenience class to access and change permanent settings

Settings::Settings(QObject *parent) : QObject(parent) {
	settings_ = new QSettings(QDir::homePath() + "/.photoqt/settings",QSettings::IniFormat);
}

void Settings::setValue(const QString &key, const QVariant &value) {
	settings_->setValue(key, value);
}

QVariant Settings::value(const QString &key, const QVariant &defaultValue) const {
	return settings_->value(key, defaultValue);
}
