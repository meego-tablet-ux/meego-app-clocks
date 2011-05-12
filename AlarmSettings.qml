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
    property alias hours: timepicker.hours
    property alias minutes: timepicker.minutes
    property int days
    property int snooze
    property int type: typecontrol.item.selectedIndex
    property string soundName
    property string soundURI
    property string songTitle
    property string songURI

    spacing: 10

    Theme { id: theme }

    AlarmSettingsRow {
        title: qsTr("Name:")
        component: TextEntry { id: name }
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
                text: Code.formatTime(hours, minutes)
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
                        color: (days&(0x1 << index)) ? "black" : "#AAAAAA"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (days & (0x1 << index))
                                days &= ~(0x1 << index)
                            else
                                days |= (0x1 << index)
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
            //FIXME
        }
        visible: type == 0
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
                text: songTitle
            }
            MouseArea {
                anchors.fill: parent
                onClicked: musicpicker.show()
            }
        }
        visible: type == 1
        MusicPicker {
            id: musicpicker
            selectSongs: true
            onSongSelected: {
                songTitle = title;
                songURI = uri;
            }
        }
    }
}
