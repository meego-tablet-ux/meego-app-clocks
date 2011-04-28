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

import "functions.js" as Code

Labs.Window {
    id: scene
    filterModel: [qsTr("Clocks"), qsTr("Alarms")]
    applicationPage: myApp

    property int animationDuration: 500
    property int buttonval: 1
    property variant editting: undefined

    onFilterTriggered: {
        if(index == 0)
        {
            currentApplication.title = qsTr("Clocks");
            buttonval = 1;
            clockListModel.type = ClockListModel.ListofClocks;
        }
        else if(index == 1)
        {
            currentApplication.title = qsTr("Alarms");
            buttonval = 0;
            clockListModel.type = ClockListModel.ListofAlarms;
        }
    }

    Connections {
        target: mainWindow
        onCall: {
            console.log("Global onCall: " + parameters);
            if(parameters[0] == "orientation")
                orientation = (orientation+1)%4;
            else if(parameters[0] == "close")
                Qt.quit();
        }
    }

    Loader {
        anchors.fill: parent
        id: dialogLoader
    }

    property string itemtodelete;
    ModalDialog {
        id: verifyDelete
        acceptButtonText: qsTr("yes")
        cancelButtonText: qsTr("no")
        title: qsTr("Are you sure you want to delete?")
        onAccepted: {
            clockListModel.destroyItemByID(itemtodelete);
        }
    }

    function deleteitem(itemid)
    {
        itemtodelete = itemid;
        verifyDelete.show();
    }

    Labs.ContextMenu {
        id: contextMenu
        onTriggered: {
            if (index == 0)
            {
                // Clock Details
                editting = payload;

                if(clockListModel.type == ClockListModel.ListofAlarms)
                    payload.itemloader.sourceComponent = payload.compalarmedit;
                else
                    payload.itemloader.sourceComponent = payload.compclockedit;

                if(scene.isLandscapeView())
                    payload.width = 800;
                else
                    payload.height = 600;
                payload.initeditor();
            }
            else if (index == 1)
            {
                // Set Local for clocks, Delete Alarm for alarms
                if(clockListModel.type == ClockListModel.ListofAlarms)
                    deleteitem(payload.currentid);
                else
                    clockListModel.setLocalClock(payload.currentid);
            }
            else if (index == 2)
            {
                // Delete Clock for clocks, Reorder for alarms
                if(clockListModel.type == ClockListModel.ListofAlarms)
                    clockListModel.setOrder(payload.currentid, 0);
                else
                    deleteitem(payload.currentid);
            }
            else if (index == 3)
            {
                // Reorder
                clockListModel.setOrder(payload.currentid, 1);
            }
        }
    }

    ClockListModel {
        id: clockListModel
        type: ClockListModel.ListofClocks
    }

    function openNewMenu(component, loader)
    {
        loader.sourceComponent = component
        loader.item.parent = scene.container

        var menuContainer = loader.item
        menuContainer.width = scene.container.width
        menuContainer.height = scene.container.height
        menuContainer.z = 100
    }

    Component {
        id: myApp
        Labs.ApplicationPage {
            id: myPage
            anchors.fill: parent
            title: qsTr("Clocks")
            disableSearch: true

            menuContent: Item {
                width: childrenRect.width
                height: childrenRect.height
                Labs.ActionMenu {
                    model: [(buttonval == 0)?qsTr("New alarm"):qsTr("New clock")]
                    onTriggered: {
                        editting = undefined;
                        if(buttonval == 0)
                            addAlarmMenu.visible = true;
                        else if(buttonval == 1)
                            addClockMenu.visible = true;
                        myPage.closeMenu();
                    }
                }
            }

            Labs.ModalSurface {
                id: addAlarmMenu
                autoCenter: true
                content: NewAlarmMenu {
                    width:(scene.isLandscapeView())?Math.min(scene.width, 700):Math.min(scene.height, 700)
                    height: (scene.isLandscapeView())?Math.min(scene.height, 550):Math.min(scene.width, 550)
                    landscape: scene.isLandscapeView()
                    onClose: addAlarmMenu.visible = false
                    onTriggered: {
                        clockListModel.addAlarm(a_name, a_days, a_soundtype, a_soundname,
                                                a_soundfile, a_snooze, a_active, a_hour, a_minute);
                    }
                }
            }

            Labs.ModalSurface {
                id: addClockMenu
                autoCenter: true
                content: NewClockMenu {
                    width:(scene.isLandscapeView())?Math.min(scene.width, 700):Math.min(scene.height, 700)
                    height: (scene.isLandscapeView())?Math.min(scene.height, 550):Math.min(scene.width, 550)
                    landscape: scene.isLandscapeView()
                    onClose: addClockMenu.visible = false
                    onTriggered: {
                        clockListModel.addClock(c_name, c_title, c_gmt);
                    }
                }
            }

            Item {
                id: landingScreenContent
                parent: myPage.content
                anchors.fill: parent

                Item {
                    id: listarea
                    height: parent.height
                    width: parent.width
                    Connections {
                        target: scene
                        onOrientationChanged: {
                            mainlistview.contentX = 0;
                            mainlistview.contentY = 0;
                        }
                    }
                    ListView {
                        id: mainlistview
                        anchors.fill: parent
                        orientation: ((scene.orientation == 1)||(scene.orientation == 3))?ListView.Horizontal:ListView.Vertical
                        model: clockListModel
                        highlightMoveDuration:100
                        clip: true
                        delegate: Item {
                           id: dinstance
                           height: (scene.isLandscapeView())?listarea.height:loader.item.height
                           width: (scene.isLandscapeView())?loader.item.width:listarea.width

                           Behavior on width {
                               PropertyAnimation {
                                   duration: 150
                                   easing.type: Easing.OutSine
                               }
                           }
                           Behavior on height {
                               PropertyAnimation {
                                   duration: 150
                                   easing.type: Easing.OutSine
                               }
                           }

                           property alias itemloader: loader
                           property alias compclock: clockComponent
                           property alias compclockedit: editClockComponent
                           property alias compalarm: alarmComponent
                           property alias compalarmedit: editAlarmComponent
                           property string currentid: itemid
                           property int currentidx: index
                           function initeditor()
                           {
                               if(loader.item.initialize != undefined)
                               {
                                   if(clockListModel.type == ClockListModel.ListofAlarms)
                                       loader.item.initialize(name, days, soundtype,
                                                              soundname, soundfile,
                                                              snooze, active,
                                                              hour, minute);
                                   else
                                       loader.item.initialize(title, gmtoffset);
                               }
                           }

                           Loader {
                               id: loader
                               // set the initial state
                               sourceComponent:(buttonval == 0)?alarmComponent:clockComponent
                               onStatusChanged: {
                                   if(status == Loader.Ready) {
                                       item.parent = loader.parent;
                                       item.anchors.centerIn = parent;
                                   }
                               }
                           }

                           Component {
                               id: clockComponent
                               BorderImage {
                                   id: backgroundClock
                                   width: scene.isLandscapeView()?undefined:parent.width
                                   height: scene.isLandscapeView()?parent.height:undefined
                                   source: scene.isLandscapeView()?"image://theme/clock/bg_clock_panel_l":"image://theme/clock/bg_clock_panel_p_up"
                                   Clock {
                                       id: theclock
                                       anchors.centerIn: parent
                                       cityname: name
                                       gmt: gmtoffset
                                       landscape: scene.isLandscapeView()
                                       localzone: (index == 0)
                                   }
                               }
                           }

                           Component {
                               id: alarmComponent
                               BorderImage {
                                   id: backgroundAlarm
                                   width: scene.isLandscapeView()?undefined:parent.width
                                   height: scene.isLandscapeView()?parent.height:undefined
                                   anchors.centerIn: parent
                                   source: scene.isLandscapeView()?"image://theme/clock/bg_clock_panel_l":"image://theme/clock/bg_clock_panel_p_up"
                                   Alarm {
                                       id: thealarm
                                       anchors.centerIn: parent
                                       alarmName: name
                                       alarmDays: days
                                       alarmHour: hour
                                       alarmMinute: minute
                                       alarmActive: active
                                       landscape: scene.isLandscapeView()
                                       onTriggered: {
                                           clockListModel.editAlarm(itemid, name, days,
                                                                    soundtype, soundname, soundfile,
                                                                    snooze, a_active,
                                                                    hour, minute);
                                       }
                                   }
                               }
                           }

                           Component {
                               id: editClockComponent
                               NewClockMenu {
                                   onClose: {
                                       loader.sourceComponent = clockComponent;
                                       if(scene.isLandscapeView())
                                           dinstance.width = loader.item.width;
                                       else
                                           dinstance.height = loader.item.height;
                                       editting = undefined;
                                   }
                                   Component.onCompleted: {
                                      mainlistview.currentIndex = index;
                                   }
                                   onTriggered: {
                                       clockListModel.editClock(itemid, c_name, c_title, c_gmt);
                                   }
                               }
                           }

                           Component {
                               id: editAlarmComponent
                               NewAlarmMenu {
                                   onClose: {
                                       loader.sourceComponent = alarmComponent;
                                       if(scene.isLandscapeView())
                                           dinstance.width = loader.item.width;
                                       else
                                           dinstance.height = loader.item.height;
                                       editting = undefined;
                                   }
                                   onNuke: {
                                       deleteitem(itemid);
                                   }
                                   Component.onCompleted: {
                                      mainlistview.currentIndex = index;
                                   }
                                   onTriggered: {
                                       clockListModel.editAlarm(itemid, a_name, a_days,
                                                                a_soundtype, a_soundname, a_soundfile,
                                                                a_snooze, a_active,
                                                                a_hour, a_minute);
                                   }
                               }
                           }

                           ExtendedMouseArea {
                               id: mouseArea
                               anchors.fill:parent
                               onPressed:{
                                   if(editting != undefined)
                                   {
                                       if(clockListModel.type == ClockListModel.ListofAlarms)
                                           editting.itemloader.sourceComponent = editting.compalarm;
                                       else
                                           editting.itemloader.sourceComponent = editting.compclock;

                                       if(scene.isLandscapeView())
                                           editting.width = editting.itemloader.item.width;
                                       else
                                           editting.height = editting.itemloader.item.height;
                                       editting = undefined;
                                   }
                               }
                               onDoubleClicked: {
                               }
                               onLongPressAndHold: {
                                   if(clockListModel.type == ClockListModel.ListofAlarms)
                                   {
                                       var map = mapToItem(scene, mouseX, mouseY);
                                       contextMenu.model = [qsTr("Alarm details"), qsTr("Delete alarm"), qsTr("Move to top")]
                                       contextMenu.payload = dinstance;
                                       contextMenu.menuX = map.x;
                                       contextMenu.menuY = map.y;
                                       contextMenu.visible = true;
                                   }
                                   else if(index == 1)
                                   {
                                       var map = mapToItem(scene, mouseX, mouseY);
                                       contextMenu.model = [qsTr("Edit clock"), qsTr("Make local time"), qsTr("Delete clock")]
                                       contextMenu.payload = dinstance;
                                       contextMenu.menuX = map.x;
                                       contextMenu.menuY = map.y;
                                       contextMenu.visible = true;
                                   }
                                   else if(index > 1)
                                   {
                                       var map = mapToItem(scene, mouseX, mouseY);
                                       contextMenu.model = [qsTr("Edit clock"), qsTr("Make local time"), qsTr("Delete clock"), qsTr("Move to top")]
                                       contextMenu.payload = dinstance;
                                       contextMenu.menuX = map.x;
                                       contextMenu.menuY = map.y;
                                       contextMenu.visible = true;
                                   }
                               }
                           }
                        }
                    }
                }

                states: [
                    State {
                        name: "view0"
                        when: clockListState == 0
                        PropertyChanges {
                            target: loader.item
                            opacity: 1
                        }
                    },
                    State {
                        name: "view1"
                        when: clockListState == 1
                        PropertyChanges {
                            target: loader.item
                            opacity: 1
                        }
                    }
                ]

                transitions: [
                    Transition {
                        SequentialAnimation {
                            PropertyAnimation {
                                properties: "opacity"
                                duration: 500
                                easing.type: Easing.OutSine
                            }
                        }
                    }
                ]
            }
        }
    }
}
