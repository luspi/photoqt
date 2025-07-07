#include <pqc_extensionsettings.h>
#include <pqc_extensionshandler.h>
#include <pqc_configfiles.h>

#include <QCryptographicHash>

ExtensionSettings::ExtensionSettings(QObject *parent) : QQmlPropertyMap(parent) {
    set = nullptr;
    m_isSetup = false;
    connect(this, &QQmlPropertyMap::valueChanged, this, &ExtensionSettings::saveExtensionValue);
}

ExtensionSettings::~ExtensionSettings() {
    if(set != nullptr)
        delete set;
}

void ExtensionSettings::saveExtensionValue(const QString &key, const QVariant &value) {
    if(key == "extensionId")
        setup(value.toString());
    else if(m_isSetup)
        set->setValue(key, value);
}

void ExtensionSettings::setup(QString id) {

    QString path = QString("%1/%2").arg(PQCConfigFiles::get().EXTENSION_CONFIG_DIR(), id);
    set = new QSettings(path, QSettings::IniFormat);

    const QList<QStringList> allsets = PQCExtensionsHandler::get().getSettings(id);
    for(const QStringList &s : allsets) {

        if(s[1] == "int")
            this->insert(s[0], s[2].toInt());
        else if(s[1] == "double")
            this->insert(s[0], s[2].toDouble());
        else if(s[1] == "bool")
            this->insert(s[0], static_cast<bool>(s[2].toInt()));
        else if(s[1] == "list") {
            if(s[2].contains(":://::"))
                this->insert(s[0], s[2].split(":://::"));
            else if(s[2] != "")
                this->insert(s[0], QStringList() << s[2]);
            else
                this->insert(s[0], QStringList());
        } else if(s[1] == "point") {
            const QStringList parts = s[2].split(",");
            if(parts.length() == 2)
                this->insert(s[0], QPoint(parts[0].toDouble(), parts[1].toDouble()));
            else {
                qWarning() << QString("ERROR: invalid format of QPoint for setting '%1': '%2'").arg(s[0], s[2]);
                this->insert(s[0], QPoint(0,0));
            }
        } else if(s[1] == "size") {
            const QStringList parts = s[2].split(",");
            if(parts.length() == 2)
                this->insert(s[0], QSize(parts[0].toDouble(), parts[1].toDouble()));
            else {
                qWarning() << QString("ERROR: invalid format of QSize for setting '%1': '%2'").arg(s[0], s[2]);
                this->insert(s[0], QSize(0,0));
            }
        } else if(s[1] == "string")
            this->insert(s[0], s[2]);
        else if(s[1] != "")
            qCritical() << QString("ERROR: datatype not handled for setting '%1':").arg(s[0]) << s[1];
        else
            qDebug() << QString("empty datatype found for setting '%1' -> ignoring").arg(s[0]);

    }

    const QStringList allKeys = set->allKeys();
    for(const QString &key : allKeys) {
        this->insert(key, set->value(key));
    }

    m_isSetup = true;

}
