/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
Item {
    property bool isHorizontal: true
    height: isHorizontal ? 2 : parent.height
    width: isHorizontal ? parent.width : 2
    Rectangle {
        id: spaceLineDark
        color: theme_separatorDarkColor
        opacity: theme_separatorDarkAlpha
        height: isHorizontal ? 1 : parent.height
        width: isHorizontal ? parent.width : 1
        anchors.top: isHorizontal ? parent.top : undefined
        anchors.left: isHorizontal ? undefined : parent.left
    }
    Rectangle {
        id: spaceLineLight
        color: theme_separatorLightColor
        opacity: theme_separatorLightAlpha
        height: isHorizontal ? 1 : parent.height
        width: isHorizontal ? parent.width : 1
        anchors.bottom: isHorizontal ? parent.bottom : undefined
        anchors.right: isHorizontal ? undefined : parent.right
    }
}
