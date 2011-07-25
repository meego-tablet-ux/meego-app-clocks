/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include <QDir>
#include <QDebug>
#include <QtDBus/QtDBus>
#include <kcalcoren/ksystemtimezone.h>
#include <unicode/timezone.h>
#include <unicode/locid.h>
#include <clockmodel.h>
#include "clocklistmodel.h"

using namespace std;

ClockListModel::ClockListModel(QObject *parent)
    : QAbstractListModel(parent), settings("MeeGo", "meego-app-clocks"),
    m_type(-1), m_initialized(false)
{
    QHash<int, QByteArray> roles;
    roles.insert(ClockItem::ID, "itemid");
    roles.insert(ClockItem::ItemType, "itemtype");
    roles.insert(ClockItem::Title, "title");
    roles.insert(ClockItem::Name, "name");
    roles.insert(ClockItem::GMTOffset, "gmtoffset");
    roles.insert(ClockItem::Index, "index");
    roles.insert(ClockItem::Days, "days");
    roles.insert(ClockItem::SoundType, "soundtype");
    roles.insert(ClockItem::SoundName, "soundname");
    roles.insert(ClockItem::SoundFile, "soundfile");
    roles.insert(ClockItem::Snooze, "snooze");
    roles.insert(ClockItem::Active, "active");
    roles.insert(ClockItem::Hour, "hour");
    roles.insert(ClockItem::Minute, "minute");
    roles.insert(ClockItem::GMTName, "gmtname");
    setRoleNames(roles);

    m_storage = eKCal::EStorage::localStorage(KCalCore::IncidenceBase::TypeEvent,
                                            "alarmsnotebook",
                                            true);
    m_calendar = m_storage->calendar();

    m_storage->registerObserver(this);
    m_storage->startLoading(); // Asynchronous
}

ClockListModel::~ClockListModel()
{
    clearData();
}

void ClockListModel::clearData()
{
    if(!itemsList.isEmpty())
    {
        beginRemoveRows(QModelIndex(), 0, itemsList.count()-1);
        for(int i = 0; i < itemsList.count(); i++)
            delete itemsList[i];
        localzone = NULL;
        itemsList.clear();
        endRemoveRows();
    }
}

QString ClockListModel::cleanTZName(QString title) const
{
    QStringList temp = title.split("/", QString::SkipEmptyParts);
    if (temp.isEmpty())
        return title;
    QString res = temp.last();
    res.replace("_", " ");
    return res;
}

void ClockListModel::setType(const int type)
{
    if(type == m_type)
        return;

    clearData();
    m_type = type;
    emit typeChanged(m_type);

    QList<ClockItem *> newItemsList;

    if(m_type == ListofClocks)
    {
        QString localzonename = "GMT";
        int gmt = 0;
        QString name = localzonename;
        QString title = localzonename;
        mClockModel.reset(new ClockModel());
        connect(mClockModel.data(), SIGNAL(timezoneChanged()),
                this, SLOT(timezoneChanged()));
        if (!mClockModel->timezone().isEmpty()) {
            title = mClockModel->timezone();
            KTimeZone zone = KSystemTimeZones::zone(title);
            name = cleanTZName(title);
            gmt = zone.currentOffset(Qt::UTC);
        }
        localzone = new ClockItem(name, title, gmt);
        newItemsList << localzone;


        if(!settings.contains("firstuse"))
        {
            QStringList defaultzones;
            defaultzones << "Europe/London"
                         << "America/Los_Angeles"
                         << "Asia/Shanghai";
            settings.setValue("firstuse", "false");
            settings.beginGroup("clocks");
            for (int i = 0; i < defaultzones.size(); i++) {
                KTimeZone zone = KSystemTimeZones::zone(defaultzones[i]);
                settings.setValue(QString("00%1/name").arg(i+1), cleanTZName(zone.name()));
                settings.setValue(QString("00%1/title").arg(i+1), zone.name());
                settings.setValue(QString("00%1/gmt").arg(i+1), zone.currentOffset(Qt::UTC));
            }
            settings.endGroup();
        }

        settings.beginGroup("clocks");
        QStringList ids = settings.childGroups();
        for(int i = 0; i < ids.count(); i++)
        {
            QString name = settings.value(ids[i] + "/name", "undefined").toString();
            QString title = settings.value(ids[i] + "/title", "undefined").toString();
            int gmt = settings.value(ids[i] + "/gmt", 100).toInt();
            newItemsList << new ClockItem(name, title, gmt);
        }
        settings.endGroup();
        // force reload when locale changes to get new timezone names
        connect(&mLocale, SIGNAL(localeChanged()), this, SIGNAL(modelReset()));
    }
    else if(m_type == ListofAlarms)
    {
        newItemsList = getAlarmsFromCalendar();
    }
    else if(m_type == ListofTimers)
    {
    }
    else
    {
        qDebug() << "Invalid Type";
        return;
    }

   // Set the new clock items
   setClockItems(newItemsList);
}

