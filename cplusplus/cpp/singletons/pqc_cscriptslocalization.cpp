#include <cpp/pqc_cscriptslocalization.h>

#include <QtDebug>
#include <QDirIterator>
#include <QTranslator>
#include <QApplication>
#include <QQmlEngine>
#include <QQmlContext>
#include <QSqlQuery>
#include <QSqlDatabase>
#include <QSqlError>

PQCCScriptsLocalization::PQCCScriptsLocalization() {
    trans = new QTranslator;
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

PQCCScriptsLocalization::~PQCCScriptsLocalization() {
    delete trans;
}

PQCCScriptsLocalization &PQCCScriptsLocalization::get() {
    static PQCCScriptsLocalization instance;
    return instance;
}

QStringList PQCCScriptsLocalization::getAvailableTranslations() {

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

void PQCCScriptsLocalization::updateTranslation(QString code) {

    qDebug() << "args: code =" << code;

    if(code == currentTranslation) {
        qDebug() << "Translation already set.";
        return;
    }

    static QTranslator trans;
    qApp->removeTranslator(&trans);

    const QStringList allcodes = code.split("/");

    // we use this to detect whether a translation was found for the above language code
    currentTranslation = "";
    for(const QString &c : allcodes) {

        if(QFile(":/lang/photoqt_" + c + ".qm").exists()) {

            if(trans.load(":/lang/photoqt_" + c)) {
                currentTranslation = c;
                qApp->installTranslator(&trans);
            } else
                qWarning() << "Unable to install translator for language code" << c;

        } else if(c.contains("_")) {

            const QString cc = c.split("_").at(0);

            if(QFile(":/lang/photoqt_" + cc + ".qm").exists()) {

                if(trans.load(":/lang/photoqt_" + cc)) {
                    currentTranslation = cc;
                    qApp->installTranslator(&trans);
                } else
                    qWarning() << "Unable to install translator for language code" << cc;

            }

        } else {

            const QString cc = QString("%1_%2").arg(c, c.toUpper());

            if(QFile(":/lang/photoqt_" + cc + ".qm").exists()) {

                if(trans.load(":/lang/photoqt_" + cc)) {
                    currentTranslation = cc;
                    qApp->installTranslator(&trans);
                } else
                    qWarning() << "Unable to install translator for language code" << c;

            }
        }

    }

    // no translation found -> store selected code
    if(currentTranslation == "")
        currentTranslation = code;

    if(QQmlEngine::contextForObject(this) != nullptr)
        QQmlEngine::contextForObject(this)->engine()->retranslate();

}

QString PQCCScriptsLocalization::getNameForLocalizationCode(QString code) {
    qDebug() << "args: code =" << code;
    if(langNames.contains(code))
        return langNames.value(code.toLower(), code);
    else if(code.contains("_"))
        return langNames.value(code.split("_").at(0).toLower(), code);
    return code;
}

QString PQCCScriptsLocalization::getCurrentTranslation() {

    QSqlQuery query(QSqlDatabase::database("settings"));

    if(!query.exec("SELECT `value` FROM `interface` WHERE `name`='Language'")) {
        qWarning() << "Querying current language failed:" << query.lastError().text();
        return "en";
    }

    if(!query.next()) return "en";

    return query.value(0).toString();

}
