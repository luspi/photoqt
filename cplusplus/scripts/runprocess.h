#ifndef RUNPROCESS_H
#define RUNPROCESS_H

#include <QProcess>
#include <QApplication>
#include <thread>

// This is a convenience class to start a process and receive the standard output with ease
class RunProcess : public QObject {

    Q_OBJECT

public:
    explicit RunProcess() {
        proc = new QProcess;
        gotOutput = false;
        error = false;
        connect(proc, SIGNAL(readyRead()), this, SLOT(read()));
        connect(proc, SIGNAL(error(QProcess::ProcessError)), this, SLOT(readError(QProcess::ProcessError)));
    }
    ~RunProcess() { while(proc->waitForFinished()) {} delete proc; }
    // START PROCESS
    void start(QString exec) {
        gotOutput = false;
        error = false;
        proc->start(exec);
    }

    // GET INFO
    QString getOutput() { return output; }
    bool gotError() { return error; }
    int getErrorCode() { return errorCode; }

    // WAIT FUNCTION
    bool waitForOutput() {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        QApplication::processEvents();
        return !gotOutput;
    }

private:
    QProcess *proc;
    QString output;
    bool gotOutput;
    bool error;
    int errorCode;

private slots:
    void read() {
        output = proc->readAll();
        gotOutput = true;
    }
    void readError(QProcess::ProcessError e) {
        output = "";
        error = true;
        gotOutput = true;
        errorCode = e;
    }

};


#endif // RUNPROCESS_H
