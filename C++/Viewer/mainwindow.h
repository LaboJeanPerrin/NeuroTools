#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QDebug>
#include <QApplication>
#include <QMainWindow>
#include <QDesktopWidget>
#include <QShortcut>
#include <QGridLayout>
#include <QLabel>
#include <QSlider>
#include <QTextEdit>
#include <QScrollBar>
#include <QTimer>

#include <QtNetwork>
#include <QThread>

#include <QVector3D>
#include <QColormap>
#include <QtDataVisualization>
#include <Q3DScatter>
#include <Q3DCamera>
#include <QCustom3DVolume>
#include <QTransform>

#include "MsgHandler.h"
#include "Channels.h"
#include "dataset.h"

// === Namespaces ==========================================================

using namespace std;
using namespace QtDataVisualization;

// === Custom types ========================================================

struct WindowTheme {

    QString name;
    QString backgroundColor;
    QString textColor;
    QString labelLightStyle;
    QString labelDarkStyle;
    QString consoleStyleFile;
    QString slider;

};

// === Mainwindow class ====================================================

namespace Ui { class MainWindow; }

class MainWindow : public QMainWindow {

    Q_OBJECT

public:

    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

    void updateTopBar();
    void updateBottomBar();

    // --- Data ---------------------------------

    QVector<dataset*> Set;

    QCustom3DVolume *volume;
    QVector<uchar> *VData;
    QVector<QRgb> cmap;


public slots:

    // --- Console
    void updateConsole();

    // --- Commands
    void newCommand(Command);

    // --- Display
    void refreshView();
    void updateDisplay();


private:

    // --- Appearance ---------------------------

    // --- Screen
    QVector<QRect> Screens;
    int screen;

    // --- Window
    Ui::MainWindow *ui;
    QSize windowSize;
    QShortcut *s_Close;
    WindowTheme Theme;

    // --- Layout
    QGridLayout *mainLayout;

    QLabel *topLabel1;
    QLabel *topLabel2;
    QLabel *topLabel3;
    QLabel *topLabel4;
    QLabel *topLabel5;
    QLabel *topLabel6;

    QGridLayout *sideBarLayout;
    QLabel *sideBarTemp;
    QTextEdit *logConsole;

    QLabel *viewImage;
    QSlider *timeSlider;
    QGridLayout *viewLayout;

    QLabel *bottomLabel1;
    QLabel *bottomLabel2;
    QLabel *bottomLabel3;
    QLabel *bottomLabel4;
    QLabel *bottomLabel5;
    QLabel *bottomLabel6;

    // --- Display
    QTimer *dispTimer;
    int prevSliderValue;

    // --- Parameters
    QString view;
    QString theme;

    // --- Channels -----------------------------

    Channels *channel;

};

#endif // MAINWINDOW_H
