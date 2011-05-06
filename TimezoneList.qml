/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1 as Labs

Rectangle {
    color: "white"

    function filter(arg) { timezoneListModel.filterOut(arg); }
    
    Labs.TimezoneListModel { id: timezoneListModel }

    Rectangle {
        anchors.fill: parent
        z: 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: "#10000000" }
        }
    }

    ListView {
        anchors.fill: parent
        model: timezoneListModel
        clip: true

        delegate: Component {
            BorderImage {
                id: borderImage
                source: {
                    if (index == timezoneListModel.count - 1)
                        return mouseArea.pressed ? "image://themedimage/widgets/common/list/list-single-active" : "image://themedimage/widgets/common/list/list-single-inactive";
                    else
                        return mouseArea.pressed ? "image://themedimage/widgets/common/list/list-active" : "image://themedimage/widgets/common/list/list-inactive";
                }
                border { top: 2; bottom: 2; left: 1; right: 1 }
                width: parent.width
                height: 40
                Text {
                    anchors.baseline: parent.verticalCenter
                    anchors.baselineOffset: 6
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    color: theme_fontColorMedium
                    font.pixelSize: 18
                    text: qsTr("%1, %2").arg(city).arg(countrycode)
                }
                Text {
                    anchors.baseline: parent.verticalCenter
                    anchors.baselineOffset: 6
                    anchors.right: parent.right
                    anchors.rightMargin: 15
                    color: theme_fontColorMedium
                    font.pixelSize: 14
                    text: qsTr("(GMT %1%2)").arg(gmtoffset<0?"":"+").arg(gmtoffset)
                }
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                }
            }
        }
    }

}
