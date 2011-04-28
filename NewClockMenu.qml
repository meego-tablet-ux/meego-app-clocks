/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1 as Labs
import MeeGo.Components 0.1
import MeeGo.App.Clocks 0.1

Item {
    id: container
    anchors.fill:parent

    property variant model: undefined
    property int itemHeight: 50
    property bool landscape: true

    signal triggered(string c_name, string c_title, int c_gmt)
    signal close()

    function initialize(title, gmt) {
        timezonelist.filterOut(title);
        theclock.gmt = gmt
        tzlistmodel.currentIndex = 0;
        tzlistmodel.highlight = highlighter;
        inputElement.text = title;
    }

    Labs.TimezoneListModel {
        id: timezonelist
    }

    Component {
        id: highlighter
        Rectangle {
            color: "green"
        }
    }

    Component {
        id: highlighteroff
        Rectangle {
            color: "transparent"
        }
    }

    Image {
        id: menu
        anchors.fill: parent
        source: "image://theme/clock/bg_clock_panel_editing_l"
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Clock {
            id: theclock
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.leftMargin: 20
            gmt: 0
            minimal: true
            landscape: container.landscape
            MouseArea {
                anchors.fill: parent
                onClicked: {
                }
            }
        }

        Image {
            id: timezones
            anchors.bottom: buttons.top
            anchors.left: parent.left
            anchors.bottomMargin: 10
            anchors.leftMargin: 40
            height: parent.height - theclock.height - buttons.height - 30
            width: parent.width - 80
            source: "image://theme/clock/bg_grooved_area"
            ListView {
                id: tzlistmodel
                anchors.fill: parent
                clip: true
                z: -1
                model: timezonelist
                highlight: highlighteroff
                highlightMoveDuration: 1
                delegate: Image {
                   id: timerect
                   property int gmt: gmtoffset
                   property string clockname: city
                   property string clocktitle: title
                   source: "image://theme/clock/bg_list_item"
                   height: 30
                   width: parent.width
                   Text {
                       text: title
                       anchors.left: timerect.left
                       anchors.verticalCenter: parent.verticalCenter
                       color: theme_fontColorNormal
                       font.pixelSize: theme_fontPixelSizeLarge
                       font.bold: false
                       verticalAlignment: Text.AlignVCenter
                       horizontalAlignment: Text.AlignHCenter
                       wrapMode: Text.WordWrap
                   }
                   Text {
                       text: (gmtoffset < 0)?qsTr("(GMT %1)").arg(gmtoffset):qsTr("(GMT +%1)").arg(gmtoffset)
                       anchors.right: timerect.right
                       anchors.verticalCenter: parent.verticalCenter
                       color: theme_fontColorNormal
                       font.pixelSize: theme_fontPixelSizeLarge
                       font.bold: false
                       verticalAlignment: Text.AlignVCenter
                       horizontalAlignment: Text.AlignHCenter
                       wrapMode: Text.WordWrap
                   }
                   MouseArea {
                       anchors.fill: parent
                       onClicked: {
                           theclock.gmt = gmtoffset
                           tzlistmodel.currentIndex = index;
                           tzlistmodel.highlight = highlighter;
                           inputElement.text = title;
                       }
                   }
                }
            }
        }

        Item {
            id: buttons
            height: 80
            width: parent.width
            anchors.bottom: parent.bottom
            Item {
                width: timezones.width
                height: parent.height
                anchors.centerIn: parent
                Button {
                    id: saveButton
                    height: 68
                    width: 208
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    active: ((tzlistmodel.currentItem != undefined)&&(inputElement.displayText != ""))
                    bgSourceUp: "image://theme/btn_blue_up"
                    bgSourceDn: "image://theme/btn_blue_dn"
                    text: qsTr("Save")
                    font.pixelSize: theme_fontPixelSizeLarge
                    onClicked: {
                        if((tzlistmodel.currentItem != undefined)&&(inputElement.displayText != ""))
                        {
                            container.triggered(tzlistmodel.currentItem.clockname, tzlistmodel.currentItem.clocktitle, tzlistmodel.currentItem.gmt);
                            container.close();
                        }
                    }
                }
                Button {
                    id: cancelButton
                    height: 68
                    width: 208
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    bgSourceUp: "image://theme/btn_red_up"
                    bgSourceDn: "image://theme/btn_red_dn"
                    text: qsTr("Cancel")
                    font.pixelSize: theme_fontPixelSizeLarge
                    onClicked: {
                        container.close();
                    }
                }
            }
        }

        Image {
            anchors.verticalCenter: theclock.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 40
            width: parent.width - theclock.width - 80
            source: "image://theme/clock/bg_searchbox"
            Image {
                id: searchIcon
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                source: "image://theme/clock/icn_search"
            }
            TextInput {
                id: inputElement
                anchors.left: searchIcon.right
                anchors.top: parent.top
                height: parent.height
                width: parent.width - searchIcon.width - 30
                anchors.margins: 10
                font.pixelSize: theme_fontPixelSizeLarge
                color: theme_fontColorNormal
                onTextChanged: {
                    timezonelist.filterOut(inputElement.displayText);
                    tzlistmodel.currentIndex = 0;
                    tzlistmodel.highlight = highlighter;
                    if(tzlistmodel.currentItem != undefined)
                        theclock.gmt = tzlistmodel.currentItem.gmt;
                }
                Keys.onReturnPressed: {
                    if((tzlistmodel.currentItem != undefined)&&(inputElement.displayText != ""))
                    {
                        container.triggered(tzlistmodel.currentItem.clockname, tzlistmodel.currentItem.clocktitle, tzlistmodel.currentItem.gmt);
                        container.close();
                    }
                }
            }
        }
    }
}
