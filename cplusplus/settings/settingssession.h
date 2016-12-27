/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef SETTINGSSESSION_H
#define SETTINGSSESSION_H

#include <QObject>
#include <QSettings>
#include <QDir>
#include "../logger.h"

// Convenience class to access and change permanent settings
class SettingsSession : public QObject {

	Q_OBJECT

public:
	explicit SettingsSession(QObject *parent = 0) : QObject(parent) {
		settings_ = new QSettings(CFG_SETTINGS_SESSION_FILE);
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
