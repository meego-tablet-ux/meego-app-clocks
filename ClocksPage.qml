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

    property Item __clockItem: null

    pageTitle: qsTr("Clocks")
    actionMenuModel: [qsTr("New clock")]
    actionMenuPayload: [1]
    onActionMenuTriggered: {
        if (selectedItem == 1) {
            __clockItem = newClockComponent.createObject(clocksPage);
            __clockItem.show();
        }
    }

    signal secondsTick()
    signal minutesTick()

    Timer {
        interval: 1000
        running: window.isActiveWindow
        repeat: true
        property int __seconds: 0

        onTriggered: {
            var date = new Date();
            if (date.getSeconds() < __seconds) {
                clocksPage.minutesTick();
            }
            __seconds = date.getSeconds();
            clocksPage.secondsTick();
        }
    }


    Rectangle {
        anchors.fill: parent
        color: "#EEEEEE" //TODO: get color from theme

        ListView {
            id: listview
            anchors.fill: parent
            anchors.topMargin: window.isLandscape ? 10 : 0
            anchors.bottomMargin: window.isLandscape ? 10 : 0
            anchors.leftMargin: window.isPortrait ? 10 : 0
            anchors.rightMargin: window.isPortrait ? 10 : 0
		    contentX: window.isPortrait ? 10 : 0
		    contentY: window.isPortrait ? 0 : 10
            spacing: 2
            orientation: window.isLandscape ? ListView.Horizontal : ListView.Vertical
            clip: true

            ClockListModel {
                id: clockListModel
                type: ClockListModel.ListofClocks
            }

            model: clockListModel

            //spacers to create illusion of 10px border at ends
            header: Item { width: 10; height: 10 }
            footer: Item { width: 10; height: 10 }

            delegate: ClockTile { gmt: gmtoffset; city: name }
        }
    }
    Component {
        id: newClockComponent
        ModalDialog {
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
