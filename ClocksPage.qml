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

AppPage {
    id: clocksPage

    pageTitle: qsTr("Clocks")
    actionMenuModel: [qsTr("New clock")]
    actionMenuPayload: [1]
    onActionMenuTriggered: {
        if (selectedItem == 1) {
            locEntry.text = "";
            newClockDialog.show();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#EEEEEE" //TODO: get color from theme

        Rectangle {
            id: localClock
            property int gmt: +3 //FIXME: timezone to come from connman
            property string city: "Helsinki"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            width: window.isLandscape ? 189 : parent.width - 20
            height: window.isLandscape ? parent.height - 20 : 164
            color: "#DDDDDD" //TODO: need vis reference for this

            Clock {
                id: clock
                anchors.centerIn: window.isLandscape ? parent : undefined
                anchors.left: window.isPortrait ? parent.left : undefined
                anchors.verticalCenter: window.isPortrait ? parent.verticalCenter : undefined
                anchors.margins: 20

                Component.onCompleted: timeChanged()

                function timeChanged() {
                    var date = new Date;
                    hours = localClock.gmt ? ((date.getUTCHours() + localClock.gmt + 24)%24) : date.getUTCHours();
                    minutes = localClock.gmt ? date.getUTCMinutes() + ((localClock.gmt % 1) * 60) : date.getMinutes();
                    seconds = date.getUTCSeconds();
                }

                Timer {
                    interval: 100
                    running: true
                    repeat: true
                    onTriggered: clock.timeChanged()
                }
            }

            Column {
                id: label
                anchors.left: window.isLandscape ? parent.left : clock.right
                anchors.right: parent.right
                anchors.top: window.isLandscape ? parent.top : undefined
                anchors.verticalCenter: window.isPortrait ? parent.verticalCenter : undefined
                anchors.margins: 20
                spacing: 5
                TimeDayText {
                    id: timeLabel
                    font.pixelSize: 20
                    color: theme_buttonFontColorActive
                    tz: localClock.gmt
                    width: parent.width
                    elide: Text.ElideRight
                }
                Text {
                    id: cityLabel
                    font.pixelSize: 18
                    text: localClock.city
                    width: parent.width
                    elide: Text.ElideRight
                }
                Text {
                    id: gmtLabel
                    font.pixelSize: 16
                    text: qsTr("(GMT %1%2)").arg(localClock.gmt<0?"":"+").arg(localClock.gmt)
                }
            }
        }

        ListView {
            id: listview
            anchors.top: window.isLandscape ? parent.top : localClock.bottom
            anchors.left: window.isLandscape ? localClock.right : parent.left
            anchors.right: parent.right
            anchors.bottom : parent.bottom
            anchors.topMargin: window.isLandscape ? 10 : 0
            anchors.bottomMargin: window.isLandscape ? 10 : 0
            anchors.leftMargin: window.isPortrait ? 10 : 0
            anchors.rightMargin: window.isPortrait ? 10 : 0
            spacing: 2
            orientation: window.isLandscape ? ListView.Horizontal : ListView.Vertical
            clip: true

            ClockListModel {
                id: clockListModel
                type: ClockListModel.ListofClocks
            }

            model: clockListModel

            //spacers to create illusion of 10px border at ends
            header: Item { width: 2; height: 2 }
            footer: Item { width: 10; height: 10 }

            delegate: ClockTile { gmt: gmtoffset; city: name }
        }
    }
    ModalDialog {
        id: newClockDialog
        width: 540 + 10
        height: 260 + 150
        title: qsTr("Add new clock")
        acceptButtonText: qsTr("Save")
        cancelButtonText: qsTr("Cancel")
        content: Item {
            anchors.fill: parent
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
                anchors { leftMargin: 166; topMargin: 35; rightMargin: 35 }
                font.pixelSize: 18
                onTextChanged: timezoneList.filter(text)
            }
            TimezoneList {
                id: timezoneList
                anchors { top: locEntry.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
                anchors { leftMargin: 167; rightMargin: 36; bottomMargin: 30 }
            }
        }
        onAccepted: {
            if ((timezoneList.currentItem != undefined)
                && (locEntry.text != "")) {
                if (!clockListModel.addClock(timezoneList.currentItem.selectedname, timezoneList.currentItem.selectedtitle, timezoneList.currentItem.selectedgmt)) {
                    dupeDialog.city = timezoneList.currentItem.selectedname;
                    dupeDialog.show();
                }
            }
        }
    }

    function deleteClock(id) {
        confirmDelete.id = id;
        confirmDelete.show();
    }

    ModalMessageBox {
        id: confirmDelete
        property string id
        width: 400
        height: 250
        title: qsTr("Delete clock")
        text: qsTr("Are you sure you want to delete?")
        acceptButtonText: qsTr("Delete")
        cancelButtonText: qsTr("Cancel")
        acceptButtonImage: "image://themedimage/widgets/common/button/button-negative"
        acceptButtonImagePressed: "image://themedimage/widgets/common/button/button-negative-pressed"
        onAccepted: clockListModel.destroyItemByID(id)
    }

    ModalMessageBox {
        id: dupeDialog
        property string city
        width: 400
        height: 250
        title: qsTr("Error")
        text: qsTr("You've already got a clock for %1.").arg(city)
        showAcceptButton: false
        cancelButtonText: qsTr("Cancel")
    }


}
