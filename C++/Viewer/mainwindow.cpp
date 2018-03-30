#include "mainwindow.h"
#include "ui_mainwindow.h"

/*
 * General
 *  - Gérer plusieurs canaux de données, avec ouverture sur besoin et monitoring
 *  - Lancement depuis Matlab
 *  - Test autres ordis
 *
 * Vue 3D
 *  - Mise au point
 *  - Gérer le zoom
 *  - Gérer les overlays
 *  - Gérer les données vectorielles
 *  - Gérer la selection
 *
 * Side bar
 *  - View tab
 *  - Dataset tab
 *  - Matlab console
 *
 *  Montage
 *  - Mise au point
 *  - Gérer le zoom
 *  - Gérer les overlays
 *  - Gérer les données vectorielles
 *  - Gérer la selection
 *
 * */

/* ---------------------------------------------------------------------- *\
 *  Constructor                                                           *
\* ---------------------------------------------------------------------- */

MainWindow::MainWindow(QWidget *parent):
    QMainWindow(parent), ui(new Ui::MainWindow) {

    // === DEFINITIONS =====================================================

    view = QString("3D");   // "Montage" or "3D"

    // Theme
    Theme.name = "Dark";
    Theme.backgroundColor = "#000000;";
    Theme.textColor = "#FFFFFF";
    Theme.labelLightStyle = "QLabel { background-color: #2A2A2A; color: #FFFFFF; padding: 0 5px; }";
    Theme.labelDarkStyle = "QLabel { background-color: #1A1A1A; color: #FFFFFF;  padding: 0 5px; }";
    Theme.consoleStyleFile = "consoleDark.css";
    Theme.slider = "QSlider::groove { border: none; background: #333; height: 10px; } QSlider::handle:horizontal { background: #AAA; border: none; width: 20px;}";

    // === USER INTERFACE ==================================================

    qInfo() << TITLE_1 << "Initialization";

    // --- Screens

    qInfo() << TITLE_2 << "Screen";

    QDesktopWidget Desktop;
    switch (Desktop.screenCount()) {
        case 0:  qInfo() << "No screen detected"; break;
        case 1:  qInfo() << "1 screen detected"; break;
        default: qInfo() << Desktop.screenCount() << "screens detected"; break;
    }

    for (int i=0; i<Desktop.screenCount(); i++) {
       Screens.push_back(Desktop.availableGeometry(i));
       qInfo().nospace() << " [" << i << "] " << Desktop.availableGeometry(i);
    }

    // The current screen
    screen = 0;

    // --- Window

    ui->setupUi(this);
    this->setWindowTitle("NeuroTools Viewer");
    ui->statusBar->setHidden(true);

    // Style
    this->setStyleSheet("background-color: " + Theme.backgroundColor + "; color: " + Theme.textColor + ";");
    QFont font("Courier New");
    font.setStyleHint(QFont::Monospace);
    font.setPixelSize(14);
    QApplication::setFont(font);

    // Window size
    this->setWindowFlags(Qt::FramelessWindowHint);
    this->showFullScreen();
    windowSize = QSize(Screens[screen].x()+Screens[screen].width(), Screens[screen].y()+Screens[screen].height());

    // --- Grid layout
    mainLayout = new QGridLayout(ui->centralWidget);
    mainLayout->setSpacing(0);
    mainLayout->setContentsMargins(0,0,0,0);

    // --- Top bar
    topLabel1 = new QLabel();
    topLabel2 = new QLabel();
    topLabel3 = new QLabel();
    topLabel4 = new QLabel();
    topLabel5 = new QLabel();
    topLabel6 = new QLabel();

    topLabel1->setStyleSheet(Theme.labelLightStyle);
    topLabel2->setStyleSheet(Theme.labelDarkStyle);
    topLabel3->setStyleSheet(Theme.labelLightStyle);
    topLabel4->setStyleSheet(Theme.labelDarkStyle);
    topLabel5->setStyleSheet(Theme.labelLightStyle);
    topLabel6->setStyleSheet(Theme.labelDarkStyle);

    topLabel1->setFixedHeight(25);

    mainLayout->addWidget(topLabel1, 0, 0);
    mainLayout->addWidget(topLabel2, 0, 1);
    mainLayout->addWidget(topLabel3, 0, 2);
    mainLayout->addWidget(topLabel4, 0, 3);
    mainLayout->addWidget(topLabel5, 0, 4);
    mainLayout->addWidget(topLabel6, 0, 5);

    // --- Left bar

    sideBarLayout = new QGridLayout();

    sideBarTemp = new QLabel("---");
    sideBarTemp->setStyleSheet(Theme.labelDarkStyle);

    logConsole = new QTextEdit();
    logConsole->setReadOnly(true);
    logConsole->setFixedWidth(windowSize.width()/6);

    // Style
    QFile File(Theme.consoleStyleFile);
    File.open(QFile::ReadOnly);
    QTextDocument *OutDoc = new QTextDocument;
    OutDoc->setDefaultStyleSheet(File.readAll());
    OutDoc->setDefaultFont(QFontDatabase::systemFont(QFontDatabase::FixedFont));
    logConsole->setDocument(OutDoc);

    sideBarLayout->addWidget(sideBarTemp, 0, 0);
    sideBarLayout->addWidget(logConsole, 1, 0);

    mainLayout->addLayout(sideBarLayout, 1, 0);

    // --- View Layout

    viewLayout = new QGridLayout();

    viewImage = new QLabel();
    viewImage->setFixedHeight(1000);


    timeSlider = new QSlider(Qt::Horizontal, this);
    timeSlider->setStyleSheet(Theme.slider);
    prevSliderValue = 0;

    viewLayout->addWidget(viewImage, 0, 0);
    viewLayout->addWidget(timeSlider, 1, 0);

    mainLayout->addLayout(viewLayout, 1, 1, 1, 5);

    // --- Bottom bar
    bottomLabel1 = new QLabel();
    bottomLabel2 = new QLabel("0");
    bottomLabel3 = new QLabel();
    bottomLabel4 = new QLabel();
    bottomLabel5 = new QLabel();
    bottomLabel6 = new QLabel();

    bottomLabel1->setStyleSheet(Theme.labelLightStyle);
    bottomLabel2->setStyleSheet(Theme.labelDarkStyle);
    bottomLabel3->setStyleSheet(Theme.labelLightStyle);
    bottomLabel4->setStyleSheet(Theme.labelDarkStyle);
    bottomLabel5->setStyleSheet(Theme.labelLightStyle);
    bottomLabel6->setStyleSheet(Theme.labelDarkStyle);

    bottomLabel1->setFixedHeight(25);

    mainLayout->addWidget(bottomLabel1, 2, 0);
    mainLayout->addWidget(bottomLabel2, 2, 1);
    mainLayout->addWidget(bottomLabel3, 2, 2);
    mainLayout->addWidget(bottomLabel4, 2, 3);
    mainLayout->addWidget(bottomLabel5, 2, 4);
    mainLayout->addWidget(bottomLabel6, 2, 5);

    // --- Shortcuts

    // Esc: Close
    s_Close = new QShortcut(Qt::Key_Escape, this);
    connect(s_Close, SIGNAL(activated()), QApplication::instance(), SLOT(quit()));

    // --- Set content

    updateTopBar();
    updateBottomBar();

    QTimer *t_console = new QTimer();
    connect(t_console, SIGNAL(timeout()), this, SLOT(updateConsole()));
    t_console->start(50);

    // === CHANNELS ========================================================

    channel = new Channels(&Set);
    connect(channel, SIGNAL(newCommand(Command)), this, SLOT(newCommand(Command)));
    connect(channel, SIGNAL(refresh()), this, SLOT(refreshView()));

    // === DISPLAY =========================================================

    dispTimer = new QTimer(this);
    connect(dispTimer, SIGNAL(timeout()), this, SLOT(updateDisplay()));
    dispTimer->start(40);


    /*

    // === Data visualization ==============================================

    // QVector3D VSize(2544, 1382, 400);
    // QVector3D VSize(1272, 692, 199);
    // QVector3D VSize(636, 348, 99);
    // QVector3D VSize(320, 176, 49);
    QVector3D VSize(160, 88, 24);

    Q3DScatter *view = new Q3DScatter();
    view->setShadowQuality(QAbstract3DGraph::ShadowQualityNone);
    view->setOptimizationHints(QAbstract3DGraph::OptimizationStatic);

    Q3DTheme *theme = new Q3DTheme(Q3DTheme::ThemeEbony);
    theme->setLightStrength(0);
    view->setActiveTheme(theme);
    view->activeTheme()->setGridEnabled(true);
    view->activeTheme()->setBackgroundEnabled(false);
    view->setOrthoProjection(true);
    view->scene()->activeCamera()->setCameraPreset(Q3DCamera::CameraPresetIsometricLeft);
    view->scene()->activeCamera()->setZoomLevel(75);
    view->axisX()->setRange(0, VSize.x());
    view->axisY()->setRange(0, VSize.z());
    view->axisZ()->setRange(0, VSize.y());

    view->setAspectRatio(VSize.x()/VSize.z());

    // --- Manage Data

    QScatter3DSeries *series = new QScatter3DSeries;
    QScatterDataArray data;

    for (int i=0; i<1e3; i++) {

        float x = ((float) rand() / (RAND_MAX))*VSize.x();
        float y = ((float) rand() / (RAND_MAX))*VSize.z();
        float z = ((float) rand() / (RAND_MAX))*VSize.y();

        data <<  QVector3D(x, y, z);

    }

    series->dataProxy()->addItems(data);
    series->setBaseColor(QColor(255,100,100));

    series->setMesh(QAbstract3DSeries::MeshPoint);


    // series->setMesh(QAbstract3DSeries::MeshSphere);
    // series->setItemSize(0.02);
    // series->setMeshSmooth(false);

    view->addSeries(series);

    // --- Volume ----------------------------------------------------------



    // --- Volume

    Volume = new QCustom3DVolume;
    Volume->setScalingAbsolute(false);
    Volume->setScaling(QVector3D(VSize.x(),VSize.z(),VSize.y()));
    Volume->setPosition(QVector3D(VSize.x()/2, VSize.z()/2, VSize.y()/2));

    Volume->setTextureWidth(VSize.x());
    Volume->setTextureHeight(VSize.z());
    Volume->setTextureDepth(VSize.y());
    Volume->setTextureFormat(QImage::Format_Indexed8);

    Volume->setTextureData(new QVector<uchar>(VSize.x()*VSize.y()*VSize.z(), 0));

    // --- 3D Data array
    /*
    VData->fill(0);

    for (int z=0; z<VSize.z(); z++) {
        for (int y=0; y<VSize.y(); y++) {
            for (int x=0; x<VSize.x(); x++) {
                unsigned char v = 255*exp(-((x-VSize.x()/2)*(x-VSize.x()/2) + (y-VSize.y()/2)*(y-VSize.y()/2) + (z-VSize.z()/2)*(z-VSize.z()/2))/200);
                if (v>1) {
                    (*VData)[x + y*VSize.x() + z*VSize.x()*VSize.y()] = v;
                }
            }
        }
    }

    Volume->setTextureData(new QVector<uchar>(*VData));
    */

    /*

    for (int i=0; i<VSize.z(); i++) {

        // QString fname = "/home/ljp/Science/Projects/NeuroTools/Data/Scans/scan/Frame_" + QString("%1").arg((int)VSize.z()-i-1, 6, 10, QLatin1Char('0')); + ".pgm";
        // QString fname = "/home/ljp/Science/Projects/NeuroTools/Data/Scans/sub2/Frame_" + QString("%1").arg((int)VSize.z()-i-1, 6, 10, QLatin1Char('0')); + ".pgm";
        // QString fname = "/home/ljp/Science/Projects/NeuroTools/Data/Scans/sub4/Frame_" + QString("%1").arg((int)VSize.z()-i-1, 6, 10, QLatin1Char('0')); + ".pgm";
        // QString fname = "/home/ljp/Science/Projects/NeuroTools/Data/Scans/sub8/Frame_" + QString("%1").arg((int)VSize.z()-i-1, 6, 10, QLatin1Char('0')); + ".pgm";
        QString fname = "/home/ljp/Science/Projects/NeuroTools/Data/Scans/sub16/Frame_" + QString("%1").arg((int)VSize.z()-i-1, 6, 10, QLatin1Char('0')); + ".pgm";

        QImage Img(fname);
        Volume->setSubTextureData(Qt::YAxis, i, Img.bits());
    }

    // --- Color table

    int ncolors = 256;
    cmap.resize(ncolors);
    for (int i=0; i<ncolors; i++) { cmap[i] = qRgba(0,i,0,i*i*i/255/255/2); }
    //for (int i=0; i<ncolors; i++) { cmap[i] = qRgba(i,i,i,i*i/255/2); }

    Volume->setColorTable(cmap);

    // --- Slicing

    Volume->setDrawSliceFrames(false);

    // --- Rendering

    view->addCustomItem(Volume);

    */

    // === Layout ==========================================================

    /*
    QWidget *container = QWidget::createWindowContainer(view);
    gridLayout->addWidget(container,0,0);
*/

    qInfo() << "";

}