/*!
 * Set the new clock items in the model to \a items.
 * The caller should make sure clearData() is called before setting the new items.
 */
void ClockListModel::setClockItems(const QList<ClockItem *> &newItemsList)
{
    Q_ASSERT(itemsList.isEmpty());
    if(!newItemsList.isEmpty())
    {
        beginInsertRows(QModelIndex(), 0, newItemsList.count()-1);
        itemsList = newItemsList;
        endInsertRows();
    }
    emit countChanged(itemsList.count());
}

/*!
 * Loads the alarms from the calendar and return them.
 *
 * \return The list of alarms in the calendar as ClockItems, an empty list if the
 * calendar is not ready yet.
 */
QList<ClockItem *> ClockListModel::getAlarmsFromCalendar() const
{
    Q_ASSERT (m_type == ListofAlarms);
    QList<ClockItem *> newItemsList;

    if (!m_initialized) {
        // The storage is not done loading, the alarms will be retrieved once it is
        return newItemsList;
    }

    // The calendar is initialized, retrieve the alarms from it
    KCalCore::Event::List eventList;
    eventList = m_calendar->rawEvents(KCalCore::EventSortStartDate, KCalCore::SortDirectionAscending);

    for (int i = 0; i < eventList.count(); i++)
    {
        KCalCore::Event *event = eventList.at(i).data();
        QStringList desc = event->description().split("!");
        QString name = event->summary();
        int soundtype = (desc.isEmpty())?0:desc.at(0).toInt();
        QString soundname = (desc.count() < 2)?"":desc.at(1);
        QString uid = event->uid();
        KCalCore::Recurrence* theRecurrence = event->recurrence();
        QBitArray qb = theRecurrence->days();
        int days = 0;
        for(int i = 0; i < 7; i++)
            if(qb.at(i))
                days |= (1<<i);
        KCalCore::Alarm::List alarms = event->alarms();
        if (alarms.count() < 1)
            continue;
        KCalCore::Alarm::Ptr alarm = alarms.at(0);
        QString soundfile = alarm->audioFile();
        int snooze = alarm->snoozeTime().asSeconds()/60;
        bool active = alarm->enabled();
        QTime thetime = alarm->time().toLocalZone().time();
        int hour = thetime.hour();
        int minute = thetime.minute();

        newItemsList << new ClockItem(name, days, soundtype, soundname, soundfile, snooze, active, hour, minute, uid);
    }

    return newItemsList;
}

void ClockListModel::timezoneChanged()
{
    Q_ASSERT(itemsList.size() > 0);
    ClockItem *item = itemsList[0];
    item->m_title = mClockModel->timezone();
    item->m_name = cleanTZName(item->m_title);
    KTimeZone zone = KSystemTimeZones::zone(item->m_title);
    item->m_gmtoffset = zone.currentOffset(Qt::UTC);
    emit dataChanged(index(0, 0), index(0, 0));
}

bool ClockListModel::getClock(const QString &id, ClockItem *&item, int &idx)
{
    for(idx = 0; idx < itemsList.count(); idx++)
        if(itemsList[idx]->m_id == id)
        {
            item = itemsList[idx];
            break;
        }

    if(idx >= itemsList.count())
        return false;

    return true;
}

