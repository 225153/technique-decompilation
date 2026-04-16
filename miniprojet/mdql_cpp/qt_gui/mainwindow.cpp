#include "mainwindow.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QSplitter>
#include <QLabel>
#include <QFile>
#include <QTextStream>
#include <QRegularExpression>
#include <QDir>
#include <QFont>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    setWindowTitle("Mini Data Query Language (MDQL) - IDE");
    resize(1000, 700);

    // Style sombre (Dark Mode professionnel)
    setStyleSheet(
        "QMainWindow { background-color: #2b2b2b; }"
        "QTextEdit { background-color: #1e1e1e; color: #a9b7c6; border: 1px solid #3c3f41; padding: 5px; }"
        "QLabel { color: #bbbbbb; font-weight: bold; font-size: 12px; }"
        "QPushButton { background-color: #365880; color: white; border: none; padding: 10px; font-weight: bold; border-radius: 4px; }"
        "QPushButton:hover { background-color: #4a7ab0; }"
        "QPushButton:pressed { background-color: #2a4b70; }"
        "QSplitter::handle { background: #3c3f41; }"
    );

    QFont codeFont("Monospace");
    codeFont.setStyleHint(QFont::TypeWriter);
    codeFont.setPointSize(11);

    // --- Widgets ---
    codeEditor = new QTextEdit(this);
    codeEditor->setFont(codeFont);
    codeEditor->setPlaceholderText("Entrez votre code MDQL ici...");

    csvEditor = new QTextEdit(this);
    csvEditor->setFont(codeFont);
    csvEditor->setPlaceholderText("Entrez les donn\xC3\xA9es CSV ici...");

    consoleOutput = new QTextEdit(this);
    consoleOutput->setFont(codeFont);
    consoleOutput->setReadOnly(true);
    // Style specifique pour la console pour differencier
    consoleOutput->setStyleSheet("QTextEdit { background-color: #000000; color: #00ff00; border: 1px solid #3c3f41; }");

    btnRun = new QPushButton("Ex\xC3\xA9\x63uter le Code (MDQL)", this);

    // --- Layout Global (Splitters) ---
    QWidget *centralWidget = new QWidget(this);
    QVBoxLayout *mainLayout = new QVBoxLayout(centralWidget);

    QSplitter *mainSplitter = new QSplitter(Qt::Horizontal);
    
    // Panneau Gauche : Code
    QWidget *leftPanel = new QWidget();
    QVBoxLayout *leftLayout = new QVBoxLayout(leftPanel);
    leftLayout->setContentsMargins(0, 0, 0, 0);
    leftLayout->addWidget(new QLabel("📜 Editeur MDQL (programme.mds)"));
    leftLayout->addWidget(codeEditor);
    leftLayout->addWidget(btnRun);

    // Panneau Droit (Splitter Vertical : Haut = CSV, Bas = Console)
    QSplitter *rightSplitter = new QSplitter(Qt::Vertical);
    
    QWidget *topRightPanel = new QWidget();
    QVBoxLayout *trLayout = new QVBoxLayout(topRightPanel);
    trLayout->setContentsMargins(0, 0, 0, 0);
    trLayout->addWidget(new QLabel("📊 Donnees (employees.csv)"));
    trLayout->addWidget(csvEditor);

    QWidget *bottomRightPanel = new QWidget();
    QVBoxLayout *brLayout = new QVBoxLayout(bottomRightPanel);
    brLayout->setContentsMargins(0, 0, 0, 0);
    brLayout->addWidget(new QLabel("📺 Console de Sortie"));
    brLayout->addWidget(consoleOutput);

    rightSplitter->addWidget(topRightPanel);
    rightSplitter->addWidget(bottomRightPanel);
    // On donne plus de place en hauteur a la console
    rightSplitter->setStretchFactor(0, 1);
    rightSplitter->setStretchFactor(1, 2);

    mainSplitter->addWidget(leftPanel);
    mainSplitter->addWidget(rightSplitter);
    // Repartition de largeur equilibree
    mainSplitter->setStretchFactor(0, 1);
    mainSplitter->setStretchFactor(1, 1);

    mainLayout->addWidget(mainSplitter);
    setCentralWidget(centralWidget);

    // --- Process et Signaux ---
    process = new QProcess(this);
    // Toujours s'assurer d'etre dans le bon chemin
    process->setWorkingDirectory(QDir::currentPath() + "/..");

    connect(btnRun, &QPushButton::clicked, this, &MainWindow::runCode);
    connect(process, &QProcess::readyReadStandardOutput, this, &MainWindow::readOutput);
    connect(process, &QProcess::readyReadStandardError, this, &MainWindow::readError);
    connect(process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &MainWindow::processFinished);

    // Chargement par d\xC3\xA9\x66\x61ut si dispo
    QFile fCode("../programme.mds");
    if (fCode.open(QFile::ReadOnly | QFile::Text)) {
        codeEditor->setPlainText(fCode.readAll());
    }
    
    QFile fCsv("../employees.csv");
    if (fCsv.open(QFile::ReadOnly | QFile::Text)) {
        csvEditor->setPlainText(fCsv.readAll());
    }
}

MainWindow::~MainWindow()
{
    if (process->state() == QProcess::Running) {
        process->terminate();
        process->waitForFinished(1000);
    }
}

QString MainWindow::stripAnsi(const QString &text)
{
    QString clean = text;
    // Regex pour supprimer les codes de couleurs ANSI generees par notre parseur
    clean.replace(QRegularExpression("\\x1B\\[[0-9;]*[a-zA-Z]"), "");
    return clean;
}

void MainWindow::runCode()
{
    btnRun->setEnabled(false);
    btnRun->setText("Execution en cours...");
    consoleOutput->clear();

    // 1. Sauvegarder l'editeur dans programme.mds
    QFile fCode("../programme.mds");
    if (fCode.open(QFile::WriteOnly | QFile::Text)) {
        QTextStream out(&fCode);
        out << codeEditor->toPlainText();
        fCode.close();
    } else {
        consoleOutput->append("[ERREUR] Impossible de sauvegarder programme.mds\n");
    }

    // 2. Sauvegarder le CSV
    QFile fCsv("../employees.csv");
    if (fCsv.open(QFile::WriteOnly | QFile::Text)) {
        QTextStream out(&fCsv);
        out << csvEditor->toPlainText();
        fCsv.close();
    } else {
        consoleOutput->append("[ERREUR] Impossible de sauvegarder employees.csv\n");
    }

    // 3. Executer notre compilateur
    QString comp_path = QDir::currentPath() + "/../mdql";
    consoleOutput->append("> runApp: " + comp_path + " programme.mds");
    process->start(comp_path, QStringList() << "programme.mds");
}

void MainWindow::readOutput()
{
    QString out = process->readAllStandardOutput();
    consoleOutput->append(stripAnsi(out).trimmed());
}

void MainWindow::readError()
{
    QString err = process->readAllStandardError();
    consoleOutput->append("<font color='red'>" + stripAnsi(err).trimmed() + "</font>");
}

void MainWindow::processFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    btnRun->setEnabled(true);
    btnRun->setText("Ex\xC3\xA9\x63uter le Code (MDQL)");
    
    if (exitStatus == QProcess::CrashExit) {
        consoleOutput->append("<br><i><font color='red'>Process a crashe !</font></i>");
    } else {
        consoleOutput->append(QString("<br><i>Programme termine avec le code %1</i>").arg(exitCode));
    }
}