/* ---------------------------------------------------------------------- *\
 *  Destructor                                                            *
\* ---------------------------------------------------------------------- */

MainWindow::~MainWindow() { delete ui; }

/* ---------------------------------------------------------------------- *\
 *  Commands                                                              *
\* ---------------------------------------------------------------------- */

void MainWindow::newCommand(Command C) {

    if (C.Category=="display") { // -------------------------------- Display

        if (C.Key=="view") {
            view = C.Value;
            qInfo() << "View set to " << C.Value;
        }

        updateTopBar();

    } else if (C.Category=="data") { // ------------------------------  Data

        int id = C.Identifier-1;

        // if (C.Key=="new") { channel->newDataChannel(); }
        if (C.Key=="size") { channel->data[0][id]->size = C.Value.toInt(); }
        if (C.Key=="type") { channel->data[0][id]->type = QString(C.Value); }
        if (C.Key=="index") { channel->data[0][id]->index = C.Value.toInt() - 1; }
        if (C.Key=="z") { channel->data[0][id]->z = C.Value.toInt()-1; }
        if (C.Key=="t") { channel->data[0][id]->t = C.Value.toInt()-1; }
        if (C.Key=="check") { channel->data[0][id]->checkBuffer(); }

    } else if (C.Category=="set") { // ----------------------------- Dataset

        int index = C.Identifier-1;

        if (C.Key=="new") { Set.append(new dataset); }
        if (C.Key=="type") { Set[index]->type = C.Value; }
        if (C.Key=="name") { Set[index]->name = C.Value; }
        if (C.Key=="X") { Set[index]->X = C.Value.toInt(); }
        if (C.Key=="Y") { Set[index]->Y = C.Value.toInt(); }
        if (C.Key=="Z") { Set[index]->setZ(C.Value.toInt()); }
        if (C.Key=="T") {
            Set[index]->T = C.Value.toInt();
            timeSlider->setRange(0, C.Value.toInt()-1);
        }
        if (C.Key=="t") { Set[index]->t = C.Value.toInt()-1; }
        if (C.Key=="vertex") { }
        if (C.Key=="face") { }
        if (C.Key=="transform") { }
        if (C.Key=="cmap") { }
        if (C.Key=="x2um") { Set[index]->x2um = C.Value.toFloat(); }
        if (C.Key=="y2um") { Set[index]->y2um = C.Value.toFloat(); }
        if (C.Key=="z2um") { Set[index]->z2um = C.Value.toFloat(); }
        if (C.Key=="t2s") { Set[index]->t2s = C.Value.toFloat(); }
        if (C.Key=="visible") { Set[index]->visible = C.Value=="1"; }
        if (C.Key=="frozen") { Set[index]->frozen = C.Value=="1"; }

    }

}

