#include <pqc_wizard.h>
#include <QVBoxLayout>
#include <QRadioButton>

PQCWizard::PQCWizard(bool freshInstall, QWidget *parent) : m_freshInstall(freshInstall), QWizard(parent) {

    setWindowTitle("PhotoQt startup wizard");
    setButtonText(QWizard::CancelButton, "Skip wizard");
    setButtonText(QWizard::FinishButton, "Start PhotoQt");

    setWizardStyle(QWizard::ModernStyle);

    QPixmap pix(":/other/logo.svg");
    setPixmap(QWizard::LogoPixmap, pix.scaledToWidth(50));
    QPixmap pixW(":/other/wizardwatermark.png");
    setPixmap(QWizard::WatermarkPixmap, pixW);

    addPage(createIntroPage());
    addPage(createInterfaceVariantPage());

}

QWizardPage *PQCWizard::createIntroPage() {

    QWizardPage *page = new QWizardPage;

    if(m_freshInstall)
        page->setTitle(tr("Welcome to PhotoQt"));
    else
        page->setTitle("Welcome to a new PhotoQt");
    page->setSubTitle("PhotoQt is a simple yet powerful and good looking image viewer.");

    QLabel *headerLabel = new QLabel(tr("Welcome to PhotoQt. This wizard will guide you through some initial setup."));
    QFont ft = headerLabel->font();
    ft.setBold(true);
    headerLabel->setFont(ft);
    headerLabel->setWordWrap(true);
    QLabel *topLabel = new QLabel(tr("If you don't know what to do, don't worry. Anything and everything in PhotoQt can be adjusted from its powerful settings manager at any point in time."));
    topLabel->setWordWrap(true);

    QLabel *txtLabel = new QLabel(tr("Thank you for using PhotoQt."));
    txtLabel->setWordWrap(true);

    QLabel *metaLabel = new QLabel(tr("Website:") + " https://photoqt.org<br>" +
                                   tr("License:") + " GPLv2<br>" +
                                   tr("Contact:") + " Lukas@PhotoQt.org");
    QFont ftm = metaLabel->font();
    ftm.setPointSize(ftm.pointSize()*0.9);
    metaLabel->setFont(ftm);

    QVBoxLayout *layout = new QVBoxLayout;
    layout->setSpacing(10);
    layout->addSpacing(20);
    layout->addWidget(headerLabel);
    layout->addWidget(topLabel);
    layout->addWidget(txtLabel);
    layout->addStretch();
    layout->addWidget(metaLabel);
    page->setLayout(layout);

    return page;

}

QWizardPage *PQCWizard::createInterfaceVariantPage() {

    QWizardPage *page = new QWizardPage;

    page->setTitle(tr("Interface Variant"));
    page->setSubTitle("The general type of look.");

    QLabel *topLabel = new QLabel("PhotoQt offers two types of graphical interfaces for you to choose from: You can either select a highly customizable interface that allows for a lot of styling and acts as more of a floating layer presenting your images. Or alternatively you can choose a more traditional interface that attempts to integrate nicely into whatever your system looks like.");
    topLabel->setWordWrap(true);

    QRadioButton *radioModern = new QRadioButton("customizable interface");
    QRadioButton *radioIntegrated = new QRadioButton("integrated interface");

    QLabel *botLabel = new QLabel("Note that any choice you make now is never final. You can switch the interface variant at any time from the settings manager.");
    botLabel->setWordWrap(true);

    QVBoxLayout *layout = new QVBoxLayout;
    layout->addWidget(topLabel);
    layout->addWidget(radioModern);
    layout->addWidget(radioIntegrated);
    layout->addWidget(botLabel);
    page->setLayout(layout);

    return page;

}
