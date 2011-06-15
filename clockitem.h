/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef CLOCKITEM_H
#define CLOCKITEM_H

#include <QtCore/QtCore>
#include <QtCore/QObject>

class ClockItem: public QObject {
    Q_OBJECT

public:
    /* new clock */
    ClockItem(QString name, QString title, int gmt, QObject *parent = 0);
    /* new alarm */
    ClockItem(QString name, int days, int soundtype,
                       QString soundname, QString soundfile,
                       int snooze, bool active,
                       int hour, int minute, QString uid,
                       QObject *parent = 0);

    enum Role {
        ID = Qt::UserRole + 1,
        ItemType = Qt::UserRole + 2,
        Index = Qt::UserRole + 3,
        Title = Qt::UserRole + 4,
        Name = Qt::UserRole + 5,
        GMTOffset = Qt::UserRole + 6,
        Days = Qt::UserRole + 7,
        SoundType = Qt::UserRole + 8,
        SoundName = Qt::UserRole + 9,
        SoundFile = Qt::UserRole + 10,
        Snooze = Qt::UserRole + 11,
        Active = Qt::UserRole + 12,
        Hour = Qt::UserRole + 13,
        Minute = Qt::UserRole + 14,
        GMTName = Qt::UserRole + 15
    };

    enum ItemType {
        DefaultItem = 0,
        AlarmItem = 1,
        TimerItem = 2
    };

    bool isClock()
        { return (m_type == DefaultItem); }
    bool isAlarm()
        { return (m_type == AlarmItem); }
    bool isTimer()
        { return (m_type == TimerItem); }

    QString m_id;
    QString m_name;
    QString m_title;
    int m_gmtoffset;
    int m_type;
    int m_days;
    int m_soundtype;
    QString m_soundname;
    QString m_soundfile;
    int m_snooze;
    bool m_active;
    int m_hour;
    int m_minute;
    QString m_uid;
};

#endif // CLOCKITEM_H
