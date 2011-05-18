/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1
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

    Theme { id: theme }

    AlarmSettingsRow {
        title: qsTr("Name:")
        component: TextEntry {
            Component.onCompleted: text = a_name
            onTextChanged: a_name = text
        }
    }

    AlarmSettingsRow {
        title: qsTr("Alarm time:")
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
                onClicked: timepicker.show()
            }
        }
        TimePicker { id: timepicker; hr24: true }
    }

    AlarmSettingsRow {
        title: qsTr("Days:")
        component: Rectangle {
            height: 45
            Repeater {
                model: 7
                Item {
                    x: index * parent.width/7
                    width: parent.width/7
                    height: parent.height
                    anchors.top: parent.top
                    Text {
                        anchors.centerIn: parent
                        font.pixelSize: 16
                        text: Code.weekdayShort[index]
                        color: (a_days&(0x1 << index)) ? "black" : "#AAAAAA"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (a_days & (0x1 << index))
                                a_days &= ~(0x1 << index)
                            else
                                a_days |= (0x1 << index)
                        }
                    }
                }
            }
        }
    }

    AlarmSettingsRow {
        title: qsTr("Snooze duration:")
        component: DropDown {
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
            titleColor: "black"
            replaceDropDownTitle: true
            model: ["Blurp",
                    "ChordUp",
                    "ChordDown",
                    "ChimeUp",
                    "ChimeDown"]
            //FIXME: need meego alarm sounds
            Component.onCompleted: {
                if (a_soundname == "ChordUp") selectedIndex = 1;
                else if (a_soundname == "ChordDown") selectedIndex = 2;
                else if (a_soundname == "ChimeUp") selectedIndex = 3;
                else if (a_soundname == "ChimeDown") selectedIndex = 4;
                else selectedIndex = 0;
            }
            onSelectedIndexChanged: a_soundname = model[selectedIndex]
        }
        visible: a_soundtype == 0
    }

    AlarmSettingsRow {
        title: qsTr("Music track:")
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
