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
    property alias currentItem: listView.currentItem

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
        id: listView
        anchors.fill: parent
        model: timezoneListModel
        clip: true

        delegate: BorderImage {
            id: borderImage

            // these are used to propagate data to the
            // create/edit clocks logic
            property int selectedgmt: gmtoffset
            property string selectedname: locationname
            property string selectedtitle: title

            source: {
                if (index == listView.count - 1)
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
                anchors.leftMargin: 6
                color: theme_fontColorMedium
                font.pixelSize: 18
                elide: Text.ElideRight
                width: parent.width - 100
                text: title
            }
            Text {
                anchors.baseline: parent.verticalCenter
                anchors.baselineOffset: 6
                anchors.right: parent.right
                anchors.rightMargin: 14
                color: theme_fontColorMedium
                font.pixelSize: 14
                //: %1 is "" or "+", %2 is GMT offset
                text: qsTr("(GMT %1%2)").arg(gmtoffset<0?"":"+").arg(gmtoffset)
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    listView.currentIndex = index;
                    locEntry.text = title;
                }
            }
        }
    }

}
