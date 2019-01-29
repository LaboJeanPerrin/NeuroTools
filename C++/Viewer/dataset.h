#ifndef DATASET_H
#define DATASET_H

#include <QString>
#include <QVector>
#include <QImage>
#include <QVector3D>
#include <QTransform>

class dataset {

public:

    dataset();
    void setZ(int);

    QString name;
    QString type;

    int X, Y, Z, T, t;
    QVector3D vertex, face;
    QVector<QImage*> layer;
    QTransform transform;

    QVector<QRgb> cmap;
    float x2um, y2um, z2um, t2s;
    bool visible, frozen;

private:

};

#endif // DATASET_H
