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

    SaveRestoreState {
	id: boxState
	onSaveRequired: {
	    setValue("expanded." + city, root.expanded)
	    sync()
	}
    }

    Component.onCompleted: {
	if (boxState.restoreRequired) {
	    root.expanded = boxState.value("expanded." + city, false)
	}
    }

    enabled: index != 0
    bgColorCollapsed: index == 0 ? theme_highlightColor : "white"
    bgOpacity: index == 0 || expanded ? 1 : 0

    headerComponent: Item {
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

            Component.onCompleted: {
                timeChanged();
                clocksPage.secondsTick.connect(timeChanged);
            }

            function timeChanged() {
                // workaround for https://bugs.meego.com/show_bug.cgi?id=19693
                try {
                    var date = new Date;
                    hours = gmt ? ((date.getUTCHours() + (gmt/3600) + 24)%24) : date.getUTCHours();
                    minutes = gmt ? ((date.getUTCMinutes() + (gmt/60) + 24*3600) % 60) : date.getMinutes();
                    seconds = date.getUTCSeconds();
                } catch (e) {
                    console.log(e);
                }
            }

        }

        Column {
            id: label
            anchors.left: root.orientation == "vertical" ? parent.left : clock.right
            anchors.right: parent.right
            anchors.top: root.orientation == "vertical" ? parent.top : undefined
            anchors.verticalCenter: root.orientation == "horizontal" ? parent.verticalCenter : undefined
            anchors.margins: 20
            spacing: 5
            TimeDayText {
                id: timeLabel
                font.pixelSize: 20
                color: theme_buttonFontColorActive
                tz: root.gmt
                width: parent.width
                elide: Text.ElideRight
            }
            Text {
                id: cityLabel
                font.pixelSize: 18
                text: city
                width: parent.width
                elide: Text.ElideRight
            }
            Text {
                id: gmtLabel
                font.pixelSize: 14
                text: gmtname
                width: parent.width
                elide: Text.ElideRight
            }
        }
    }

    detailsWidthHint: 505
    detailsHeightHint: 390

    detailsComponent: Item {
        width: root.orientation == "vertical" ? 505 : listview.width
        height: root.orientation == "vertical" ? listview.height : 390
        Item {
            anchors.fill: parent
            anchors.margins: 5
            Rectangle {
                id: detailsBox
                anchors { top: parent.top; left: parent.left; right: parent.right; bottom: buttonRow.top }
                color: "#d5ecf6"
                Text {
                    id: locLabel
                    anchors { top: parent.top; left: parent.left }
                    anchors.topMargin: 35
                    anchors.leftMargin: root.orientation == "vertical" ? 10 : 75
                    color: theme_fontColorMedium
                    font.pixelSize: 16
                    text: qsTr("Choose location:")
                }
                TextEntry {
                    id: locEntry
                    anchors { top: locLabel.bottom; left: parent.left; right: parent.right }
                    anchors.topMargin: 20
                    font.pixelSize: 18
                    anchors.leftMargin: root.orientation == "vertical" ? 10 : 75
                    anchors.rightMargin: root.orientation == "vertical" ? 10 : 75
                    onTextChanged: timezoneList.filter(text)
                }
                TimezoneList {
                    id: timezoneList
                    anchors { top: locEntry.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
                    anchors.leftMargin: root.orientation == "vertical" ? 11 : 76
                    anchors.rightMargin: root.orientation == "vertical" ? 11 : 76
                    anchors.bottomMargin: 10
                    Component.onCompleted: selectTitle(title);
                }
            }
            Row {
                id: buttonRow
                height: 66
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                anchors.leftMargin: root.orientation == "vertical" ? 10 : 75
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
                    onClicked: clocksPage.deleteClock(itemid)
                }
            }
        }
    }

    orientation: window.isLandscape ? "vertical" : "horizontal"

}
