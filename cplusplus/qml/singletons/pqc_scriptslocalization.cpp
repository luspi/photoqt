#include <qml/pqc_scriptslocalization.h>

#include <QtDebug>
#include <QDirIterator>
#include <QTranslator>
#include <QApplication>
#include <QQmlEngine>
#include <QQmlContext>
#include <QSqlQuery>
#include <QSqlDatabase>
#include <QSqlError>

PQCScriptsLocalization::PQCScriptsLocalization() {
    currentTranslation = "en";

    langNames.insert("en",    "English");
    langNames.insert("ar",    "عربي,عربى");
    langNames.insert("ca_es", "Català");
    langNames.insert("cs",    "Čeština");
    langNames.insert("de",    "Deutsch");
    langNames.insert("el",    "Ελληνικά");
    langNames.insert("es",    "Español");
    langNames.insert("es_cr", "Español (Costa Rica)");
    langNames.insert("fi",    "Suomen kieli");
    langNames.insert("fr",    "Français");
    langNames.insert("he",    "עברית");
    langNames.insert("it",    "Italiano");
    langNames.insert("lt",    "lietuvių kalba");
    langNames.insert("nl",    "Nederlands");
    langNames.insert("pl",    "Polski");
    langNames.insert("pt",    "Português (Portugal)");
    langNames.insert("pt_br", "Português (Brasil)");
    langNames.insert("ru",    "Русский");
    langNames.insert("sk",    "Slovenčina");
    langNames.insert("tr",    "Türkçe");
    langNames.insert("uk",    "Українська");
    langNames.insert("zh",    "Chinese (simplified)");
    langNames.insert("zh_tw", "Chinese (traditional)");

}

PQCScriptsLocalization::~PQCScriptsLocalization() {}

PQCScriptsLocalization &PQCScriptsLocalization::get() {
    static PQCScriptsLocalization instance;
    return instance;
}

QStringList PQCScriptsLocalization::getAvailableTranslations() {

    qDebug() << "";

    QStringList ret;

    QStringList tmp;

    // the non-translated language is English
    tmp << "en";

    QDirIterator it(":/lang");
    while (it.hasNext()) {
        QString file = it.next();
        if(file.endsWith(".qm")) {
            file = file.remove(0, 15);
            file = file.remove(file.length()-3, file.length());
            if(!ret.contains(file))
                tmp.push_back(file);
        }
    }

    tmp.sort();
    ret.append(tmp);

    return ret;

}

QString PQCScriptsLocalization::getNameForLocalizationCode(QString code) {
    qDebug() << "args: code =" << code;
    if(langNames.contains(code))
        return langNames.value(code.toLower(), code);
    else if(code.contains("_"))
        return langNames.value(code.split("_").at(0).toLower(), code);
    return code;
}

QString PQCScriptsLocalization::getCurrentTranslation() {

    QSqlQuery query(QSqlDatabase::database("settings"));

    if(!query.exec("SELECT `value` FROM `interface` WHERE `name`='Language'")) {
        qWarning() << "Querying current language failed:" << query.lastError().text();
        return "en";
    }

    if(!query.next()) return "en";

    return query.value(0).toString();

}
