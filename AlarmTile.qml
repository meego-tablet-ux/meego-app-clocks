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

ExpandoBox {
    id: root

    property int gmt
    property string city: ""

    headerComponent: Item {
        width: root.orientation == "vertical" ? 189 : listview.width
        height: root.orientation == "vertical" ? listview.height : 164

        Clock {
            id: clock
            anchors.centerIn: root.orientation == "vertical" ? parent : undefined
            anchors.left: root.orientation == "horizontal" ? parent.left : undefined
            anchors.verticalCenter: root.orientation == "horizontal" ? parent.verticalCenter : undefined
            anchors.margins: 20
            gmt: root.gmt
        }

        Column {
            id: label
            anchors.left: root.orientation == "vertical" ? parent.left : clock.right
            anchors.top: root.orientation == "vertical" ? parent.top : undefined
            anchors.verticalCenter: root.orientation == "horizontal" ? parent.verticalCenter : undefined
            anchors.margins: 20
            spacing: 5
            TimeDayText {
                id: timeLabel
                font.pixelSize: 20
                color: theme_buttonFontColorActive
                tz: root.gmt
            }
            Text {
                id: cityLabel
                font.pixelSize: 18
                text: city
            }
            Text {
                id: gmtLabel
                font.pixelSize: 16
                text: qsTr("(GMT %1%2)").arg(gmt<0?"":"+").arg(gmt)
            }
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
        height: root.orientation == "vertical" ? listview.height : 290
        Item {
            anchors.fill: parent
            anchors.margins: 5
            Rectangle {
                id: detailsBox
                anchors { top: parent.top; left: parent.left; right: parent.right; bottom: buttonRow.top }
                color: "#d5ecf6"
                Text {
                    id: locLabel
                    anchors { verticalCenter: locEntry.verticalCenter; left: parent.left }
                    anchors { margins: 20 }
                    color: theme_fontColorMedium
                    font.pixelSize: 16
                    text: qsTr("Choose location:")
                }
                TextEntry {
                    id: locEntry
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    anchors { leftMargin: 166; topMargin: 10 }
                    font.pixelSize: 18
                    anchors.rightMargin: root.orientation == "vertical" ? 10 : 75
                    Component.onCompleted: text = title
                    onTextChanged: timezoneList.filter(text)
                }
                TimezoneList {
                    id: timezoneList
                    anchors { top: locEntry.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
                    anchors.leftMargin: 167
                    anchors.rightMargin: root.orientation == "vertical" ? 11 : 76
                    anchors.bottomMargin: 10
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
                        clockListModel.editClock(itemid, timezoneList.currentItem.selectedname, timezoneList.currentItem.selectedtitle, timezoneList.currentItem.selectedgmt);
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