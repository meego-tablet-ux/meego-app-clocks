/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

import "functions.js" as Code

Text {
    id: root

    property int tz: 0
    property int hours: 0
    property int minutes: 0
    property int seconds: 0
    property int day: 0

    Component.onCompleted: {
        timeChanged();
        clocksPage.minutesTick.connect(timeChanged);
    }

    function timeChanged() {
        var date = new Date;
        hours = tz ? ((date.getUTCHours() + tz + 24)%24) : date.getUTCHours();
        minutes = date.getMinutes();
        seconds = date.getUTCSeconds();
        day = (date.getUTCDay() + dayOffset() + 7) % 7;
        //: %1 is formatted time, %2 is weekday
        text = qsTr("%1 %2", "TimeWeekday").arg(Code.formatTime(hours,minutes)).arg(Code.weekday[(day - 1 + 7) % 7]);
    }

    // calculate the weekday offset from UTC since we have no
    // timezone support in Qt to get the actual date
    // (see http://bugreports.qt.nokia.com/browse/QTBUG-10219)
    function dayOffset() {
        var date = new Date;
        // calculations below are in "normalized" utc offsets:
        // +0 to +23 hrs, with 0 set at international date line
        var nMidnight = (12 - date.getUTCHours() + 24) % 24;
        var nTz = (tz + 12 + 24) % 24;
        var nUtc = 12;
        if (nTz >= nMidnight && nUtc < nMidnight) {
            return 1;
        } else if (nUtc >= nMidnight && nTz < nMidnight) {
            return -1;
        } else {
            return 0;
        }
    }
}
