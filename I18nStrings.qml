/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

// dummy file for string localization

Item {
    // clocks
    property string string01: qsTr("You cannot add more than %1 clocks", "clock creation error")

    // alarms
    property string string02: qsTr("You have no alarms", "alarms page, no content")
    property string string03: qsTr("Create a new alarm", "alarms page, no content")
    property string string04: qsTr("You cannot add more than %1 alarms", "alarm creation error")
    property string string05: qsTr("You must provide a name", "alarm creation error")
    property string string06: qsTr("You must select at least one day", "alarm creation error")

    // timers
    property string string07: qsTr("Timers", "page title")
    property string string08: qsTr("You have no timers", "timers page, no content")
    property string string09: qsTr("Create a new timer", "timers page, no cotnent")
    property string string10: qsTr("New timer", "menu item")
    property string string11: qsTr("Add new timer", "timer creation dialogbox title")
    property string string12: qsTr("You cannot add more than %1 timers", "timer creation error")
    property string string13: qsTr("You must provide a name", "timer creation error")
    property string string14: qsTr("Delete timer", "timer deletion dialogbox title")
    property string string15: qsTr("Are you sure you want to delete?", "timer deletion dialogbox text")
    property string string16: qsTr("Duration", "timer settings")
    property string string17: qsTr("Hours", "timer settings")
    property string string18: qsTr("Minutes", "timer settings")
    property string string19: qsTr("Seconds", "timer settings")
    property string string20: qsTr("Start", "timer button")
    property string string21: qsTr("Pause", "timer button")
    property string string22: qsTr("min", "timer display (min=minutes)")
    property string string23: qsTr("remaining", "timer display")
    property string string24: qsTr("Cancel", "timer button")

    // stopwatch
    property string string25: qsTr("Stopwatch", "page title")
    property string string26: qsTr("hours", "stopwatch display")
    property string string27: qsTr("min", "stopwatch display (min=minutes)")
    property string string28: qsTr("sec", "stopwatch display (sec=seconds)")
    property string string29: qsTr("ms", "stopwatch display (ms=milliseconds)")
    property string string30: qsTr("Start", "stopwatch button")
    property string string31: qsTr("Stop", "stopwatch button")
    property string string32: qsTr("Create lap", "stopwatch button")
    property string string33: qsTr("Reset", "stopwatch button")
    property string string34: qsTr("Lap %1", "stopwatch label")
}
