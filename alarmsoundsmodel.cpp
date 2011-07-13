/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include <QFileInfo>
#include "alarmsoundsmodel.h"

AlarmSoundsModel::AlarmSoundsModel()
    : mAlarmSoundsConf(new MGConfItem("/apps/meego-app-clocks/alarmsoundfiles"))
{
    connect(mAlarmSoundsConf, SIGNAL(valueChanged()), this, SIGNAL(soundsChanged()));
}

QStringList AlarmSoundsModel::soundNames() const
{
    QStringList names;
    QStringList files = soundFiles();
    foreach (QString filename, files) {
        names.append(QFileInfo(filename).baseName());
    }
    return names;
}

QStringList AlarmSoundsModel::soundFiles() const
{
    QStringList defaults;
    defaults << "/usr/share/sounds/meego/stereo/ring-1.wav"
             << "/usr/share/sounds/meego/stereo/ring-2.wav"
             << "/usr/share/sounds/meego/stereo/ring-3.wav"
             << "/usr/share/sounds/meego/stereo/ring-4.wav";
    if (mAlarmSoundsConf->value().type() != QVariant::StringList ||
            mAlarmSoundsConf->value().toStringList().size() < 1) {
        return defaults;
    }
    return mAlarmSoundsConf->value().toStringList();
}

int AlarmSoundsModel::getIndexByFile(QString file) const
{
    QStringList files = soundFiles();
    for (int i = 0; i < files.size(); i++) {
        if (file == files.value(i))
            return i;
    }

    return 0;
}

