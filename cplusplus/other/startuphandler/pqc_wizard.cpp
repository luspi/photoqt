#include <pqc_wizard.h>
#include <scripts/pqc_scriptslocalization.h>
#include <pqc_configfiles.h>
#include <ui_pqc_wizard.h>
#include <pqc_settingscpp.h>
#include <QSqlQuery>
#include <QSqlDatabase>
#include <QSqlError>
#include <QMessageBox>
#include <QRadioButton>
#include <QTimer>
#include <QDesktopServices>
#include <QFile>

// NOTE:
// We use a Qt designer approach here (a .ui file) as this allows us to call retranslate() of the ui with ease
// without having to do a lot of manual legwork.

PQCWizard::PQCWizard(bool freshInstall, QWidget *parent) : m_freshInstall(freshInstall), QWizard(parent), m_ui(new Ui::Wizard) {

    m_ui->setupUi(this);

    QPixmap pix(":/other/logo.svg");
    setPixmap(QWizard::LogoPixmap, pix.scaledToWidth(50));
    QPixmap pixW(":/other/wizardwatermark.png");
    setPixmap(QWizard::WatermarkPixmap, pixW);

    m_allAvailableLanguages = PQCScriptsLocalization::get().getAvailableTranslations();
    m_selectedLanguage = PQCScriptsLocalization::get().getCurrentTranslation();
    PQCScriptsLocalization::get().updateTranslation(m_selectedLanguage);

    // The combobox with all available languages
    // The currently selected language will be pre-selected (English by default)
    // a fresh install is easy -> we default to English
    if(m_freshInstall) {
        for(int i = 0; i < m_allAvailableLanguages.length(); ++i) {
            m_ui->langCombo->addItem(PQCScriptsLocalization::get().getNameForLocalizationCode(m_allAvailableLanguages.at(i)));
        }
        m_ui->langCombo->setCurrentIndex(m_allAvailableLanguages.indexOf("en"));
    // otherwise we try to load the current language and apply it.
    } else {
        int selectedIndex = -1;
        for(int i = 0; i < m_allAvailableLanguages.length(); ++i) {
            const QString l = m_allAvailableLanguages.at(i);
            if(l == m_selectedLanguage)
                selectedIndex = i;
            else if(l == m_selectedLanguage.split("_").at(0))
                selectedIndex = i;
            m_ui->langCombo->addItem(PQCScriptsLocalization::get().getNameForLocalizationCode(l));
        }
        m_ui->langCombo->setCurrentIndex(selectedIndex);
    }
    connect(m_ui->langCombo, &QComboBox::currentIndexChanged, this, &PQCWizard::applyCurrentLanguage);
    PQCScriptsLocalization::get().updateTranslation(m_selectedLanguage);
    m_ui->retranslateUi(this);

    if(freshInstall)
        this->removePage(1);
    else {
        this->removePage(0);

        bool showReset = false;

        // here we check if something went wrong with the shortcuts
        // this can happen with older versions of PhotoQt
        // apparently particular on Windows
        QSqlDatabase db = QSqlDatabase::database("shortcuts");
        const QStringList checkFor = {"__next", "__prev", "__zoomIn", "__zoomOut"};
        for(const QString &cmd : checkFor) {
            QSqlQuery query(db);
            query.prepare("SELECT COUNT(commands) FROM shortcuts WHERE commands=:cmd");
            query.bindValue(":cmd", cmd);
            if(query.exec()) {
                query.next();
                if(query.value(0).toInt() < 1) {
                    showReset = true;
                    break;
                }
            } else {
                qWarning() << "Unable to check for missing cmd:" << query.lastError().text().trimmed();
                showReset = true;
                break;
            }
        }

        m_ui->lineUpdateReset1->setVisible(showReset);
        m_ui->resetTitle->setVisible(showReset);
        m_ui->resetSubtitle->setVisible(showReset);
        m_ui->butResetShortcuts->setVisible(showReset);
        m_ui->butResetSettings->setVisible(showReset);

        connect(m_ui->butResetShortcuts, &QPushButton::clicked, this, &PQCWizard::resetShortcut);
        connect(m_ui->butResetSettings, &QPushButton::clicked, this, &PQCWizard::resetSettings);

    }

    connect(m_ui->buttonWebsite1, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("https://photoqt.org")); });
    connect(m_ui->buttonLicense1, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("https://www.gnu.org/licenses/old-licenses/gpl-2.0.html#SEC1")); });
    connect(m_ui->buttonEmail1, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("mailto:Lukas@PhotoQt.org?subject=Setup Wizard")); });
    connect(m_ui->buttonWebsite2, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("https://photoqt.org")); });
    connect(m_ui->buttonLicense2, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("https://www.gnu.org/licenses/old-licenses/gpl-2.0.html#SEC1")); });
    connect(m_ui->buttonEmail2, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("mailto:Lukas@PhotoQt.org?subject=Setup Wizard")); });

    setButtonText(QWizard::CancelButton, QApplication::translate("wizard", "Skip wizard"));
    setButtonText(QWizard::FinishButton, QApplication::translate("wizard", "Start PhotoQt"));

}

PQCWizard::~PQCWizard() {}

