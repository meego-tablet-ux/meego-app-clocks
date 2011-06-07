TRANSLATIONS += *.qml
VERSION = 0.3.6
PROJECT_NAME = meego-app-clocks

TEMPLATE = lib
TARGET = Clocks
QT += declarative \
    dbus
CONFIG += qt \
    plugin \
    dbus \
    link_pkgconfig
PKGCONFIG += gconf-2.0 \
    libkcalcoren \
    libmkcal \
    connman-qt4
TARGET = $$qtLibraryTarget($$TARGET)
DESTDIR = $$TARGET
OBJECTS_DIR = .obj
MOC_DIR = .moc

# Input
SOURCES += clocks.cpp \
    clockitem.cpp \
    clocklistmodel.cpp
OTHER_FILES += \
    qmldir
HEADERS += clocks.h \
    clockitem.h \
    clocklistmodel.h

qmlfiles.files += *.qml *.js i18n
qmlfiles.path += $$INSTALL_ROOT/usr/share/$$PROJECT_NAME
qmldir.files += $$TARGET
qmldir.path += $$[QT_INSTALL_IMPORTS]/MeeGo/App
INSTALLS += qmldir qmlfiles

dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION} &&
dist.commands += git clone . $${PROJECT_NAME}-$${VERSION} &&
dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION}/.git &&
dist.commands += mkdir -p $${PROJECT_NAME}-$${VERSION}/ts &&
dist.commands += lupdate $${TRANSLATIONS} -ts $${PROJECT_NAME}-$${VERSION}/ts/$${PROJECT_NAME}.ts &&
dist.commands += tar jcpvf $${PROJECT_NAME}-$${VERSION}.tar.bz2 $${PROJECT_NAME}-$${VERSION}
QMAKE_EXTRA_TARGETS += dist