bool ClockListModel::addClock(const QString &name, const QString &title, const int gmt)
{
    if(m_type != ListofClocks)
    {
        qDebug() << "Can only add clocks to ListofClocks type";
        return true;
    }

    // search for duplicate clock
    ClockItem *clock;
    foreach (clock, itemsList) {
        if (clock->m_title == title) {
            return false;
        }
    }

    beginInsertRows(QModelIndex(), itemsList.count(), itemsList.count());
    itemsList << new ClockItem(name, title, gmt);
    endInsertRows();

    QString group;
    group.sprintf("clocks/%03d", itemsList.count()-1);
    settings.beginGroup(group);
    settings.setValue("name", name);
    settings.setValue("title", title);
    settings.setValue("gmt", gmt);
    settings.endGroup();
    emit countChanged(itemsList.count());
    return true;
}

QString ClockListModel::calendarAlarm(const QString &name, const int days,
      const int soundtype, const QString &soundname, const QString &soundfile,
      const int snooze, const bool active,
      const int hour, const int minute, QString uid)
{
    Q_ASSERT(m_initialized);

    KCalCore::Event::Ptr coreEvent;

    if(uid.isEmpty())
    {
        /* this is an ADD call, create a new item */
        coreEvent = KCalCore::Event::Ptr(new KCalCore::Event());
    }
    else
    {
        /* this is an EDIT call, load the alarm item */
        coreEvent = m_calendar->event(uid);
        /* if the database lacks this item, create a new one */
        if(coreEvent == NULL)
        {
            qDebug() << "can't edit this: " << name;
            coreEvent = KCalCore::Event::Ptr(new KCalCore::Event());
        }
    }

    /* if somehow we still have nothing, kick over the table and storm off */
    if(coreEvent == NULL)
    {
        qDebug() << "alarm not found in calendar db: " << name;
        return uid;
    }

    coreEvent->setSummary(name);
    QString desc = QString("%1!%2").arg(soundtype).arg(soundname);
    coreEvent->setDescription(desc);

    //coreEvent->setAllDay(true);
    coreEvent->clearAlarms();
    KCalCore::Alarm::Ptr eventAlarm(coreEvent->newAlarm());
    eventAlarm->setAudioAlarm( soundfile );
    eventAlarm->setSnoozeTime( KCalCore::Duration( 60*snooze ) );
    eventAlarm->setRepeatCount(10);
    KDateTime thetime = KDateTime::currentDateTime(KDateTime::Spec(KSystemTimeZones::local()));
    thetime.setTime(QTime(hour, minute, 0, 0));
    eventAlarm->setTime(thetime);
    eventAlarm->setEnabled(active);
    coreEvent->addAlarm( eventAlarm );

    QBitArray qb(10);
    for(int i = 0; i < 7; i++)
    {
        qb.setBit(i,(days>>i)&0x1);
    }
    KCalCore::Recurrence* newRecurrence = coreEvent->recurrence();
    newRecurrence->setWeekly(1, qb, 1);

    m_calendar->addEvent(coreEvent);
    m_storage->save();
    return coreEvent->uid();
}

void ClockListModel::addAlarm(const QString &name, const int days, const int soundtype,
                              const QString &soundname, const QString &soundfile,
                              const int snooze, const bool active,
                              const int hour, const int minute)
{
    if(m_type != ListofAlarms)
    {
        qDebug() << "Can only add clocks to ListofAlarms type";
        return;
    }

    QString uid = calendarAlarm(name, days, soundtype, soundname, soundfile,
                                 snooze, active, hour, minute);

    beginInsertRows(QModelIndex(), itemsList.count(), itemsList.count());
    itemsList << new ClockItem(name, days, soundtype, soundname, soundfile,
                               snooze, active, hour, minute, uid);
    endInsertRows();

//    QString group;
//    group.sprintf("alarms/%03d", itemsList.count()-1);
//    settings.beginGroup(group);
//    settings.setValue("name", name);
//    settings.setValue("days", days);
//    settings.setValue("soundtype", soundtype);
//    settings.setValue("soundname", soundname);
//    settings.setValue("soundfile", soundfile);
//    settings.setValue("snooze", snooze);
//    settings.setValue("active", active);
//    settings.setValue("hour", hour);
//    settings.setValue("minute", minute);
//    settings.setValue("uid", uid);
//    settings.endGroup();
    emit countChanged(itemsList.count());
}

