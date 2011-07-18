/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1
import MeeGo.Labs.Components 0.1 as Labs
import "functions.js" as Code

Column {
    property string a_name: ""
    property alias a_hour: timepicker.hours
    property alias a_minute: timepicker.minutes
    property int a_days: 0
    property int a_snooze: 0
    property int a_soundtype: 0
    property string a_soundname: ""
    property string a_sounduri: ""
    property string a_songname: ""
    property string a_songuri: ""

    spacing: 10

    SaveRestoreState {
        id: alarmState

        onSaveRequired: {
            setValue("alarm.name."      + a_name, parent.a_name)
            setValue("alarm.hour."      + a_name, parent.a_hour)
            setValue("alarm.minute."    + a_name, parent.a_minute)
            setValue("alarm.days."      + a_name, parent.a_days)
            setValue("alarm.snooze."    + a_name, parent.a_snooze)
            setValue("alarm.soundtype." + a_name, parent.a_soundtype)
            setValue("alarm.soundname." + a_name, parent.a_soundname)
            setValue("alarm.sounduri."  + a_name, parent.a_sounduri)
            setValue("alarm.songname."  + a_name, parent.a_songname)
            setValue("alarm.songuri."   + a_name, parent.a_songuri)

            sync()
        }
    }

    Component.onCompleted: {
        if (alarmState.restoreRequired) {
            parent.a_name      = value("alarm.name."      + a_name)
            parent.a_hour      = value("alarm.hour."      + a_name)
            parent.a_minute    = value("alarm.minute."    + a_name)
            parent.a_days      = value("alarm.days."      + a_name)
            parent.a_snooze    = value("alarm.snooze."    + a_name)
            parent.a_soundtype = value("alarm.soundtype." + a_name)
            parent.a_soundname = value("alarm.soundname." + a_name)
            parent.a_sounduri  = value("alarm.sounduri."  + a_name)
            parent.a_songname  = value("alarm.songname."  + a_name)
            parent.a_songuri   = value("alarm.songuri."   + a_name)
        }
    }

    Theme { id: theme }

    AlarmSettingsRow {
        title: qsTr("Name:")
        component: TextEntry {
            Component.onCompleted: text = a_name
            onTextChanged: a_name = text
        }
    }

    AlarmSettingsRow {
        id: settingsRow
        title: qsTr("Alarm time:")

        property int __showTimePicker: 0 // Save/restore does weird things with "bool".

        component: Rectangle {
            height: 45
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 6
                font.pixelSize: theme.fontPixelSizeLarge
                text: Code.formatTime(a_hour, a_minute)
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    settingsRow.__showTimePicker= 1
                    timepicker.show()
                }
            }

            SaveRestoreState {
                id: alarmTimeState

                onSaveRequired: {
                    setValue("alarmTime.showTimePicker", settingsRow.__showTimePicker)
                    sync()
                }
            }

            Component.onCompleted: {
                if (alarmTimeState.restoreRequired && value("alarmTime.showTimePicker"))
                    timepicker.show()
            }
        }

        TimePicker {
            id: timepicker
            hr24: localeHelper.timeFormat == Labs.LocaleHelper.TimeFormat24

            SaveRestoreState {
                id: alarmTimePickerState

                onSaveRequired: {
                    setValue("alarmTimePicker.hours",   timepicker.hours)
                    setValue("alarmTimePicker.minutes", timepicker.minutes)
                    sync()
                }
            }

            Component.onCompleted: {
                if (alarmTimePickerState.restoreRequired) {
                    hours   = value("alarmTimePicker.hours")
                    minutes = value("alarmTimePicker.minutes")
                }
            }
        }
    }

    AlarmSettingsRow {
        title: qsTr("Days:")
        component: Rectangle {
            height: 45
            Repeater {
                model: 7
                Item {
                    property int day: (index + localeHelper.firstDayOfWeek - 1) % 7
                    x: index * parent.width/7
                    width: parent.width/7
                    height: parent.height
                    anchors.top: parent.top
                    Text {
                        anchors.centerIn: parent
                        font.pixelSize: 16
                        text: Code.weekdayShort[day]
                        color: (a_days&(0x1 << day)) ? "black" : "#AAAAAA"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (a_days & (0x1 << day))
                                a_days &= ~(0x1 << day)
                            else
                                a_days |= (0x1 << day)
                        }
                    }
                }
            }
        }
    }

    AlarmSettingsRow {
        title: qsTr("Snooze duration:")
        component: DropDown {
            height: 45
            replaceDropDownTitle: true
            titleColor: "black"
            model: [qsTr("Never"),
                    qsTr("Every 5 mins"),
                    qsTr("Every 10 mins"),
                    qsTr("Every 15 mins")]
            payload: [0, 5, 10, 15]
            Component.onCompleted: {
                if (a_snooze == 5) selectedIndex = 1;
                else if (a_snooze == 10) selectedIndex = 2;
                else if (a_snooze == 15) selectedIndex = 3;
                else selectedIndex = 0;
            }
            onSelectedIndexChanged: a_snooze = payload[selectedIndex]
        }
    }

    AlarmSettingsRow {
        id: typecontrol
        title: qsTr("Type:")
        component: DropDown {
            height: 45
            titleColor: "black"
            replaceDropDownTitle: true
            model: [qsTr("Sound effect"), qsTr("Music track")]
            Component.onCompleted: selectedIndex = a_soundtype
            onSelectedIndexChanged: a_soundtype = selectedIndex
        }
    }

    AlarmSettingsRow {
        title: qsTr("Sound effect:")
        component: DropDown {
            height: 45
            titleColor: "black"
            replaceDropDownTitle: true
            model: alarmSoundsModel.soundNames
            payload: alarmSoundsModel.soundFiles
            Component.onCompleted: {
                selectedIndex = alarmSoundsModel.getIndexByFile(a_sounduri);
                a_soundname = model[selectedIndex];
                a_sounduri = payload[selectedIndex];
            }
            onSelectedIndexChanged: {
                a_soundname = model[selectedIndex];
                a_sounduri = payload[selectedIndex];
            }
        }
        visible: a_soundtype == 0
    }

    AlarmSettingsRow {
        title: qsTr("Music track:")

        property int __showMusicPicker: 0

        SaveRestoreState {
            id: musicTrackState

            onSaveRequired: {
                setValue("musicTrack.showMusicPicker", __showMusicPicker)
                sync()
            }
        }

        Component.onCompleted: {
            if (musicTrackState.restoreRequired && value("musicTrack.showMusicPicker"))
                musicpicker.show()
        }

        component: Rectangle {
            height: 45
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 6
                font.pixelSize: theme.fontPixelSizeLarge
                text: a_songname
            }
            MouseArea {
                anchors.fill: parent
                onClicked: musicpicker.show()
            }
        }
        visible: a_soundtype == 1

        MusicPicker {
            id: musicpicker
            selectSongs: true
            onSongSelected: {
                a_songname = title;
                a_songuri = uri;
            }
        }
    }
}
