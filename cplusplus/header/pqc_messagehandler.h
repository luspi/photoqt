// This file is included in main.cpp
// and this function is installed as message handler

void pqcMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg) {

    QByteArray localMsg = msg.toLocal8Bit();
    const char *file = context.file ? context.file : "";
    const char *function = context.function ? context.function : "";
    const QDateTime date = QDateTime::currentDateTime();
    const QFileInfo fileinfo(file);
    QByteArray filename = fileinfo.fileName().toLatin1();
    switch (type) {
    case QtDebugMsg:
#ifdef NDEBUG
        if(PQCNotify::get().getDebug())
#endif
            fprintf(stderr, "[%s] [D] %s::%s:%u: %s\n", date.toString("yyyy-MM-dd HH:mm:ss.zzz").toLatin1().constData(), filename.constData(), function, context.line, localMsg.constData());
        break;
    case QtInfoMsg:
        fprintf(stderr, "[%s] [I] %s::%s:%u: %s\n", date.toString("yyyy-MM-dd HH:mm:ss.zzz").toLatin1().constData(), filename.constData(), function, context.line, localMsg.constData());
        break;
    case QtWarningMsg:
        fprintf(stderr, "[%s] [W] %s::%s:%u: %s\n", date.toString("yyyy-MM-dd HH:mm:ss.zzz").toLatin1().constData(), filename.constData(), function, context.line, localMsg.constData());
        break;
    case QtCriticalMsg:
        fprintf(stderr, "[%s] [C] %s::%s:%u: %s\n", date.toString("yyyy-MM-dd HH:mm:ss.zzz").toLatin1().constData(), filename.constData(), function, context.line, localMsg.constData());
        break;
    case QtFatalMsg:
        fprintf(stderr, "[%s] [F] %s::%s:%u: %s\n", date.toString("yyyy-MM-dd HH:mm:ss.zzz").toLatin1().constData(), filename.constData(), function, context.line, localMsg.constData());
        std::exit(1);
        break;
    }
}
