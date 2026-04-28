#include <pqc_wizard.h>
#include <scripts/pqc_scriptslocalization.h>
#include <pqc_configfiles.h>
#include <ui_pqc_wizard.h>
#include <pqc_settingscpp.h>
#include <pqc_extensionshandler.h>
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

    m_selfTestPerformed = false;
    m_showReset = false;
    m_showExtensions = false;

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

        m_ui->interfaceIntegrated->setChecked(true);
        storeInterfaceSelection();

        connect(m_ui->interfaceIntegrated, &QRadioButton::clicked, this, &PQCWizard::storeInterfaceSelection);
        connect(m_ui->interfaceModern, &QRadioButton::clicked, this, &PQCWizard::storeInterfaceSelection);

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

    if(freshInstall) {
        this->removePage(1);
        this->removePage(2);
    } else {
        this->removePage(0);

        m_ui->resetLine->setVisible(false);
        m_ui->resetTitle->setVisible(false);
        m_ui->resetSubtitle->setVisible(false);
        m_ui->butResetShortcuts->setVisible(false);
        m_ui->butResetSettings->setVisible(false);

        m_ui->extensionsLine->setVisible(false);
        m_ui->extensionsTitle->setVisible(false);
        m_ui->extensionsSubtitle->setVisible(false);
        m_ui->butExtensions->setVisible(false);

    }

    connect(m_ui->buttonWebsite1, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("https://photoqt.org")); });
    connect(m_ui->buttonLicense1, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("https://www.gnu.org/licenses/old-licenses/gpl-2.0.html#SEC1")); });
    connect(m_ui->buttonEmail1, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("mailto:Lukas@PhotoQt.org?subject=Setup Wizard")); });
    connect(m_ui->buttonWebsite2, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("https://photoqt.org")); });
    connect(m_ui->buttonLicense2, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("https://www.gnu.org/licenses/old-licenses/gpl-2.0.html#SEC1")); });
    connect(m_ui->buttonEmail2, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("mailto:Lukas@PhotoQt.org?subject=Setup Wizard")); });

    setButtonText(QWizard::CancelButton, QApplication::translate("wizard", "Skip wizard"));
    setButtonText(QWizard::FinishButton, QApplication::translate("wizard", "Start PhotoQt"));

    connect(this, &QWizard::currentIdChanged, this, &PQCWizard::newPageShown);

}

PQCWizard::~PQCWizard() {}

void PQCWizard::newPageShown(int id) {

    // the self-test page id
    if(id == 2) {

        m_ui->testTitle->setVisible(false);
        m_ui->notice->setVisible(false);
        m_ui->noticeLine->setVisible(false);

#if __cplusplus >= 202002L
        connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::numExtensionsAllChanged, this, [=, this]() { if(!m_selfTestPerformed) performSelftest(); });
#else
        connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::numExtensionsAllChanged, this, [=]() { if(!m_selfTestPerformed) performSelftest(); });
#endif
        PQCExtensionsHandler::get().setup();
    }

}

void PQCWizard::storeInterfaceSelection() {

    QSqlQuery query(QSqlDatabase::database("settings"));
    query.prepare("INSERT OR REPLACE INTO `general` (`name`, `value`, `datatype`) VALUES ('InterfaceVariant', :val, 'string')");
    query.bindValue(":val", (m_ui->interfaceIntegrated->isChecked() ? "integrated" : "modern"));

    if(!query.exec()) {
        qWarning() << "Unable to store interface selection:" << query.lastError().text();
        QMessageBox::warning(this,
                             QApplication::translate("wizard", "Unable to store interface selection"),
                             QApplication::translate("wizard", "PhotoQt was unable to store your interface selection. If this issue persists, try changing it later from the settings manager.")+"<br><br>"+QApplication::translate("wizard", "Error:")+QString(" %1").arg(query.lastError().text()));
        return;
    }

    query.clear();

}


