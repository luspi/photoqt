#include <pqc_extensionsettings.h>
#include <pqc_extensionshandler.h>
#include <pqc_configfiles.h>

#include <QCryptographicHash>
#include <QJSValue>

ExtensionSettings::ExtensionSettings(QObject *parent) : QQmlPropertyMap(this, parent) {
    set = nullptr;
    watcher = nullptr;
    m_status = getLoading();
    m_extensionId = "";
    m_setPath = "";
    connect(this, &QQmlPropertyMap::valueChanged, this, &ExtensionSettings::saveExtensionValue);
    connect(this, &ExtensionSettings::extensionIdChanged, this, &ExtensionSettings::setup);

}

ExtensionSettings::~ExtensionSettings() {
    if(set != nullptr)
        delete set;
    if(watcher != nullptr)
        delete watcher;
}

void ExtensionSettings::saveExtensionValue(const QString &key, const QVariant &value) {

    if(m_status == getReady()) {

        qDebug() << "args: key =" << key;
        qDebug() << "args: value =" << value;

        QString val = "";
        if(value.typeId() == QMetaType::Bool) {
            val = "BOL_" + QString::number(value.toInt());
        } else if(value.typeId() == QMetaType::Int) {
            val = "INT_" + QString::number(value.toInt());
        } else if(value.typeId() == QMetaType::Double) {
            val = "DBL_" + QString::number(value.toDouble());
        } else if(value.typeId() == QMetaType::QStringList) {
            val = "LST_" + value.toStringList().join(":://::");
        } else if(value.typeId() == QMetaType::QPoint) {
            val = "PNT_" + QString("%1,%2").arg(value.toPoint().x()).arg(value.toPoint().y());
        } else if(value.typeId() == QMetaType::QPointF) {
            val = "PTF_" + QString("%1,%2").arg(value.toPointF().x()).arg(value.toPointF().y());
        } else if(value.typeId() == QMetaType::QSize) {
            val = "SZE_" + QString("%1,%2").arg(value.toSize().width()).arg(value.toSize().height());
        } else if(value.typeId() == QMetaType::QSizeF) {
            val = "SZF_" + QString("%1,%2").arg(value.toSizeF().width()).arg(value.toSizeF().height());
        } else if(value.canConvert<QJSValue>() && value.value<QJSValue>().isArray()) {
            QStringList ret;
            QJSValue _val = value.value<QJSValue>();
            const int length = _val.property("length").toInt();
            for(int i = 0; i < length; ++i)
                ret << _val.property(i).toString();
            val = "LST_" + ret.join(":://::");
        } else {
            val = "STR_" + value.toString();
        }

        watcher->removePath(m_setPath);
        set->setValue(key, val);
        watcher->addPath(m_setPath);

        if(key == "ExtShortcut") {
            PQCExtensionsHandler::get().removeShortcut(key);
            if(value.toString() != "")
                PQCExtensionsHandler::get().addShortcut(m_extensionId, this->value("ExtShortcut").toString());
        }

    }
}

