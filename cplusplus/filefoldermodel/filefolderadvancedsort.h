#ifndef PQFILEFOLDERADVANCEDSORT_H
#define PQFILEFOLDERADVANCEDSORT_H

#include <QObject>
#include <QRunnable>
#include "../imageprovider/imageproviderfull.h"
#include "../settings/settings.h"

class PQFileFolderAvancedSort : public QObject {

    Q_OBJECT

public:
    void advancedSort(const QStringList &filenames);



};

class PQFileFolderAvancedSortASYNC : public QRunnable {

    Q_OBJECT

public:
    PQFileFolderAvancedSortASYNC(const QStringList &filenames);
    ~PQFileFolderAvancedSortASYNC();

    void run() override;

private:
    PQImageProviderFull *imageprovider;

};


#endif // PQFILEFOLDERADVANCEDSORT_H
