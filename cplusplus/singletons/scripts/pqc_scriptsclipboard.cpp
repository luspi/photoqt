#include <scripts/pqc_scriptsclipboard.h>
#include <QMimeData>
#include <QApplication>
#include <QClipboard>
#include <QUrl>
#include <QTextDocumentFragment>

PQCScriptsClipboard::PQCScriptsClipboard() {
    clipboard = qApp->clipboard();
    connect(clipboard, &QClipboard::dataChanged, this, &PQCScriptsClipboard::clipboardUpdated);
}

PQCScriptsClipboard::~PQCScriptsClipboard() {}

bool PQCScriptsClipboard::areFilesInClipboard() {

    const QMimeData *mimeData = clipboard->mimeData();

    if(mimeData == nullptr)
        return false;

    if(!mimeData->hasUrls())
        return false;

    return true;
}

void PQCScriptsClipboard::copyFilesToClipboard(QStringList files) {

    qDebug() << "args: files =" << files;

    if(files.length() == 0)
        return;

    QMimeData* mimeData = new QMimeData();

    QList<QUrl> allurls;
    for(auto &f : std::as_const(files))
        allurls.push_back(QUrl::fromLocalFile(f));
    mimeData->setUrls(allurls);
    clipboard->setMimeData(mimeData);

}

QStringList PQCScriptsClipboard::getListOfFilesInClipboard() {

    qDebug() << "";

    const QMimeData *mimeData = clipboard->mimeData();

    if(mimeData == nullptr)
        return QStringList();

    if(!mimeData->hasUrls())
        return QStringList();

    QList<QUrl> allurls = mimeData->urls();

    QStringList ret;
    for(auto &u : std::as_const(allurls))
        ret << u.toLocalFile();

    return ret;

}

void PQCScriptsClipboard::copyTextToClipboard(QString txt, bool removeHTML) {

    qDebug() << "args: txt.length =" << txt.length();
    qDebug() << "args: removeHTML =" << removeHTML;

    if(removeHTML)
        txt = QTextDocumentFragment::fromHtml(txt).toPlainText();

    clipboard->setText(txt, QClipboard::Clipboard);

}

QString PQCScriptsClipboard::getTextFromClipboard() {

    qDebug() << "";

    return clipboard->text();

}
