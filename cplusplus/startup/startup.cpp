#include "startup.h"

PQStartup::PQStartup(const int checker, QWidget *parent) : QDialog(parent) {

    this->setMaximumWidth(800);
    this->setMinimumWidth(600);

    this->checker = checker;

    QLabel *title;
    if(checker == 1)
        title = new QLabel("Welcome back to PhotoQt");
    else
        title = new QLabel("Welcome to PhotoQt");
    title->setStyleSheet("font-size: 35pt; font-weight: bold");
    title->setAlignment(Qt::AlignHCenter);

    QLabel *desc1 = new QLabel("PhotoQt is an image viewer that aims to be very flexible in order to adapt to your needs and workflow instead of the other way around. Thus, most things and behaviours can be adjusted in the settings manager.");
    desc1->setStyleSheet("font-size: 11pt;");
    desc1->setWordWrap(true);

    QLabel *desc2 = new QLabel("<b>In order to complete the update, some things need to be updated/migrated (done automatically).</b> Simply close this window to continue.");
    desc2->setStyleSheet("font-size: 11pt;");
    desc2->setWordWrap(true);

    QLabel *desc3 = new QLabel("<b>Website:</b> <a href=\"https://photoqt.org\">https://photoqt.org</a>&nbsp;&mdash;&nbsp;<b>Contact:</b> <a href=\"mailto:Lukas@photoqt.org\">Lukas@photoqt.org</a>");
    desc3->setStyleSheet("font-size: 11pt;");
    desc3->setAlignment(Qt::AlignHCenter);
    desc3->setWordWrap(true);
    connect(desc3, &QLabel::linkActivated, this, &PQStartup::linkClicked);

    QPushButton *but = new QPushButton("Open PhotoQt");
    but->setStyleSheet("font-weight: bold; font-size: 15pt;");
    but->setMaximumWidth(400);
    QHBoxLayout *butLay = new QHBoxLayout;
    butLay->addStretch();
    butLay->addWidget(but);
    butLay->addStretch();


    QVBoxLayout *mainLayout = new QVBoxLayout;
    mainLayout->setMargin(20);
    this->setLayout(mainLayout);

    mainLayout->addWidget(title);
    mainLayout->addSpacing(20);
    mainLayout->addWidget(desc1);
    mainLayout->addSpacing(10);
    if(checker == 1) {
        mainLayout->addWidget(desc2);
        mainLayout->addSpacing(10);
    }
    mainLayout->addWidget(desc3);
    mainLayout->addSpacing(10);
    mainLayout->addLayout(butLay);

    connect(but, &QPushButton::clicked, this, &QDialog::close);


}

// 0: no update
// 1: update
// 2: fresh install
int PQStartup::check() {

    QSqlDatabase db;

    // check if sqlite is available
    // this is a hard requirement now and we wont launch PhotoQt without it
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "startup");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "startup");
    else {
        LOG << CURDATE << "PQStartup::check(): ERROR: SQLite driver not available. Available drivers are: " << QSqlDatabase::drivers().join(",").toStdString() << NL;
        LOG << CURDATE << "PQStartup::check(): PhotoQt cannot function without SQLite available." << NL;
        //: This is the window title of an error message box
        QMessageBox::critical(0, QCoreApplication::translate("PQStartup", "SQLite error"),
                                 QCoreApplication::translate("PQStartup", "You seem to be missing the SQLite driver for Qt. This is needed though for a few different things, like reading and writing the settings. Without it, PhotoQt cannot function!"));
        std::exit(1);
    }

    // if we are on dev, we pretend to always update
    if(QString(VERSION) == "dev")
        return 1;

    // if no config files exist, then it is a fresh install
    if((!QFile::exists(ConfigFiles::SETTINGS_FILE()) && !QFile::exists(ConfigFiles::SETTINGS_DB())) ||
        !QFile::exists(ConfigFiles::IMAGEFORMATS_DB()) ||
        !QFile::exists(ConfigFiles::SHORTCUTS_FILE())) {
        return 2;
    }

    // 2.4 and older used a settings file
    // 2.5 and later uses a settings database
    if(QFile::exists(ConfigFiles::SETTINGS_FILE()) && !QFile::exists(ConfigFiles::SETTINGS_DB()))
        return 1;

    // open database
    db.setDatabaseName(ConfigFiles::SETTINGS_DB());
    if(!db.open())
        LOG << CURDATE << "PQStartup::check(): Error opening database: " << db.lastError().text().trimmed().toStdString() << NL;

    // compare version string in database to current version string
    QSqlQuery query(db);
    if(!query.exec("SELECT `value` from `general` where `name`='Version'"))
        LOG << CURDATE << "PQStartup::check(): SQL query error: " << query.lastError().text().trimmed().toStdString() << NL;
    query.next();

    // close database
    db.close();

    // updated
    QString version = query.record().value(0).toString();
    if(version != QString(VERSION))
        return 1;

    // nothing happened
    return 0;

}

void PQStartup::linkClicked(const QString &url) {

    QDesktopServices::openUrl(QUrl(url));

}

void PQStartup::hideEvent(QHideEvent *e) {

    if(checker == 1)
        performChecksAndMigrations();
    else
        setupFresh();

    return QDialog::hideEvent(e);

}

void PQStartup::setupFresh() {

    qDebug() << "setupFresh";

}

void PQStartup::performChecksAndMigrations() {

    qDebug() << "performChecksAndMigrations";

}
