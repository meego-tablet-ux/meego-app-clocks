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
    property string a_name: namecontrol.item.text
    property alias a_hour: timepicker.hours
    property alias a_minute: timepicker.minutes
    property int a_days
    property int a_snooze
    property int a_soundtype: typecontrol.item.selectedIndex
    property string a_soundname: ""
    property string a_sounduri: ""
    property string a_songname
    property string a_songuri

    spacing: 10

    Theme { id: theme }

    AlarmSettingsRow {
        id: namecontrol
        title: qsTr("Name:")
        component: TextEntry {
            Component.onCompleted: text = a_name
        }
    }

    AlarmSettingsRow {
        title: qsTr("Alarm time:")
        component: Rectangle {
            height: 45
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 14
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
        }
    }

    AlarmSettingsRow {
        id: typecontrol
        title: qsTr("Type:")
        component: DropDown {
            titleColor: "black"
            replaceDropDownTitle: true
            model: [qsTr("Sound effect"), qsTr("Music track")]
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
                anchors.leftMargin: 14
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
