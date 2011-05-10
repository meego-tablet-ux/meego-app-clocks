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

    Component.onCompleted: timeChanged()

    function timeChanged() {
        var date = new Date;
        hours = tz ? ((date.getUTCHours() + tz + 24)%24) : date.getUTCHours();
        minutes = date.getMinutes();
        seconds = date.getUTCSeconds();
        day = (date.getDay() + dayOffset() + 7) % 7;
        text = qsTr("%1 %2").arg(Code.formatTime(hours,minutes)).arg(Code.weekday[day]);
    }

    function dayOffset() {
        var date = new Date;
        var nmidnight = (12 - date.getUTCHours() + 24) % 24;
        var ntz = (tz + 12 + 24) % 24;
        var nlocal = (date.getHours() - date.getUTCHours() + 12 + 24) % 24;
        if (ntz >= nmidnight && nlocal < nmidnight) {
            return 1;
        } else if (nlocal >= nmidnight && ntz < nmidnight) {
            return -1;
        } else {
            return 0;
        }
    }

    Timer {
        interval: 6000
        running: true
        repeat: true
        onTriggered: root.timeChanged()
    }
}