void ExtensionSettings::setup() {

    qDebug() << "";

    m_setPath = QString("%1/%2").arg(PQCConfigFiles::get().EXTENSION_CONFIG_DIR(), m_extensionId);
    set = new QSettings(m_setPath, QSettings::IniFormat);

    watcher = new QFileSystemWatcher;
    watcher->addPath(m_setPath);
    connect(watcher, &QFileSystemWatcher::fileChanged, this, [=]() { readFile(); });

    this->insert("ExtShow", 0);
    this->insert("ExtPosition", QPoint(-1,-1));
    this->insert("ExtSize", QSize(-1,-1));
    this->insert("ExtPopout", 0);
    this->insert("ExtForcePopout", 0);
    this->insert("ExtPopoutPosition", QPoint(-1,-1));
    this->insert("ExtPopoutSize", QSize(-1,-1));
    this->insert("ExtShortcut", PQCExtensionsHandler::get().getExtensionDefaultShortcut(m_extensionId));

    const QList<QStringList> allsets = PQCExtensionsHandler::get().getExtensionSettings(m_extensionId);

    for(const QStringList &s : allsets) {

        if(s.length() != 3)
            continue;

        if(s[1] == "int") {
            const int val = s[2].toInt();
            this->insert(s[0], val);
            defaultValues.insert(s[0], val);
        } else if(s[1] == "double") {
            const double val =  s[2].toDouble();
            this->insert(s[0], val);
            defaultValues.insert(s[0], val);
        } else if(s[1] == "bool") {
            const bool val = static_cast<bool>(s[2].toInt());
            this->insert(s[0], val);
            defaultValues.insert(s[0], val);
        } else if(s[1] == "list") {
            if(s[2].contains(":://::")) {
                const QStringList val = s[2].split(":://::");
                this->insert(s[0], val);
                defaultValues.insert(s[0], val);
            } else if(s[2] != "") {
                this->insert(s[0], QStringList() << s[2]);
                defaultValues.insert(s[0], QStringList() << s[2]);
            } else {
                this->insert(s[0], QStringList());
                defaultValues.insert(s[0], QStringList());
            }
        } else if(s[1] == "point") {
            const QStringList parts = s[2].split(",");
            if(parts.length() == 2) {
                const QPoint val = QPoint(parts[0].toDouble(), parts[1].toDouble());
                this->insert(s[0], val);
                defaultValues.insert(s[0], val);
            } else {
                qWarning() << QString("ERROR: invalid format of QPoint for setting '%1': '%2'").arg(s[0], s[2]);
                this->insert(s[0], QPoint(0,0));
                defaultValues.insert(s[0], QPoint(0,0));
            }
        } else if(s[1] == "size") {
            const QStringList parts = s[2].split(",");
            if(parts.length() == 2) {
                const QSize val = QSize(parts[0].toDouble(), parts[1].toDouble());
                this->insert(s[0], val);
                defaultValues.insert(s[0], val);
            } else {
                qWarning() << QString("ERROR: invalid format of QSize for setting '%1': '%2'").arg(s[0], s[2]);
                this->insert(s[0], QSize(0,0));
                defaultValues.insert(s[0], QSize(0,0));
            }
        } else if(s[1] == "string") {
            this->insert(s[0], s[2]);
            defaultValues.insert(s[0], s[2]);
        } else if(s[1] != "")
            qCritical() << QString("ERROR: datatype not handled for setting '%1':").arg(s[0]) << s[1];
        else
            qDebug() << QString("empty datatype found for setting '%1' -> ignoring").arg(s[0]);

    }

    readFile();

    if(this->value("ExtForcedPopout").toBool() && this->value("ExtPopout").toBool()) {
        this->insert("ExtForcedPopout", false);
        this->insert("ExtPopout", false);
    } else
        this->insert("ExtForcedPopout", false);

    if(PQCExtensionsHandler::get().getExtensionModalMake(m_extensionId))
        this->insert("ExtShow", false);

    if(this->value("ExtShortcut").toString() != "")
        PQCExtensionsHandler::get().addShortcut(m_extensionId, this->value("ExtShortcut").toString());

    m_status = getReady();
    Q_EMIT statusChanged();

}

void ExtensionSettings::readFile() {

    qDebug() << "";

    watcher->removePath(m_setPath);

    const QStringList allKeys = set->allKeys();
    for(const QString &key : allKeys) {

        QString val = set->value(key).toString();

        if(val.startsWith("BOL_"))
            this->insert(key, static_cast<bool>(val.remove(0,4).toInt()));
        else if(val.startsWith("INT_"))
            this->insert(key, val.remove(0,4).toInt());
        else if(val.startsWith("DBL_"))
            this->insert(key, val.remove(0,4).toDouble());
        else if(val.startsWith("LST_"))
            this->insert(key, val.remove(0,4).split(":://::"));
        else if(val.startsWith("PNT_")) {
            QStringList parts = val.remove(0,4).split(",");
            if(parts.length() == 2)
                this->insert(key, QPoint(parts[0].toInt(), parts[1].toInt()));
            else {
                qWarning() << "Invalid QPoint format:" << val.remove(0,4);
                this->insert(key, QPoint(0,0));
            }
        } else if(val.startsWith("PTF_")) {
            QStringList parts = val.remove(0,4).split(",");
            if(parts.length() == 2)
                this->insert(key, QPointF(parts[0].toDouble(), parts[1].toDouble()));
            else {
                qWarning() << "Invalid QPointF format:" << val.remove(0,4);
                this->insert(key, QPointF(0,0));
            }
        } else if(val.startsWith("SZE_")) {
            QStringList parts = val.remove(0,4).split(",");
            if(parts.length() == 2)
                this->insert(key, QSize(parts[0].toInt(), parts[1].toInt()));
            else {
                qWarning() << "Invalid QSize format:" << val.remove(0,4);
                this->insert(key, QSize(0,0));
            }
        } else if(val.startsWith("SZF_")) {
            QStringList parts = val.remove(0,4).split(",");
            if(parts.length() == 2)
                this->insert(key, QSizeF(parts[0].toDouble(), parts[1].toDouble()));
            else {
                qWarning() << "Invalid QSizeF format:" << val.remove(0,4);
                this->insert(key, QSizeF(0,0));
            }
        } else if(val.startsWith("STR_"))
            this->insert(key, val.remove(0,4));

    }

    watcher->addPath(m_setPath);

}

QVariant ExtensionSettings::getDefaultFor(const QString &key) {
    return defaultValues.value(key, "");
}
