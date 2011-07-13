/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef ALARMSOUNDSMODEL_H
#define ALARMSOUNDSMODEL_H

#include <QtCore/QObject>
#include <mgconfitem.h>

class AlarmSoundsModel: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList soundNames READ soundNames NOTIFY soundsChanged);
    Q_PROPERTY(QStringList soundFiles READ soundFiles NOTIFY soundsChanged);

public:
    AlarmSoundsModel();

    QStringList soundNames() const;
    QStringList soundFiles() const;

    Q_INVOKABLE int getIndexByFile(QString) const;

signals:
    void soundsChanged();

private:
    MGConfItem *mAlarmSoundsConf;
};

#endif // ALARMSOUNDSMODEL_H

