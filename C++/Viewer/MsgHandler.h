#ifndef MSGHANDLER_H
#define MSGHANDLER_H

#include <QtMessageHandler>
#include <QString>
#include <QVector>
#include <QRegExp>
#include <iostream>

#define TITLE_1 "css{p class='title1'}"
#define TITLE_2 "css{p class='title2'}"
#define COMMAND "css{p class='command'}"
#define CONN "css{p class='connection'}"

using namespace std;

struct Message {
    QtMsgType type;
    QString text;
    QString css;
};

extern QVector<Message> Messages;

void MsgHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg);

#endif // MSGHANDLER_H
