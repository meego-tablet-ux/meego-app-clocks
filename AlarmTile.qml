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
import MeeGo.App.Clocks 0.1
import "functions.js" as Code

ExpandoBox {
    id: root
    property bool a_active: headerItem.on
    property bool __suppress: false

    SaveRestoreState {
        id: alarmTileState
        onSaveRequired: {
            setValue("alarmTile.expanded." + name, root.expanded)
            sync()
        }
    }

    Component.onCompleted: {
        __suppress = true;
        headerItem.on = active;
        __suppress = false;

        if (alarmTileState.restoreRequired) {
            root.expanded = alarmTileState.value("alarmTile.expanded." + name, false)
        }
    }

    bgOpacity: expanded ? 1 : 0

    headerComponent: Item {
        property alias on: activeToggle.on

        onOnChanged: { if (!__suppress)
            clockListModel.editAlarm(itemid,
                                     name,
                                     days,
                                     soundtype,
                                     soundname,
                                     soundfile,
                                     snooze,
                                     on,
                                     hour,
                                     minute);
        }
        width: root.orientation == "vertical" ? 189 : listview.width
        height: root.orientation == "vertical" ? listview.height : 164

        ListSeparator {
            visible: index > 0
            isHorizontal: root.orientation == "horizontal"
        }

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
            anchors.right: root.orientation == "vertical" ? parent.right : activeToggle.left
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
                width: parent.width
                elide: Text.ElideRight
            }
            Text {
                id: gmtLabel
                font.pixelSize: 16
                text: Code.daysFriendly(days)
            }
        }

        ToggleButton {
            id: activeToggle
            anchors.horizontalCenter: root.orientation == "vertical" ? parent.horizontalCenter : undefined
            anchors.bottom: root.orientation == "vertical" ? parent.bottom : undefined
            anchors.right: root.orientation == "horizontal" ? parent.right : undefined
            anchors.verticalCenter: root.orientation == "horizontal" ? parent.verticalCenter : undefined
            anchors.margins: 20
        }
    }

    detailsWidthHint: 505
    detailsHeightHint: 540

    detailsComponent: Item {
        width: root.orientation == "vertical" ? 505 : listview.width
        height: root.orientation == "vertical" ? listview.height : 540
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
                    anchors { topMargin: 10; bottomMargin: 20 }
                    anchors.leftMargin: root.orientation == "vertical" ? 10 : 75
                    anchors.rightMargin: root.orientation == "vertical" ? 10 : 75

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
                anchors.leftMargin: root.orientation == "vertical" ? 0 : 75
                anchors.rightMargin: root.orientation == "vertical" ? 0 : 75
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
                    onClicked: alarmsPage.deleteAlarm(itemid)
                }
            }
        }
    }

    orientation: window.isLandscape ? "vertical" : "horizontal"

}