void ClockListModel::editClock(const QString &id, const QString &name, const QString &title, const int gmt)
{
    int idx = 0;
    ClockItem *item = NULL;
    if(!getClock(id, item, idx))
        return;

    if(idx == 0)
        return;

    QString group;
    group.sprintf("clocks/%03d", idx);
    settings.beginGroup(group);
    settings.setValue("name", name);
    settings.setValue("title", title);
    settings.setValue("gmt", gmt);
    settings.endGroup();
    item->m_name = name;
    item->m_title = title;
    item->m_gmtoffset = gmt;
    emit dataChanged(index(idx, 0), index(idx, 0));
}

void ClockListModel::editAlarm(const QString &id, const QString &name, const int days,
                       const int soundtype, const QString &soundname, const QString &soundfile,
                       const int snooze, const bool active,
                       const int hour, const int minute)
{
    int idx = 0;
    ClockItem *item = NULL;
    if(!getClock(id, item, idx))
        return;

    QString uid = calendarAlarm(name, days, soundtype, soundname, soundfile,
                  snooze, active, hour, minute, item->m_uid);

//    QString group;
//    group.sprintf("alarms/%03d", idx);
//    settings.beginGroup(group);
//    settings.setValue("name", name);
//    settings.setValue("days", days);
//    settings.setValue("soundtype", soundtype);
//    settings.setValue("soundname", soundname);
//    settings.setValue("soundfile", soundfile);
//    settings.setValue("snooze", snooze);
//    settings.setValue("active", active);
//    settings.setValue("hour", hour);
//    settings.setValue("minute", minute);
//    settings.setValue("uid", uid);
//    settings.endGroup();
    item->m_name = name;
    item->m_days = days;
    item->m_soundtype = soundtype;
    item->m_soundname = soundname;
    item->m_soundfile = soundfile;
    item->m_snooze = snooze;
    item->m_active = active;
    item->m_hour = hour;
    item->m_minute = minute;
    item->m_uid = uid;
    emit dataChanged(index(idx, 0), index(idx, 0));
}

void ClockListModel::setOrder(const QString &id, const int order)
{
    if((m_type == ListofClocks)&&(order < 1))
        return;

    int idx = 0;
    ClockItem *item = NULL;
    if(!getClock(id, item, idx))
        return;

    if((m_type == ListofClocks)&&(idx == 0))
        return;

    int idxtgt = order;
    if(idx == idxtgt)
        return;

    itemsList.swap(idx, idxtgt);
    storeClockData();
    emit dataChanged(index(idx, 0), index(idx, 0));
    emit dataChanged(index(idxtgt, 0), index(idxtgt, 0));
}

void ClockListModel::storeClockData()
{
    if(m_type == ListofClocks)
    {
        settings.remove("clocks");
        for(int i = 1; i < itemsList.count(); i++)
        {
            QString group;
            group.sprintf("clocks/%03d", i);
            settings.beginGroup(group);
            settings.setValue("name", itemsList[i]->m_name);
            settings.setValue("title", itemsList[i]->m_title);
            settings.setValue("gmt", itemsList[i]->m_gmtoffset);
            settings.endGroup();
        }
    }
    else if(m_type == ListofAlarms)
    {
        settings.remove("alarms");
        for(int i = 0; i < itemsList.count(); i++)
        {
            QString group;
            group.sprintf("alarms/%03d", i);
            settings.beginGroup(group);
            settings.setValue("name", itemsList[i]->m_name);
            settings.setValue("days", itemsList[i]->m_days);
            settings.setValue("soundtype", itemsList[i]->m_soundtype);
            settings.setValue("soundname", itemsList[i]->m_soundname);
            settings.setValue("soundfile", itemsList[i]->m_soundfile);
            settings.setValue("snooze", itemsList[i]->m_snooze);
            settings.setValue("active", itemsList[i]->m_active);
            settings.setValue("hour", itemsList[i]->m_hour);
            settings.setValue("minute", itemsList[i]->m_minute);
            settings.setValue("uid", itemsList[i]->m_uid);
            settings.endGroup();
        }
    }
}

