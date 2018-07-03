#include "Channels.h"

// *************************************************************************
// *                                                                       *
// *   dataChannel class                                                   *
// *                                                                       *
// *************************************************************************

dataChannel::dataChannel(int id, QTcpSocket *C, QVector<dataset*> *S):
    identifier(id), connection(C), Set(S) {

    size = 0;
    available = true;

    // Manage new data
    connect(connection, SIGNAL(readyRead()), this, SLOT(newData()));

    // clock = new QTime;

}

dataChannel::~dataChannel() { connection->disconnectFromHost(); }

/* ---------------------------------------------------------------------- *\
 *  Data handling                                                         *
\* ---------------------------------------------------------------------- */

void dataChannel::newData() {

    // Append data
    buffer.append(connection->readAll());

    // Update status
    if (buffer.size()) { available = false; }

    // Check buffer ?
    if (size>0) { checkBuffer(); }

}

void dataChannel::checkBuffer() {

    // qDebug() << "Buffer " << connection->socketDescriptor() << " - id " << identifier << " at " << buffer.size();

    // if (buffer.size() == 0) { clock->start(); }

    if (buffer.size() == size) {

        // qDebug() << "Ellapsed: " << clock->elapsed() << "ms";

        // --- Process

        if (type == "image") {

            Set[0][index]->layer[z] = new QImage(reinterpret_cast<unsigned char *>(buffer.data()), Set[0][index]->X, Set[0][index]->Y, QImage::Format_Indexed8);

        } else if (type=="vertex") {

        } else if (type=="face") {

        } else if (type=="cmap") {

        }

        // --- Update view

        emit refresh();

        // --- Re-initialize channel

        buffer.clear();
        size = 0;
        index = 0;
        z = 0;
        t = 0;
        type = QString();
        available = true;

        // qDebug() << "Available " << identifier;

        emit setAvailable(identifier);

    }

}

// *************************************************************************
// *                                                                       *
// *   Channels class                                                      *
// *                                                                       *
// *************************************************************************

Channels::Channels(QVector<dataset*> *S):
    Set(S){

    data = new QVector<dataChannel*>;

    // --- Socket for commands

    tcpServer = new QTcpServer(this);
    tcpServer->listen(QHostAddress::LocalHost, port);
    connect(tcpServer, SIGNAL(newConnection()), this, SLOT(setConnection()));

}

Channels::~Channels() { connection->disconnectFromHost(); }

/* ---------------------------------------------------------------------- *\
 *  Set connection for commands                                           *
\* ---------------------------------------------------------------------- */

void Channels::setConnection() {

    if (!connection) {

        connection = tcpServer->nextPendingConnection();
        connect(connection, SIGNAL(readyRead()), this, SLOT(receive()));

        qInfo() << CONN  << "Command connection established";

    } else {

        int id = data->count();
        data->append(new dataChannel(id, tcpServer->nextPendingConnection(), Set));
        connect(data->last(), SIGNAL(refresh()), this, SIGNAL(refresh()));
        connect(data->last(), SIGNAL(setAvailable(int)), this, SLOT(setAvailable(int)));

        qInfo().nospace() << CONN << "New data connection (#" << id << ":" << data->count() << ")";

    }

}

/* ---------------------------------------------------------------------- *\
 *  Sending commands                                                      *
\* ---------------------------------------------------------------------- */

void Channels::send(QString Instr) {

    connection->write((Instr + ";\n").toStdString().c_str());
    connection->flush();

}

/* ---------------------------------------------------------------------- *\
 *  Receiving commands                                                    *
\* ---------------------------------------------------------------------- */

void Channels::receive() {

    Command C = {};

    for (QString com : QString(connection->readAll()).split(";", QString::SkipEmptyParts)) {

        // qInfo() << COMMAND << com.toStdString().c_str() << endl;
        //qDebug() << com.toStdString().c_str();

        QStringList CKV = com.split(":", QString::SkipEmptyParts);
        C.Category = CKV[0];
        C.Identifier = CKV[1].toInt();
        C.Key = CKV[2];
        if (CKV.count()>3) { C.Value = CKV[3]; }

        emit newCommand(C);

    }

}

/* ---------------------------------------------------------------------- *\
 *  Manage data channels                                                  *
\* ---------------------------------------------------------------------- */

/*
void Channels::newDataChannel() {

    int id = data->count();
    data->append(new dataChannel(id, port+id+1, Set));
    connect(data->last(), SIGNAL(refresh()), this, SIGNAL(refresh()));
    connect(data->last(), SIGNAL(setAvailable(int)), this, SLOT(setAvailable(int)));

    qInfo().nospace() << CONN << "New data connection (#" << id << "/" << data->count() << " on port " << port+id << ")";

}
/**/

void Channels::setAvailable(int id) {

    send(QString("available:%1").arg(id));

}
