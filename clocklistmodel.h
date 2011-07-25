/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef CLOCKLISTMODEL_H
#define CLOCKLISTMODEL_H

#include <QAbstractListModel>
#include <QtCore/QtCore>
#include <QtCore/QObject>
#include <QSettings>
#include <ekcal/ekcal-storage.h>
#include "clockitem.h"
#include "meegolocale.h"

class ClockListModel: public QAbstractListModel, public eKCal::StorageObserver
{
    Q_OBJECT
    Q_ENUMS(ModelType)
    Q_PROPERTY(int type READ getType WRITE setType NOTIFY typeChanged);
    Q_PROPERTY(int count READ getCount NOTIFY countChanged);

public:
    ClockListModel(QObject *parent = 0);
    ~ClockListModel();

    enum ModelType {  ListofClocks = 0,
                      ListofAlarms = 1,
                      ListofTimers = 2
                   };

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(int index) const;

    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex());
    void insertRow(int row, ClockItem *item);
    void moveRow(int rowsrc, int rowdst);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    int getType() const
        { return m_type; }
    int getCount() const
        { return itemsList.count(); }
    virtual void setType(const int type);

public slots:
    void destroyItemByID(const QString &id);
    bool addClock(const QString &name, const QString &title, const int gmt);
    void addAlarm(const QString &name, const int days,
                  const int soundtype, const QString &soundname, const QString &soundfile,
                  const int snooze, const bool active,
                  const int hour, const int minute);
    void editClock(const QString &id, const QString &name, const QString &title, const int gmt);
    void editAlarm(const QString &id, const QString &name, const int days,
                   const int soundtype, const QString &soundname, const QString &soundfile,
                   const int snooze, const bool active,
                   const int hour, const int minute);
    void setOrder(const QString &id, const int order);

signals:
    void dataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight);
    void typeChanged(const int type);
    void countChanged(const int count);

private slots:
    void timezoneChanged();

protected:
    QSettings settings;
    void clearData();
    void storeClockData();
    bool getClock(const QString &id, ClockItem *&item, int &idx);
    QString cleanTZName(QString title) const;
    QString calendarAlarm(const QString &name, const int days,
              const int soundtype, const QString &soundname, const QString &soundfile,
              const int snooze, const bool active,
              const int hour, const int minute, QString uid = "");
    QList<ClockItem *> getAlarmsFromCalendar() const;
    void setClockItems(const QList<ClockItem *> &items);
    /* eKCal::StorageObserver */
    void loadingComplete(bool success, const QString &error);
    void savingComplete(bool success, const QString &error);

    /* the master list contains all the photos found through tracker */
    QList<ClockItem *> itemsList;
    QScopedPointer<class ClockModel> mClockModel;
    ClockItem *localzone;
    int m_type;
    /* Indicate if the calendar storage is done loading since the operation is
     * asynchronous */
    bool m_initialized;
    eKCal::EStorage::Ptr m_storage;
    KCalCore::Calendar::Ptr m_calendar;
    meego::Locale mLocale;
};

#endif // CLOCKLISTMODEL_H
