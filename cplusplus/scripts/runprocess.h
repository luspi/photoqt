/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

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
