// This file is included in main.cpp
// and this function is installed as message handler

void pqcMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg) {

    const char *file = context.file ? context.file : "";
    const char *function = context.function ? context.function : "";
    const QDateTime date = QDateTime::currentDateTime();
    const QFileInfo fileinfo(file);
    QByteArray filename = fileinfo.fileName().toLatin1();
    switch (type) {
    case QtDebugMsg:
#ifdef NDEBUG
        if(PQCNotify::get().getDebug()) {
#endif
            PQCNotify::get().addDebugLogMessages(QString("%1 [D] %2::%3::%4: %5\n").arg(date.toString("yyyy-MM-dd HH:mm:ss.zzz")).arg(filename).arg(function).arg(context.line).arg(msg));
            fprintf(stderr, "%s [D] %s::%s::%u: %s\n", date.toString("yyyy-MM-dd HH:mm:ss.zzz").toLatin1().constData(), filename.constData(), function, context.line, msg.toLocal8Bit().constData());
#ifdef NDEBUG
        }
#endif
        break;
    case QtInfoMsg:
        PQCNotify::get().addDebugLogMessages(QString("%1 [I] %2::%3::%4: %5\n").arg(date.toString("yyyy-MM-dd HH:mm:ss.zzz")).arg(filename).arg(function).arg(context.line).arg(msg));
        fprintf(stderr, "%s [I] %s::%s::%u: %s\n", date.toString("yyyy-MM-dd HH:mm:ss.zzz").toLatin1().constData(), filename.constData(), function, context.line, msg.toLocal8Bit().constData());
        break;
    case QtWarningMsg:
        PQCNotify::get().addDebugLogMessages(QString("%1 [W] %2::%3::%4: %5\n").arg(date.toString("yyyy-MM-dd HH:mm:ss.zzz")).arg(filename).arg(function).arg(context.line).arg(msg));
        fprintf(stderr, "%s [W] %s::%s::%u: %s\n", date.toString("yyyy-MM-dd HH:mm:ss.zzz").toLatin1().constData(), filename.constData(), function, context.line, msg.toLocal8Bit().constData());
        break;
    case QtCriticalMsg:
        PQCNotify::get().addDebugLogMessages(QString("%1 [C] %2::%3::%4: %5\n").arg(date.toString("yyyy-MM-dd HH:mm:ss.zzz")).arg(filename).arg(function).arg(context.line).arg(msg));
        fprintf(stderr, "%s [C] %s::%s::%u: %s\n", date.toString("yyyy-MM-dd HH:mm:ss.zzz").toLatin1().constData(), filename.constData(), function, context.line, msg.toLocal8Bit().constData());
        break;
    case QtFatalMsg:
        PQCNotify::get().addDebugLogMessages(QString("%1 [F] %2::%3::%4: %5\n").arg(date.toString("yyyy-MM-dd HH:mm:ss.zzz")).arg(filename).arg(function).arg(context.line).arg(msg));
        fprintf(stderr, "%s [F] %s::%s::%u: %s\n", date.toString("yyyy-MM-dd HH:mm:ss.zzz").toLatin1().constData(), filename.constData(), function, context.line, msg.toLocal8Bit().constData());
        std::exit(1);
        break;
    }
}
