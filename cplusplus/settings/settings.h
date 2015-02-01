#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QSettings>
#include <QDir>

// Convenience class to access and change permanent settings

class Settings : public QObject {

	Q_OBJECT

public:
	explicit Settings(QObject *parent = 0);
	Q_INVOKABLE void setValue(const QString & key, const QVariant & value);
	Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;


private:
    QSettings *settings_;

};

#endif // SETTINGS_H
