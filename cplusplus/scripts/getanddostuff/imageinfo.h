#ifndef GETANDDOSTUFFIMAGEINFO_H
#define GETANDDOSTUFFIMAGEINFO_H

#include <QObject>
#include "../../imageprovider/imageproviderfull.h"

class GetAndDoStuffImageInfo : public QObject {

	Q_OBJECT

public:
	explicit GetAndDoStuffImageInfo(QObject *parent = 0);
	~GetAndDoStuffImageInfo();

	QList<int> getGreyscaleHistogramValues(QString filename);
	QList<int> getColorHistogramValues(QString filename);

private:
	ImageProviderFull *provider;

};

#endif // GETANDDOSTUFFIMAGEINFO_H
