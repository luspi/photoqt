#ifndef SETTINGSSESSION_H
#define SETTINGSSESSION_H

#include <QObject>
#include <QSettings>
#include <QDir>

// Convenience class to access and change permanent settings
class SettingsSession : public QObject {

	Q_OBJECT

public:
	explicit SettingsSession(QObject *parent = 0) : QObject(parent) {
		settings_ = new QSettings(CFG_SEETINGS_SESSION_FILE);
		setValue("metadatakeepopen",false);
	}
	~SettingsSession() { delete settings_; }

	Q_INVOKABLE void setValue(const QString & key, const QVariant & value) {
		settings_->setValue(key, value);
	}

	Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const {
		return settings_->value(key, defaultValue);

	}
	Q_INVOKABLE QVariant hasKey(const QString &key) const {
		return settings_->allKeys().contains(key);
	}

private:
	QSettings *settings_;
};

#endif // SETTINGSSESSION_H