void PQCWizard::performSelftest() {

    m_ui->testTitle->setVisible(true);

    /****************************************************************/
    // check shortcuts

    // here we check if something went wrong with the shortcuts
    // this can happen with older versions of PhotoQt
    // apparently particular on Windows
    const QStringList checkFor = {"__next", "__prev", "__zoomIn", "__zoomOut"};
    for(const QString &cmd : checkFor) {
        QSqlQuery query(QSqlDatabase::database("shortcuts"));
        query.prepare("SELECT COUNT(commands) FROM shortcuts WHERE commands=:cmd");
        query.bindValue(":cmd", cmd);
        if(query.exec()) {
            query.next();
            if(query.value(0).toInt() < 1) {
                m_showReset = true;
                break;
            }
        } else {
            qWarning() << "Unable to check for missing cmd:" << query.lastError().text().trimmed();
            m_showReset = true;
            break;
        }
    }

    if(!m_selfTestPerformed) {
        m_ui->resetLine->setVisible(m_showReset);
        m_ui->resetTitle->setVisible(m_showReset);
        m_ui->resetSubtitle->setVisible(m_showReset);
        m_ui->butResetShortcuts->setVisible(m_showReset);
        m_ui->butResetSettings->setVisible(m_showReset);

        connect(m_ui->butResetShortcuts, &QPushButton::clicked, this, &PQCWizard::resetShortcut);
        connect(m_ui->butResetSettings, &QPushButton::clicked, this, &PQCWizard::resetSettings);
    }

    /****************************************************************/
    // check extensions

    // here we check if and how many extensions are disabled.
    // if any are disabled, we offer the user to enable them all.
    const QStringList extDisabled = PQCExtensionsHandler::get().getDisabledExtensions();
    const QStringList extAll = PQCExtensionsHandler::get().getExtensionsEnabledAndDisabld();
    qWarning() << ">>>" << extDisabled << "/" << extAll;
    if(extDisabled.length() > 0 || (m_selfTestPerformed && m_showExtensions)) {
        m_showExtensions = true;
        m_ui->extensionsTitle->setText(QString("%1 out of %2 extensions are enabled.").arg(extAll.length()-extDisabled.length()).arg(extAll.length()));
    }

    if(!m_selfTestPerformed) {
        m_ui->extensionsLine->setVisible(m_showExtensions);
        m_ui->extensionsTitle->setVisible(m_showExtensions);
        m_ui->extensionsSubtitle->setVisible(m_showExtensions);
        m_ui->butExtensions->setVisible(m_showExtensions);

        connect(m_ui->butExtensions, &QPushButton::clicked, this, &PQCWizard::enableAllExtensions);
    }

    /****************************************************************/

    if(!m_selfTestPerformed) {
        if(m_showReset || m_showExtensions) {
            m_ui->resultsText->setVisible(false);
            m_ui->notice->setVisible(true);
            m_ui->noticeLine->setVisible(true);
        } else
            m_ui->resultsText->setText(QApplication::translate("wizard", "No issues were found."));
    }

    m_selfTestPerformed = true;

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

    qDebug() << "";

    if(QMessageBox::question(this, QApplication::translate("wizard", "Reset shortcuts?"), QApplication::translate("wizard", "This will replace the current shortcuts with the default set. Continue?")) == QMessageBox::No) {
        qDebug() << "Cancelled resetting shortcuts.";
        return;
    }

    // backup database
    QFile::remove(QString("%1.bak").arg(PQCConfigFiles::get().SHORTCUTS_DB()));
    QFile::copy(PQCConfigFiles::get().SHORTCUTS_DB(), QString("%1.bak").arg(PQCConfigFiles::get().SHORTCUTS_DB()));

    QSqlQuery queryDel(QSqlDatabase::database("shortcuts"));
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
    performSelftest();

}

void PQCWizard::resetSettings() {

    qDebug() << "";

    if(QMessageBox::question(this, QApplication::translate("wizard", "Reset settings?"), QApplication::translate("wizard", "This will replace the current settings with their defaults. Continue?")) == QMessageBox::No) {
        qDebug() << "Cancelled resetting settings.";
        return;
    }

    // backup database
    QFile::remove(QString("%1.bak").arg(PQCConfigFiles::get().USERSETTINGS_DB()));
    QFile::copy(PQCConfigFiles::get().USERSETTINGS_DB(), QString("%1.bak").arg(PQCConfigFiles::get().USERSETTINGS_DB()));

    const QStringList tbls = {"filedialog", "filetypes", "general", "imageview", "interface",
                              "mainmenu", "mapview", "metadata", "slideshow", "thumbnails"};

    for(const QString &tb : tbls) {

        QSqlQuery queryDel(QSqlDatabase::database("settings"));
        queryDel.exec(QString("DELETE FROM `%1`").arg(tb));
        queryDel.clear();

    }

    PQCSettingsCPP::get().readDB();

    QMessageBox::information(this, QApplication::translate("wizard", "Reset successful"), QApplication::translate("wizard", "The settings were reset successfully."));
    performSelftest();

}

void PQCWizard::enableAllExtensions() {

    qDebug() << "";

    for(const QString &id : PQCExtensionsHandler::get().getDisabledExtensions())
        PQCExtensionsHandler::get().enableExtension(id);

    QSqlQuery query(QSqlDatabase::database("settings"));
    query.prepare(QString("INSERT OR REPLACE INTO `general` (`name`,`value`,`datatype`) VALUES('ExtensionsEnabled','%1','list')").arg(PQCExtensionsHandler::get().getExtensionsEnabledAndDisabld().join(":://::")));
    if(!query.exec()) {
        QMessageBox::information(this, QApplication::translate("wizard", "Error"), QApplication::translate("wizard", "Failed to enable all extensions. Please try to enable them manually from the settings manager."));
        return;
    } else {
        PQCSettingsCPP::get().readDB();
    }

    QMessageBox::information(this, QApplication::translate("wizard", "Success"), QApplication::translate("wizard", "All extensions have been enabled."));
    performSelftest();

}
