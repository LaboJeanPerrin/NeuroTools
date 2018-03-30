#include "dataset.h"

dataset::dataset() {

    layer = QVector<QImage*>();
    t = 1;
    visible = true;
    frozen = false;

    for(int i = 0; i<256; i++) { cmap.push_back(qRgba(i,i,i,255)); }

}

void dataset::setZ(int value) {

    Z = value;
    layer = QVector<QImage*>(Z);

}
