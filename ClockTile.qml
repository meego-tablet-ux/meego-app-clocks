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

Rectangle {
    id: clockTile

    property alias gmt: clock.gmt
    property string city: ""

    color: "white" //TODO: get color from theme

    Clock {
        id: clock
        anchors.margins: 20
    }

    Column {
        id: label
        spacing: 5
        anchors.margins: 20
        Text {
            id: timeLabel
            font.pixelSize: 20
            color: theme_buttonFontColorActive
            //FIXME: calculate day of week
            text: "11:30 Wednesday"
        }
        Text {
            id: cityLabel
            font.pixelSize: 18
            text: city
        }
        Text {
            id: gmtLabel
            font.pixelSize: 16
            text: qsTr("(GMT %1%2)").arg(gmt>=0?"+":"").arg(gmt)
        }
    }

    Image {
        id: dragHandle
        anchors.margins: 40
        source: "image://themedimage/widgets/common/drag-handle/drag-handle"
    }

    MouseArea {
        anchors.fill: parent
        onPressed: { console.log("pressed") }
        onReleased: { console.log("released") }
        onClicked: { console.log("clicked") }
        onCanceled: { console.log("canceled") }
        onPressAndHold: { console.log("pressandhold") }
    }

    states: [
        State {
            name: "landscape"
            when: window.inLandscape
            PropertyChanges {
                target: clockTile
                width: 189
                height: listview.height
            }
            AnchorChanges {
                target: clock
                // AnchorChanges doesnt seem to support "centerIn"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
            AnchorChanges {
                target: label
                anchors.top: parent.top
                anchors.left: parent.left
            }
            AnchorChanges {
                target: dragHandle
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        },
        State {
            name: "portrait"
            when: window.inPortrait
            PropertyChanges {
                target: clockTile
                width: listview.width
                height: 164
            }
            AnchorChanges {
                target: clock
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }
            AnchorChanges {
                target: label
                anchors.left: clock.right
                anchors.verticalCenter: parent.verticalCenter
            }
            AnchorChanges {
                target: dragHandle
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    ]
}
