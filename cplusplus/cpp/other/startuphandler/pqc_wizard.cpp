#include <cpp/pqc_wizard.h>
#include <cpp/pqc_cscriptslocalization.h>

#include <QSqlQuery>
#include <QSqlDatabase>
#include <QSqlError>
#include <QMessageBox>
#include <QRadioButton>
#include <QTimer>
#include <QDesktopServices>

// NOTE:
// We use a Qt designer approach here (a .ui file) as this allows us to call retranslate() of the ui with ease
// without having to do a lot of manual legwork.

PQCWizard::PQCWizard(bool freshInstall, QWidget *parent) : m_freshInstall(freshInstall), QWizard(parent), m_ui(new Ui::Wizard) {

    m_ui->setupUi(this);

    QPixmap pix(":/other/logo.svg");
    setPixmap(QWizard::LogoPixmap, pix.scaledToWidth(50));
    QPixmap pixW(":/other/wizardwatermark.png");
    setPixmap(QWizard::WatermarkPixmap, pixW);

    m_allAvailableLanguages = PQCCScriptsLocalization::get().getAvailableTranslations();
    m_selectedLanguage = PQCCScriptsLocalization::get().getCurrentTranslation();
    PQCCScriptsLocalization::get().updateTranslation(m_selectedLanguage);

    // The combobox with all available languages
    // The currently selected language will be pre-selected (English by default)
    // a fresh install is easy -> we default to English
    if(m_freshInstall) {
        for(int i = 0; i < m_allAvailableLanguages.length(); ++i) {
            m_ui->langCombo->addItem(PQCCScriptsLocalization::get().getNameForLocalizationCode(m_allAvailableLanguages.at(i)));
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
            m_ui->langCombo->addItem(PQCCScriptsLocalization::get().getNameForLocalizationCode(l));
        }
        m_ui->langCombo->setCurrentIndex(selectedIndex);
    }
    connect(m_ui->langCombo, &QComboBox::currentIndexChanged, this, &PQCWizard::applyCurrentLanguage);
    PQCCScriptsLocalization::get().updateTranslation(m_selectedLanguage);
    m_ui->retranslateUi(this);

    m_ui->radioModern->setChecked(!m_freshInstall);
    m_ui->radioIntegrated->setChecked(m_freshInstall);
    connect(m_ui->radioModern, &QRadioButton::toggled, [=](bool checked) { storeCurrentInterface("modern"); });
    connect(m_ui->radioIntegrated, &QRadioButton::toggled, [=](bool checked) { storeCurrentInterface("integrated"); });
    storeCurrentInterface(freshInstall ? "integrated" : "modern");

    m_ui->buttonWebsite->setFixedHeight(25);
    m_ui->buttonLicense->setFixedHeight(25);
    m_ui->buttonEmail->setFixedHeight(25);
    m_ui->buttonWebsite->setStyleSheet("text-align:left;");
    m_ui->buttonLicense->setStyleSheet("text-align:left;");
    m_ui->buttonEmail->setStyleSheet("text-align:left;");

    connect(m_ui->buttonWebsite, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("https://photoqt.org")); });
    connect(m_ui->buttonLicense, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("https://www.gnu.org/licenses/old-licenses/gpl-2.0.html#SEC1")); });
    connect(m_ui->buttonEmail, &QPushButton::clicked, this, [=]() { QDesktopServices::openUrl(QUrl("mailto:Lukas@PhotoQt.org?subject=Setup Wizard")); });

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

    PQCCScriptsLocalization::get().updateTranslation(m_selectedLanguage);
    m_ui->retranslateUi(this);

}