/* ---------------------------------------------------------------------- *\
 *  Display                                                               *
\* ---------------------------------------------------------------------- */

/* --- Top bar --- */

void MainWindow::updateTopBar() {

    topLabel2->setText(view);

}

/* --- Side Bar --- */

void MainWindow::updateConsole() {

    while (Messages.length()) {

        Message MSG = Messages.takeFirst();
        QString S;

        switch (MSG.type) {
        case QtDebugMsg:
            cout << MSG.text.toStdString() << endl;
            break;
        case QtInfoMsg:
            S = "<" + MSG.css + ">" + MSG.text + "</p>" ;
            break;
        case QtWarningMsg:
            S = "<p class='warning'>" + MSG.text + "</p>";
            break;
        case QtCriticalMsg:
            S = "<p class='critical'>" + MSG.text + "</p>";
            break;
        case QtFatalMsg:
            S = "<p class='fatal'>" + MSG.text + "</p>";
            break;
        }

        logConsole->setHtml(logConsole->toHtml().append(S));
        logConsole->verticalScrollBar()->setValue(logConsole->verticalScrollBar()->maximum());
    }

}

/* --- Bottom Bar --- */

void MainWindow::updateBottomBar() {

}

void MainWindow::updateDisplay() {

    // --- Time

    int p = timeSlider->value();
    if (p!=prevSliderValue) {
        channel->send(QString("time:%1").arg(p+1));
        bottomLabel2->setText(QString("%1").arg(p+1));
        prevSliderValue = p;
    }

    // --- Data channels

    if (channel->data[0].size()) {
        QString s = "";
        foreach(dataChannel *C, channel->data[0]) { s += C->available ? "-" : "#"; }
        bottomLabel6->setText(s);
    } else { bottomLabel6->setText(QString("")); }

}

void MainWindow::refreshView() {

    QImage Img = QImage(Set[0]->layer[0]->bits(), Set[0]->X, Set[0]->Y, QImage::Format_Indexed8);
    Img.setColorTable(Set[0]->cmap);

    viewImage->setPixmap(QPixmap::fromImage(Img));


    // viewImage->setPixmap(QPixmap::fromImage(*Set[0]->layer[0]));

    // viewImage->setFixedWidth(1000);
    // viewImage->setFixedHeight(1382);

    // qInfo() << Set[0]->layer[0]->width() << " - " << Set[0]->layer[0]->height();

}
