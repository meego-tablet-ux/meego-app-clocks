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

    property Component headerComponent: null
    property Item headerItem: null
    property Component detailsComponent: null
    property Item detailsItem: null
    property string orientation: "horizontal"
    property bool expanded: false
    property color bgColorExpanded: theme_highlightColor
    property color bgColorCollapsed: "white"
    property alias bgOpacity: bgRectangle.opacity
    property bool enabled: true

    // hints provide the detailsComponent geometry, so the expandobox
    // can animate expanding before the component has loaded
    property int detailsWidthHint: 0
    property int detailsHeightHint: 0

    width: orientation == "vertical" ? header.width : parent.width
    height: orientation == "vertical" ? parent.height : header.height
    clip: true

    //allow only one expandobox open at a time
    onExpandedChanged: {
        if (ListView.view.currentItem && ListView.view.currentIndex != index)
            ListView.view.currentItem.expanded = false;
        if (expanded == true)
            ListView.view.currentIndex = index;
    }

    onHeaderComponentChanged: {
        if (headerItem) headerItem.destroy();
        headerItem = headerComponent.createObject(header);
    }

    Rectangle {
        id: bgRectangle
        anchors.top: parent.top
        anchors.left: parent.left
        width: headerItem.width
        height: headerItem.height
        color: expanded ? bgColorExpanded : bgColorCollapsed
    }
    Item {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        width: headerItem.width
        height: headerItem.height
        MouseArea {
            anchors.fill: parent
            onClicked: if (root.enabled) expanded = !expanded;
        }
    }

    Rectangle {
        id: details

        anchors.top: orientation == "vertical" ? parent.top : header.bottom
        anchors.left: orientation == "vertical" ? header.right : parent.left
        width: {
            if (orientation == "vertical")
                return detailsItem ? detailsItem.width : detailsWidthHint;
            else
                return parent.width;
        }
        height: {
            if (orientation == "horizontal")
                return detailsItem ? detailsItem.height : detailsHeightHint;
            else
                return parent.height;
        }
        color: bgColorExpanded
        opacity: 0.0
    }

    states: State {
            name: "expanded"
            when: expanded
            PropertyChanges {
                target: root
                width: orientation == "vertical" ? header.width + details.width : parent.width
                height: orientation == "vertical" ? parent.height : header.height + details.height
            }
            PropertyChanges {
                target: details
                opacity: 1.0
            }
    }

    transitions: Transition {
        reversible: true
        SequentialAnimation {
            PropertyAnimation { properties: "width,height,opacity"; duration: 150 }
            ScriptAction {
                script: if (expanded) {
                    ListView.view.positionViewAtIndex(index, ListView.Center);
                    detailsItem = detailsComponent.createObject(details);
                } else if (detailsItem)
                    detailsItem.destroy();
            }
        }
    }
}
