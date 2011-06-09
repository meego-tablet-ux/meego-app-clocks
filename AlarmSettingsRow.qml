/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

Item {
    property alias title: text.text
    property alias component: loader.sourceComponent
    property alias item: loader.item
    anchors.left: parent.left
    anchors.right: parent.right
    height: loader.height

    Text {
        id: text
        anchors {right: loader.left; verticalCenter: loader.verticalCenter }
        anchors.margins: 20
        color: theme_fontColorMedium
        font.pixelSize: 16
    }

    Loader {
        id: loader
        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom }
        anchors.leftMargin: 166 - 20
    }
}
