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
    pageTitle: qsTr("Clocks")

    actionMenuModel: [qsTr("New clock")]
    actionMenuPayload: [1]
    onActionMenuTriggered: {
        if (selectedItem == 1) {
            locEntry.text = "";
            newClockDialog.show();
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
        // FIXME
        //onAccepted: doSomething()
    }

    Rectangle {
        anchors.fill: parent
        color: "#EEEEEE" //TODO: get color from theme
        clip: true  //needed to prevent list from scrolling over titlebar
        ListView {
            id: listview

            anchors.fill: parent
            spacing: 2

            model: 24 //FIXME: use real model here

            //spacers to create illusion of 10px border at ends
            header: Component { Item { width: 10; height: 10 } }
            footer: Component { Item { width: 10; height: 10 } }

            delegate: Component {
                // FIXME: populate with data from model
                ClockTile { gmt: index - 12; city: "London, UK" }
            }

            states: [
                State {
                    name: "landscape"
                    when: window.inLandscape || window.inInvertedLandscape
                    PropertyChanges {
                        target: listview
                        anchors { leftMargin: 0; rightMargin: 0;
                                  topMargin: 10; bottomMargin: 10 }
                        orientation: ListView.Horizontal
                    }
                },
                State {
                    name: "portrait"
                    when: window.inPortrait || window.inInvertedPortrait
                    PropertyChanges {
                        target: listview
                        anchors { leftMargin: 10; rightMargin: 10;
                                  topMargin: 0; bottomMargin: 0 }
                        orientation: ListView.Vertical
                    }
                }
            ]

        }
    }
}
