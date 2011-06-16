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
    function selectTitle(arg) {
        for (var i = timezoneListModel.count - 1; i >= 0; i--) {
            if (timezoneListModel.getData(i, Labs.TimezoneListModel.Title) === arg) {
                listView.currentIndex = i;
                listView.positionViewAtIndex(i, ListView.Beginning);
            }
        }
    }
    
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
                // FIXME: temporarily disabled singleton listitem graphic
                // due to annoying QML spam about non-NOTIFYable properties

                //if (index == timezoneListModel.count - 1) {
                //    if (mouseArea.pressed) {
                //        return "image://themedimage/widgets/common/list/list-single-active";
                //    } else if (ListView.isCurrentItem) {
                //        return "image://themedimage/widgets/common/list/list-single-selected";
                //    } else {
                //        return "image://themedimage/widgets/common/list/list-single-inactive";
                //    }
                //} else {
                    if (mouseArea.pressed) {
                        return "image://themedimage/widgets/common/list/list-active";
                    } else if (ListView.isCurrentItem) {
                        return "image://themedimage/widgets/common/list/list-selected";
                    } else {
                        return "image://themedimage/widgets/common/list/list-inactive";
                    }
                //}
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
                text: locationname
            }
            Text {
                anchors.baseline: parent.verticalCenter
                anchors.baselineOffset: 6
                anchors.right: parent.right
                anchors.rightMargin: 14
                color: theme_fontColorMedium
                font.pixelSize: 14
                text: gmtname
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    listView.currentIndex = index;
                }
            }
        }
    }

}
