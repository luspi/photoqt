#include <pqc_wizard.h>
#include <QVBoxLayout>
#include <QRadioButton>

PQCWizard::PQCWizard(QWidget *parent) : QWizard(parent) {

    setWindowTitle("PhotoQt startup wizard");
    setButtonText(QWizard::CancelButton, "Skip wizard");
    setButtonText(QWizard::FinishButton, "Start PhotoQt");

    setWizardStyle(QWizard::ModernStyle);

    QPixmap pix(":/other/logo.svg");
    setPixmap(QWizard::LogoPixmap, pix.scaledToWidth(50));

    addPage(createIntroPage());
    addPage(createInterfaceVariantPage());

}

QWizardPage *PQCWizard::createIntroPage() {

    QWizardPage *page = new QWizardPage;

    page->setTitle(tr("Welcome to PhotoQt"));
    page->setSubTitle("Introduction");

    QLabel *topLabel = new QLabel(tr("PhotoQt is a simple yet powerful and good looking image viewer, based on Qt/QML, published as open-source and completely free."));
    topLabel->setWordWrap(true);

    QLabel *txtLabel = new QLabel(tr("This wizard will guide you through some initial choices. If you don't know what to do, don't worry. Anything and everything in PhotoQt can be adjusted from its powerful settings manager at any point in time."));
    txtLabel->setWordWrap(true);

    QVBoxLayout *layout = new QVBoxLayout;
    layout->addWidget(topLabel);
    layout->addWidget(txtLabel);
    page->setLayout(layout);

    return page;

}

QWizardPage *PQCWizard::createInterfaceVariantPage() {

    QWizardPage *page = new QWizardPage;

    page->setTitle(tr("Welcome to PhotoQt"));
    page->setSubTitle("Interface Variant");

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