void PQCWizard::storeCurrentInterface(QString variant) {

    QSqlQuery query(QSqlDatabase::database("settings"));
    query.prepare("INSERT OR REPLACE INTO `general` (`name`, `value`, `datatype`) VALUES ('InterfaceVariant', :val, 'string')");
    query.bindValue(":val", variant);

    if(!query.exec()) {
        qWarning() << "Unable to store interface selection:" << query.lastError().text();
        QMessageBox::warning(this,
                             QApplication::translate("wizard", "Unable to store interface selection"),
                             QApplication::translate("wizard", "PhotoQt was unable to store your interface selection. If this issue persists, try changing it later from the settings manager.")+"<br><br>"+QApplication::translate("wizard", "Error:")+QString(" %1").arg(query.lastError().text()));
        return;
    }

    query.clear();

}

void PQCWizard::applyCurrentLanguage(int index) {

    m_selectedLanguage = m_allAvailableLanguages.at(index);

    QSqlQuery query(QSqlDatabase::database("settings"));
    query.prepare("INSERT OR REPLACE INTO `interface` (`name`, `value`, `datatype`) VALUES ('Language', :val, 'string')");
    query.bindValue(":val", m_selectedLanguage);

    if(!query.exec()) {
        qWarning() << "Unable to store language:" << query.lastError().text();
        // Don't localize the ones below as the language selection might be messed up
        // This way we always have a usable error message in English
        QMessageBox::warning(this,
                             "Unable to store selected language",
                             QString("PhotoQt was unable to store your interface selection. If this issue persists, try changing it later from the settings manager.")+"<br><br>"+QApplication::translate("wizard", "Error:")+QString(" %1").arg(query.lastError().text()));
        return;
    }

    query.clear();

    PQCScriptsLocalization::get().updateTranslation(m_selectedLanguage);
    m_ui->retranslateUi(this);

}

void PQCWizard::resetShortcut() {

    if(QMessageBox::question(this, QApplication::translate("wizard", "Reset shortcuts?"), QApplication::translate("wizard", "This will replace the current shortcuts with the default set. Continue?")) == QMessageBox::No) {
        qDebug() << "Cancelled resetting shortcuts.";
        return;
    }

    // backup database
    QFile::remove(QString("%1.bak").arg(PQCConfigFiles::get().SHORTCUTS_DB()));
    QFile::copy(PQCConfigFiles::get().SHORTCUTS_DB(), QString("%1.bak").arg(PQCConfigFiles::get().SHORTCUTS_DB()));

    QSqlDatabase db = QSqlDatabase::database("shortcuts");
    QSqlDatabase dbDefault = QSqlDatabase::database("shortcuts");

    QSqlQuery queryDel(db);
    queryDel.exec("DELETE FROM shortcuts");

    if(QFile(PQCConfigFiles::get().CACHE_DIR() + "/shortcutstmp.db").exists())
        QFile::remove(PQCConfigFiles::get().CACHE_DIR() + "/shortcutstmp.db");

    if(!QFile::copy(":/shortcuts.db", PQCConfigFiles::get().CACHE_DIR() + "/shortcutstmp.db")) {
        qWarning() << "Unable to create shortcuts database";
        return;
    }

    QFile file(PQCConfigFiles::get().CACHE_DIR() + "/shortcutstmp.db");
    file.setPermissions(file.permissions()|QFileDevice::WriteOwner);

    QSqlQuery queryAttach(QSqlDatabase::database("shortcuts"));
    queryAttach.exec(QString("ATTACH DATABASE '%1' AS defaultdb").arg(PQCConfigFiles::get().CACHE_DIR() + "/shortcutstmp.db"));
    if(queryAttach.lastError().text().trimmed().length()) {
        qWarning() << "Unable to attach default database:" << queryAttach.lastError().text();
        return;
    }

    QSqlQuery queryInsert(QSqlDatabase::database("shortcuts"));
    queryInsert.exec("INSERT INTO shortcuts SELECT * FROM defaultdb.shortcuts;");
    if(queryInsert.lastError().text().trimmed().length()) {
        qWarning() << "Failed to insert default shortcuts:" << queryInsert.lastError().text();
    }

    QMessageBox::information(this, QApplication::translate("wizard", "Reset successful"), QApplication::translate("wizard", "The shortcuts were reset successfully."));

}

void PQCWizard::resetSettings() {

    if(QMessageBox::question(this, QApplication::translate("wizard", "Reset settings?"), QApplication::translate("wizard", "This will replace the current settings with their defaults. Continue?")) == QMessageBox::No) {
        qDebug() << "Cancelled resetting settings.";
        return;
    }

    // backup database
    QFile::remove(QString("%1.bak").arg(PQCConfigFiles::get().USERSETTINGS_DB()));
    QFile::copy(PQCConfigFiles::get().USERSETTINGS_DB(), QString("%1.bak").arg(PQCConfigFiles::get().USERSETTINGS_DB()));

    QSqlDatabase db = QSqlDatabase::database("settings");

    const QStringList tbls = {"filedialog", "filetypes", "general", "imageview", "interface",
                              "mainmenu", "mapview", "metadata", "slideshow", "thumbnails"};

    for(const QString &tb : tbls) {

        QSqlQuery queryDel(db);
        queryDel.exec(QString("DELETE FROM `%1`").arg(tb));
        queryDel.clear();

    }

    PQCSettingsCPP::get().readDB();

    QMessageBox::information(this, QApplication::translate("wizard", "Reset successful"), QApplication::translate("wizard", "The settings were reset successfully."));

}
