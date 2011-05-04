/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

//TODO: replace this with MeeGo.Components ExpandingBox when it 
// supports header components, vertical orientation

Item {
    id: root

    property alias headerComponent: headerLoader.sourceComponent
    property alias detailsComponent: detailsLoader.sourceComponent
    property string orientation: "horizontal"
    property alias expanded: details.visible
    property color bgColorExpanded: "#eaf6fb"
    property color bgColorCollapsed: "white"

    width: orientation == "vertical" ? header.width : parent.width
    height: orientation == "vertical" ? parent.height : header.height
    clip: true

    Rectangle {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        width: headerLoader.width
        height: headerLoader.height
        color: expanded ? bgColorExpanded : bgColorCollapsed

        Loader { id: headerLoader }

        MouseArea {
            anchors.fill: parent
            onClicked: expanded = !expanded
        }

    }

    Rectangle {
        id: details

        anchors.top: orientation == "vertical" ? parent.top : header.bottom
        anchors.left: orientation == "vertical" ? header.right : parent.left
        width: detailsLoader.width
        height: detailsLoader.height
        color: bgColorExpanded
        visible: false

        Loader { id: detailsLoader }
    }

    states: State {
            name: "expanded"
            when: expanded
            PropertyChanges {
                target: root
                width: orientation == "vertical" ? header.width + details.width : parent.width
                height: orientation == "vertical" ? parent.height : header.height + details.height
            }
    }

    transitions: Transition {
        SequentialAnimation {
            PropertyAnimation { properties: "width,height"; duration: 150 }
            ScriptAction {
                script: if (expanded)
                ListView.view.positionViewAtIndex(index, ListView.Center)
            }
        }
    }
}
