#include <pqctest_scripts.h>
//QTEST_MAIN(PQCTESTScripts)

int main(int argc, char **argv) {

    QCoreApplication::setApplicationName("PhotoQt");
    QCoreApplication::setOrganizationName("");
    QCoreApplication::setOrganizationDomain("photoqt.org");
    QCoreApplication::setApplicationVersion(VERSION);

    QApplication app(argc, argv);

    PQCTESTScripts tc;
    return QTest::qExec(&tc, argc, argv);

}
