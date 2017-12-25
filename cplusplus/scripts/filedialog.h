#ifndef FILEDIALOG_H
#define FILEDIALOG_H

#include <QObject>
#include <QFileDialog>

class FileDialog : public QObject {

    Q_OBJECT

public:
    explicit FileDialog(QObject *parent = 0) : QObject(parent) {
        filedialog = nullptr;
    }

    Q_INVOKABLE void getCopyFilename(QString currentDir, QString currentFile, QString suffix) {

        // Delete old filedialog when one already exists. Otherwise the accepted signal will be fired for each once created filedialog
        if(filedialog != nullptr)
            delete filedialog;

        // store suffix to make sure new file has the same suffix
        this->suffix = suffix;

        // Create and open the filedialog (not modal_
        filedialog = new QFileDialog;
        filedialog->setWindowTitle("Copy Image to...");
        filedialog->selectFile(currentDir + "/" + currentFile);
        filedialog->setModal(false);
        filedialog->setNameFilter(suffix);
        filedialog->open();

        // We pass the rejected signal right on, but intercept the accepted one for checking the returned filename
        connect(filedialog, &QFileDialog::rejected, this, &FileDialog::rejected);
        connect(filedialog, &QFileDialog::accepted, this, &FileDialog::diagAccepted);
    }

    Q_INVOKABLE void close() {
        filedialog->close();
    }

private:
    QFileDialog *filedialog;
    QString suffix;

private slots:
    void diagAccepted() {

        // Make sure the new filename has the same suffix as the old filename
        QString fp = filedialog->selectedFiles().at(0);
        if(QFileInfo(fp).suffix() != suffix)
            fp += "." + suffix;

        accepted(fp);

    }

signals:
    void accepted(QString file);
    void rejected();

};

#endif // FILEDIALOG_H
