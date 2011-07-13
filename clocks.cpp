/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "clocks.h"
#include "clocklistmodel.h"
#include "alarmsoundsmodel.h"

void clocks::registerTypes(const char *uri)
{
    qmlRegisterType<ClockListModel>(uri, 0, 0, "ClockListModel");
    qmlRegisterType<AlarmSoundsModel>(uri, 0, 0, "AlarmSoundsModel");
}

Q_EXPORT_PLUGIN(clocks);
