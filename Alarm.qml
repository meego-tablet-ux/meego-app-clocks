/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

import "functions.js" as Code

Item {
    id: alarm
    width: backgroundDay.width
    height: backgroundDay.height

    property alias alarmWidth: backgroundDay.width
    property alias alarmHeight: backgroundDay.height
    property string alarmName: ""
    property int alarmDays: 0
    property string alarmSoundfile: ""
    property string alarmSoundfileuri: ""
    property int alarmSnoozeval: 0
    property bool alarmActive: false
    property int alarmHour: 0
    property int alarmMinute: 0
    property bool landscape: true
    property bool minimal: false
    property variant onoroff: [qsTr("On"), qsTr("Off")]

    signal triggered(bool a_active)

    Item {
        id: alarmText1
        width: backgroundDay.width
        height: 80
        anchors.right: (landscape)?undefined:backgroundDay.left
        anchors.verticalCenter: (landscape)?undefined:backgroundDay.verticalCenter
        anchors.bottom: (landscape)?backgroundDay.top:undefined
        anchors.horizontalCenter: (landscape)?backgroundDay.horizontalCenter:undefined
        visible: minimal == false
        Text {
            id: alarmText1time
            width: parent.width
            anchors.top: alarmText1.top
            anchors.left: (landscape)?undefined:alarmText1.left
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: Code.formatTime(alarmHour, alarmMinute)
            color: theme_fontColorNormal
            font.pixelSize: theme_fontPixelSizeLarge
        }
        Text {
            id: alarmText1name
            width: parent.width
            anchors.top: alarmText1time.bottom
            anchors.left: (landscape)?undefined:alarmText1.left
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: alarmName
            color: theme_fontColorNormal
            font.pixelSize: theme_fontPixelSizeLarge
        }
        Text {
            id: alarmText1days
            width: parent.width
            anchors.top: alarmText1name.bottom
            anchors.left: (landscape)?undefined:alarmText1.left
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: Code.daysFriendly(alarmDays)
            color: theme_fontColorNormal
            font.pixelSize: theme_fontPixelSizeNormal
        }
    }

    Item {
        id: alarmText2
        width: backgroundDay.width
        height: 80
        anchors.left: (landscape)?undefined:backgroundDay.right
        anchors.verticalCenter: (landscape)?undefined:backgroundDay.verticalCenter
        anchors.top: (landscape)?backgroundDay.bottom:undefined
        anchors.horizontalCenter: (landscape)?backgroundDay.horizontalCenter:undefined
        visible: minimal == false
        Image {
            id: onoffswitch
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "image://theme/clock/bg_switch_bg"
            Repeater {
                model: 2
                Item {
                    x: index * onoffswitch.width/2
                    anchors.top: parent.top
                    width: onoffswitch.width/2
                    height: parent.height
                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: onoroff[index]
                        font.pixelSize: theme_fontPixelSizeLarge
                        color: theme_buttonFontColor
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(alarmActive != !index)
                            {
                                alarmActive = !index;
                                alarm.triggered(alarmActive);
                            }
                        }
                    }
                }
            }
            Image {
                id: btnimage
                x: (alarmActive?0:1) * onoffswitch.width/2
                anchors.top: parent.top
                width: onoffswitch.width/2
                height: parent.height
                source: (alarmActive)?"image://theme/clock/btn_switch_on":"image://theme/clock/btn_switch_off"
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: onoroff[(alarmActive?0:1)]
                    font.pixelSize: theme_fontPixelSizeLarge
                    color: theme_buttonFontColor
                }
            }
        }
    }

    Image {
        id: backgroundDay
        source: (landscape)?"image://theme/clock/bg_alarm_day_face_l":"image://theme/clock/bg_alarm_day_face_p"
        visible: Code.isDay(alarmHour)
    }

    Image {
        id: backgroundNight
        height: backgroundDay.height
        width: backgroundDay.width
        source: (landscape)?"image://theme/clock/bg_alarm_night_face_l":"image://theme/clock/bg_alarm_night_face_p"
        visible: !Code.isDay(alarmHour)
    }

    Image {
        id: hourhand
        x: (backgroundDay.width/2) - (width/2)
        y: scene.isLandscapeView()?
           ((backgroundDay.height/2) - height + 14):
           ((backgroundDay.height/2) - height + 12)
        source: (!Code.isDay(alarmHour))?
                (scene.isLandscapeView()?"image://theme/clock/obj_alarm_edit_night_hour_hand_p":"image://theme/clock/obj_alarm_edit_night_hour_hand_p"):
                (scene.isLandscapeView()?"image://theme/clock/obj_alarm_edit_day_hour_hand_p":"image://theme/clock/obj_alarm_edit_day_hour_hand_p")
        smooth: true
        transform: Rotation {
            id: hourRotation
            origin.x: hourhand.width/2
            origin.y: scene.isLandscapeView()?
                    (hourhand.height - 14):
                    (hourhand.height - 12)
            angle: (alarm.alarmHour * 30) + (alarm.alarmMinute * 0.5)
            Behavior on angle {
                RotationAnimation{ direction: RotationAnimation.Shortest }
            }
        }
    }

    Image {
        id: minutehand
        x: (backgroundDay.width/2) - (width/2)
        y: scene.isLandscapeView()?
           ((backgroundDay.height/2) - height + 14):
           ((backgroundDay.height/2) - height + 12)
        source: (!Code.isDay(alarmHour))?
                (scene.isLandscapeView()?"image://theme/clock/obj_alarm_night_minute_hand_l":"image://theme/clock/obj_alarm_night_minute_hand_p"):
                (scene.isLandscapeView()?"image://theme/clock/obj_alarm_day_minute_hand_l":"image://theme/clock/obj_alarm_day_minute_hand_p")
        smooth: true
        transform: Rotation {
            id: minuteRotation
            origin.x: minutehand.width/2
            origin.y: scene.isLandscapeView()?
                    (minutehand.height - 14):
                    (minutehand.height - 12)
            angle: alarm.alarmMinute * 6
            Behavior on angle {
                RotationAnimation{ direction: RotationAnimation.Shortest }
            }
        }
    }

    Image {
        id: centerImage
        anchors.centerIn: backgroundDay
        source: (!Code.isDay(alarmHour))?
                (scene.isLandscapeView()?"image://theme/clock/obj_alarm_night_cap_l":"image://theme/clock/obj_alarm_night_cap_p"):
                (scene.isLandscapeView()?"image://theme/clock/obj_alarm_day_cap_l":"image://theme/clock/obj_alarm_day_cap_p")
    }
}
