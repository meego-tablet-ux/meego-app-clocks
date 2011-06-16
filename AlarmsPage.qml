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

AppPage {
    id: alarmsPage

    property Item __alarmItem: null
    property string alarmToDeleteId: "NULL"   // For save/restore support.

    pageTitle: qsTr("Alarms")

    actionMenuModel: [qsTr("New alarm")]
    actionMenuPayload: [1]

    SaveRestoreState {
        id: alarmsPageState
        onSaveRequired: {
            setValue("alarmsPage.showNewAlarmComponent", __alarmItem == null ? 1 : 0)
            sync()
        }
    }

    Component.onCompleted: {
        if (alarmsPageState.restoreRequired) {
            if (alarmsPageState.value("alarmsPage.showNewAlarmComponent", 0)) {
                __alarmItem = newAlarmComponent.createObject(alarmsPage);
                __alarmItem.show();
            } else if(value("alarmsPage."), 0) {
                confirmDelete.id = id;
                confirmDelete.show();
            }
        }
    }

    onActionMenuTriggered: {
        if (selectedItem == 1) {
            __alarmItem = newAlarmComponent.createObject(alarmsPage);
            __alarmItem.show();
        }
    }

    Image {
        anchors.fill: parent
        source: "image://themedimage/widgets/common/backgrounds/global-background-texture"
        clip: true

        BorderImage {
            id: panel
            anchors.fill: parent
            anchors.topMargin: 8
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.bottomMargin: 5
            source: "image://themedimage/widgets/apps/media/content-background"
            border.left:   8
            border.top:    8
            border.bottom: 8
            border.right:  8
            ClockListModel {
                id: clockListModel
                type: ClockListModel.ListofAlarms
            }

            ListView {
                id: listview
                anchors.fill: parent
                anchors.topMargin: (window.isLandscape ? 5 : 2)
                anchors.leftMargin: (window.isLandscape ? 2 : 5)
                anchors.rightMargin: (window.isLandscape ? 2 : 5)
                anchors.bottomMargin: (window.isLandscape ? 5 : 2)
                spacing: 2
                orientation: window.isLandscape ? ListView.Horizontal : ListView.Vertical
                onOrientationChanged: {
                    // maintain place in listview
                    var tmp = contentX;
                    contentX = contentY;
                    contentY = tmp;
                }
                clip: true
                interactive: window.isLandscape ? (width < contentWidth) : (height < contentHeight)

                model: clockListModel

                //spacers to create illusion of 10px border at ends
                header: Item { width: 10; height: 10 }
                footer: Item { width: 10; height: 10 }

                delegate: AlarmTile { }
            }
        }
    }

    Component {
        id: newAlarmComponent
        ModalDialog {
            width: 540 + 10
            height: 375 + 150
            title: qsTr("Add new alarm")
            acceptButtonText: qsTr("Save")
            cancelButtonText: qsTr("Cancel")
            content: AlarmSettings {
                id: alarmSettings
                anchors.fill: parent
                anchors { topMargin: 20; bottomMargin: 20; leftMargin: 40; rightMargin: 40 }
            }
            onAccepted: {
                clockListModel.addAlarm(alarmSettings.a_name,
                                        alarmSettings.a_days,
                                        alarmSettings.a_soundtype,
                                        alarmSettings.a_soundtype == 0 ? alarmSettings.a_soundname : alarmSettings.a_songname,
                                        alarmSettings.a_soundtype == 0 ? alarmSettings.a_sounduri : alarmSettings.a_songuri,
                                        alarmSettings.a_snooze,
                                        true,
                                        alarmSettings.a_hour,
                                        alarmSettings.a_minute);
                __alarmItem.destroy();
            }
        }
    }

    function deleteAlarm(id) {
        confirmDelete.alarmId = id;
        confirmDelete.show();
    }

    ModalMessageBox {
        id: confirmDelete
        property string alarmId

        width: 400
        height: 250
        title: qsTr("Delete alarm")
        text: qsTr("Are you sure you want to delete?")
        acceptButtonText: qsTr("Delete")
        cancelButtonText: qsTr("Cancel")
        acceptButtonImage: "image://themedimage/widgets/common/button/button-negative"
        acceptButtonImagePressed: "image://themedimage/widgets/common/button/button-negative-pressed"
        onAccepted: clockListModel.destroyItemByID(alarmId)
    }
}