void ClockListModel::destroyItemByID(const QString &id)
{
    int idx = 0;
    ClockItem *item = NULL;
    if(!getClock(id, item, idx))
        return;

    if(item->m_type == ClockItem::AlarmItem)
    {
        KCalCore::Event::Ptr ptr = m_calendar->event(item->m_uid);
        if(ptr == NULL)
            qDebug() << "alarm not found in calendar db: " << item->m_name;
        else
        {
            m_calendar->deleteEvent( ptr );
            m_storage->save();
        }
    }
    beginRemoveRows(QModelIndex(), idx, idx);
    itemsList.removeAt(idx);
    delete item;
    endRemoveRows();
    storeClockData();
    emit countChanged(itemsList.count());
}

QVariant ClockListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() > itemsList.count())
        return QVariant();

    ClockItem *item = itemsList[index.row()];

    if (role == ClockItem::ID)
        return item->m_id;

    if (role == ClockItem::ItemType)
        return item->m_type;

    if (role == ClockItem::Title)
        return item->m_title;

    if (role == ClockItem::Name) {
        if (m_type == ListofClocks) {
            TimeZone *zone = TimeZone::createTimeZone(UnicodeString(static_cast<const UChar*>(item->m_title.utf16())));
            UnicodeString result;
            zone->getDisplayName(TRUE, TimeZone::GENERIC_LOCATION, Locale(mLocale.locale().toAscii().constData()), result);
            delete zone;
            return QString(reinterpret_cast<const QChar*>(result.getBuffer()), result.length());
        } else {
            return item->m_name;
        }
    }

    if (role == ClockItem::GMTName) {
        TimeZone *zone = TimeZone::createTimeZone(UnicodeString(static_cast<const UChar*>(item->m_title.utf16())));
        UnicodeString result;
        zone->getDisplayName(TRUE, TimeZone::LONG_GMT, Locale(mLocale.locale().toAscii().constData()), result);
        delete zone;
        return QString(reinterpret_cast<const QChar*>(result.getBuffer()), result.length());
    }

    if (role == ClockItem::GMTOffset)
        return item->m_gmtoffset;

    if (role == ClockItem::Index)
        return index.row();

    if (role == ClockItem::Days)
        return item->m_days;

    if (role == ClockItem::SoundType)
        return item->m_soundtype;

    if (role == ClockItem::SoundName)
        return item->m_soundname;

    if (role == ClockItem::SoundFile)
        return item->m_soundfile;

    if (role == ClockItem::Snooze)
        return item->m_snooze;

    if (role == ClockItem::Active)
        return item->m_active;

    if (role == ClockItem::Hour)
        return item->m_hour;

    if (role == ClockItem::Minute)
        return item->m_minute;

    return QVariant();
}

QVariant ClockListModel::data(int index) const
{
    if(index >= itemsList.size())
        index = itemsList.size() - 1;

    return QVariant::fromValue(static_cast<void *>(itemsList[index]));
}

int ClockListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);

    return itemsList.size();
}

int ClockListModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);

    return 1;
}

bool ClockListModel::removeRows(int row, int count, const QModelIndex &parent)
{
    beginRemoveRows(parent, row, row + count - 1);
    for(int i = row; i < row + count; i++)
        itemsList.removeAt(i);
    endRemoveRows();
    return true;
}

void ClockListModel::insertRow(int row, ClockItem *item)
{
    beginInsertRows(QModelIndex(), row, row);
    itemsList.insert(row, item);
    endInsertRows();
}

void ClockListModel::moveRow(int rowsrc, int rowdst)
{
    beginMoveRows(QModelIndex(), rowsrc, rowsrc, QModelIndex(), rowdst);
    itemsList.move(rowsrc, rowdst);
    endMoveRows();
}

/*! \reimp */
void ClockListModel::loadingComplete(bool success, const QString &error)
{
    qDebug() << Q_FUNC_INFO << success << error;
    m_initialized = success;
    if(m_initialized && m_type == ListofAlarms) {
        // The calendar is done loading and the model is supposed to contain the alarms
        // so we retrieve them from the calendar and populate the model.
        setClockItems(getAlarmsFromCalendar());
    }
}

/*! \reimp */
void ClockListModel::savingComplete(bool success, const QString &error)
{
    qDebug() << Q_FUNC_INFO << success << error;
}
