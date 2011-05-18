/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1
import MeeGo.App.Clocks 0.1
import "functions.js" as Code

ExpandoBox {
    id: root
    property bool a_active: headerItem.on

    Component.onCompleted: headerItem.on = active

    headerComponent: Item {
        property alias on: activeToggle.on

        width: root.orientation == "vertical" ? 189 : listview.width
        height: root.orientation == "vertical" ? listview.height : 164

        Clock {
            id: clock
            anchors.centerIn: root.orientation == "vertical" ? parent : undefined
            anchors.left: root.orientation == "horizontal" ? parent.left : undefined
            anchors.verticalCenter: root.orientation == "horizontal" ? parent.verticalCenter : undefined
            anchors.margins: 20
            hours: hour
            minutes: minute
            showSeconds: false
        }

        Column {
            id: label
            anchors.left: root.orientation == "vertical" ? parent.left : clock.right
            anchors.top: root.orientation == "vertical" ? parent.top : undefined
            anchors.verticalCenter: root.orientation == "horizontal" ? parent.verticalCenter : undefined
            anchors.margins: 20
            spacing: 5
            Text {
                id: timeLabel
                font.pixelSize: 20
                color: theme_buttonFontColorActive
                text: Code.formatTime(hour, minute)
            }
            Text {
                font.pixelSize: 18
                text: name
            }
            Text {
                id: gmtLabel
                font.pixelSize: 16
                text: Code.daysFriendly(days)
            }
        }

        ToggleButton {
            id: activeToggle
            anchors.left: root.orientation == "vertical" ? parent.left : undefined
            anchors.bottom: root.orientation == "vertical" ? parent.bottom : undefined
            anchors.right: root.orientation == "horizontal" ? triangle.left : undefined
            anchors.verticalCenter: root.orientation == "horizontal" ? parent.verticalCenter : undefined
            anchors.margins: 20
        }

        Image {
            id: triangle
            anchors.verticalCenter: root.orientation == "horizontal" ? parent.verticalCenter : undefined
            anchors.right: parent.right
            anchors.bottom: root.orientation == "vertical" ? parent.bottom : undefined
            anchors.margins: 30
            source: "image://themedimage/widgets/common/notifications/grabby"
            rotation: {
                if (root.orientation == "horizontal")
                    return expanded ? 0 : 180
                else
                    return expanded ? 270 : 90
            }
        }
    }

    detailsComponent: Item {
        width: root.orientation == "vertical" ? 505 : listview.width
        height: root.orientation == "vertical" ? listview.height : 440
        Item {
            anchors.fill: parent
            anchors.margins: 5
            Rectangle {
                id: detailsBox
                anchors { top: parent.top; left: parent.left; right: parent.right; bottom: buttonRow.top }
                color: "#d5ecf6"
                AlarmSettings {
                    id: alarmSettings
                    anchors.fill: parent
                    anchors { topMargin: 20; bottomMargin: 20; leftMargin: 20 }
                    anchors.rightMargin: root.orientation == "vertical" ? 20 : 70

                    a_name: name
                    a_hour: hour
                    a_minute: minute
                    a_days: days
                    a_snooze: snooze
                    a_soundtype: soundtype
                    a_soundname: soundtype == 0 ? soundname : ""
                    a_sounduri: soundtype == 0 ? soundfile : ""
                    a_songname: soundtype == 0 ? "" : soundname
                    a_songuri: soundtype == 0 ? "" : soundfile
                }
            }
            Row {
                id: buttonRow
                height: 66
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                anchors { leftMargin: 166 }
                anchors.rightMargin: root.orientation == "vertical" ? 10 : 75
                spacing: 10
                Button {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width/3 - 6
                    height: 45
                    font.pixelSize: 18
                    bgSourceUp: "image://themedimage/widgets/common/button/button-default"
                    bgSourceDn: "image://themedimage/widgets/common/button/button-default-pressed"
                    text: qsTr("Save")
                    onClicked: {
                        clockListModel.editAlarm(itemid,
                                                 alarmSettings.a_name,
                                                 alarmSettings.a_days,
                                                 alarmSettings.a_soundtype,
                                                 alarmSettings.a_soundtype == 0 ? alarmSettings.a_soundname : alarmSettings.a_songname,
                                                 alarmSettings.a_soundtype == 0 ? alarmSettings.a_sounduri : alarmSettings.a_songuri,
                                                 alarmSettings.a_snooze,
                                                 a_active,
                                                 alarmSettings.a_hour,
                                                 alarmSettings.a_minute);
                        expanded = false;
                    }
                }
                Button {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width/3 - 6
                    height: 45
                    font.pixelSize: 18
                    text: qsTr("Cancel")
                    onClicked: expanded = false
                }
                Button {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width/3 - 6
                    height: 45
                    font.pixelSize: 18
                    bgSourceUp: "image://themedimage/widgets/common/button/button-negative"
                    bgSourceDn: "image://themedimage/widgets/common/button/button-negative-pressed"
                    text: qsTr("Delete")
                    onClicked: confirmDelete.show()
                }
            }
        }
    }

    ModalMessageBox {
        id: confirmDelete
        width: 400
        height: 250
        title: qsTr("Delete alarm")
        text: qsTr("Are you sure you want to delete?")
        acceptButtonText: qsTr("Delete")
        cancelButtonText: qsTr("Cancel")
        acceptButtonImage: "image://themedimage/widgets/common/button/button-negative"
        acceptButtonImagePressed: "image://themedimage/widgets/common/button/button-negative-pressed"
        onAccepted: clockListModel.destroyItemByID(itemid)
    }

    orientation: window.isLandscape ? "vertical" : "horizontal"

}
