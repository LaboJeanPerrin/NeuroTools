#ifndef CHANNELS_H
#define CHANNELS_H

#include <QDebug>
#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>
#include <QByteArray>
#include <QString>
#include <QVector>
#include <QVector3D>
#include <QTime>

#include "dataset.h"
#include "MsgHandler.h"

// === Custom sructures ====================================================

struct Command {

/*
 * Category can be either:
 *  - 'view' for viewing parameters
 *  - An unsigned int, to select a dataset.
 */

   QString Category;
   int Identifier;
   QString Key;
   QString Value;
};


// === dataChannel class ===================================================

class dataChannel : public QObject {

    Q_OBJECT

public:

    dataChannel(int, QTcpSocket *, QVector<dataset*> *);
    ~dataChannel();

    void checkBuffer();

    QVector<dataset*> *Set;
    int identifier, size, index, z, t;
    QString type;
    bool available;

public slots:

    // void setConnection();
    void newData();

signals:

    void setAvailable(int);
    void refresh();

private:

    QTcpSocket *connection;
    QByteArray buffer;

    // QTime *clock;

};

// === Channels class ======================================================

class Channels : public QObject {

    Q_OBJECT

public:

    Channels(QVector<dataset*> *);
    ~Channels();

    void send(QString);
    // void newDataChannel();

    QVector<dataset*> *Set;
    QVector<dataChannel*> *data;

public slots:

    void setConnection();
    void receive();
    void setAvailable(int);

signals:

    void newCommand(Command);
    void refresh();


private:

    const int port = 3231;
    QTcpServer *tcpServer = nullptr;
    QTcpSocket *connection = nullptr;

};

#endif // CHANNELS_H
