/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1
import MeeGo.Media 0.1
import MeeGo.App.Clocks 0.1
import "strings.js" as Strings

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
            if (clockListModel.count >= 20) {
                toomanyAlarmsDialog.show();
            } else {
                __alarmItem = newAlarmComponent.createObject(alarmsPage);
                __alarmItem.show();
            }
        }
    }

    Image {
        anchors.fill: parent
        source: "image://themedimage/widgets/common/backgrounds/global-background-texture"
        clip: true

        Item {
            id: panelArea
            anchors.horizontalCenter: parent.horizontalCenter
            width: {
                if(listview.count == 0) {
                    return parent.width
                } else if (window.isLandscape) {
                    return  Math.min(listview.totalWidth + panel.anchors.leftMargin + panel.anchors.rightMargin, parent.width)
                } else {
                    return  parent.width
                }
            }
            height: {
                if(listview.count == 0) {
                    return parent.height
                } else if (window.isLandscape) {
                    return parent.height
                } else {
                    return Math.min(listview.totalHeight + panel.anchors.leftMargin + panel.anchors.rightMargin, parent.height)
                }
            }
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
            NoContent {
                anchors.fill: parent
                visible: !listview.visible
                title: Strings.string02
                button1Text: Strings.string03
                onButton1Clicked: {
                    __alarmItem = newAlarmComponent.createObject(alarmsPage);
                    __alarmItem.show();
                }
            }

            ListView {
                id: listview
                visible: count > 0
                property int listPadding: 2
                property int totalWidth: contentWidth + 2*listPadding + 2*2
                property int totalHeight: contentHeight + 2*listPadding + 2 + 5
                anchors.fill: parent
                anchors.topMargin: (window.isLandscape ? 5 : 2)
                anchors.leftMargin: (window.isLandscape ? 2 : 5)
                anchors.rightMargin: (window.isLandscape ? 2 : 5)
                anchors.bottomMargin: (window.isLandscape ? 8 : 5)
                orientation: window.isLandscape ? ListView.Horizontal : ListView.Vertical
                onOrientationChanged: {
                    // maintain place in listview
                    var tmp = contentX;
                    contentX = contentY;
                    contentY = tmp;
                }
                clip: true
                interactive: window.isLandscape ? (width < (contentWidth + 2*listview.listPadding) ) : (height < (contentHeight + 2*listview.listPadding))

                model: clockListModel

                onCountChanged: {
                    //work-around issue where contentWidth/contentHeight is not changed after last alarm is removed
                    if(count == 0) {
                        if(window.isLandscape) {
                            contentWidth = 10;
                        } else {
                            contentHeight = 10;
                        }
                    }
                }

                //spacers to create illusion of 10px border at ends
                header: Item { width: listview.listPadding; height: listview.listPadding }
                footer: Item { width: listview.listPadding; height: listview.listPadding }

                delegate: AlarmTile { }
            }
        }
        }
    }

    Component {
        id: newAlarmComponent
        ModalDialog {
            width: 550
            height: 600
            title: qsTr("Add new alarm")
            acceptButtonText: qsTr("Save")
            cancelButtonText: qsTr("Cancel")
            content: AlarmSettings {
                id: alarmSettings
                anchors.fill: parent
                anchors { topMargin: 0; bottomMargin: 20; leftMargin: 40; rightMargin: 40 }
            }
            onAccepted: {
		if (!alarmSettings.a_name) {
			showAlert("Error", Strings.string05);
		} else if (alarmSettings.a_days == 0) {
			showAlert("Error", Strings.string06);
		} else {
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
    }

    function deleteAlarm(id) {
        confirmDelete.alarmId = id;
        confirmDelete.show();
    }

    function showAlert(title, message) {
	alertDialog.title = title;
        alertDialog.text = message;
        alertDialog.show();
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

    ModalMessageBox {
        id: alertDialog
        width: 400
        height: 250
        acceptButtonText: qsTr("OK")
	showCancelButton: false
        acceptButtonImage: "image://themedimage/widgets/common/button/button-negative"
        acceptButtonImagePressed: "image://themedimage/widgets/common/button/button-negative-pressed"
        onAccepted: __alarmItem.show()
    }

    ModalMessageBox {
        id: toomanyAlarmsDialog
        property string city
        width: 400
        height: 250
        title: qsTr("Error")
        text: Strings.string04.arg(20)
        showAcceptButton: false
        cancelButtonText: qsTr("Cancel")
    }

}
