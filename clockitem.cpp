/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "clockitem.h"
#include <inttypes.h>

ClockItem::ClockItem(QString name, QString title, int gmt, QObject *parent) :
    QObject(parent), m_name(name), m_title(title), m_gmtoffset(gmt)
{
    m_type = DefaultItem;
    m_id = QString().sprintf("0x%08lX", (uintptr_t)this);
}

ClockItem::ClockItem(QString name, int days, int soundtype,
                   QString soundname, QString soundfile,
                   int snooze, bool active,
                   int hour, int minute, QString uid,
                   QObject *parent) :
    QObject(parent), m_name(name), m_days(days), m_soundtype(soundtype), m_soundname(soundname), m_soundfile(soundfile),
    m_snooze(snooze), m_active(active), m_hour(hour), m_minute(minute), m_uid(uid)
{
    m_type = AlarmItem;
    m_id = QString().sprintf("0x%08lX", (uintptr_t)this);
}
