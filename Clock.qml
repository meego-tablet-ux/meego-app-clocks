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
    id: clock
    width: backgroundDay.width
    height: backgroundDay.height

    property variant theDate: new Date
    property alias clockWidth: backgroundDay.width
    property alias clockHeight: backgroundDay.height
    property string cityname
    property int gmt: 0
    property int hours: gmt ? ((theDate.getUTCHours() + gmt + 24)%24) : theDate.getUTCHours();
    property int minutes: gmt ? theDate.getUTCMinutes() + ((clock.gmt % 1) * 60) : theDate.getMinutes();
    property int seconds: theDate.getUTCSeconds()
    property string timeString: Code.formatTime(hours, minutes);
    property bool landscape: true
    property bool minimal: false
    property bool localzone: false

    function timeChanged() {
        var date = new Date;
        hours = gmt ? ((date.getUTCHours() + gmt + 24)%24) : date.getUTCHours();
        minutes = gmt ? date.getUTCMinutes() + ((clock.gmt % 1) * 60) : date.getMinutes();
        seconds = date.getUTCSeconds();
        timeString = Code.formatTime(hours, minutes);
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: clock.timeChanged()
    }

    Item {
        id: clockText1
        width: backgroundDay.width
        height: 60
        anchors.right: (landscape)?undefined:backgroundDay.left
        anchors.verticalCenter: (landscape)?undefined:backgroundDay.verticalCenter
        anchors.bottom: (landscape)?backgroundDay.top:undefined
        anchors.horizontalCenter: (landscape)?backgroundDay.horizontalCenter:undefined
        visible: minimal == false
        Text {
            id: clockText1name
            width: parent.width
            anchors.top: clockText1.top
            anchors.left: (landscape)?undefined:clockText1.left
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: cityname
            color: (localzone)?theme_fontColorHighlight:theme_fontColorNormal
            font.pixelSize: theme_fontPixelSizeLarge
        }
        Text {
            id: clockText1gmt
            width: parent.width
            anchors.top: clockText1name.bottom
            anchors.left: (landscape)?undefined:clockText1.left
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("(GMT %1)").arg(((gmt < 0) ? "" : "+") + gmt)
            color: (localzone)?theme_fontColorHighlight:theme_fontColorNormal
            font.pixelSize: theme_fontPixelSizeLarge
        }
    }

    Item {
        id: clockText2
        width: backgroundDay.width
        height: 50
        anchors.left: (landscape)?undefined:backgroundDay.right
        anchors.verticalCenter: (landscape)?undefined:backgroundDay.verticalCenter
        anchors.top: (landscape)?backgroundDay.bottom:undefined
        anchors.horizontalCenter: (landscape)?backgroundDay.horizontalCenter:undefined
        visible: minimal == false
        Text {
            id: clockText1time
            width: parent.width
            height: parent.height
            anchors.top: clockText2.top
            anchors.left: (landscape)?undefined:clockText2.left
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: timeString
            color: (localzone)?theme_fontColorHighlight:theme_fontColorNormal
            font.pixelSize: theme_fontPixelSizeLarge
        }
    }

    Image {
        id: backgroundDay
        source: (landscape)?"image://theme/clock/bg_clock_day_face_l":"image://theme/clock/bg_clock_day_face_p"
        visible: Code.isDay(hours)
    }

    Image {
        id: backgroundNight
        height: backgroundDay.height
        width: backgroundDay.width
        source: (landscape)?"image://theme/clock/bg_clock_night_face_l":"image://theme/clock/bg_clock_night_face_p"
        visible: !Code.isDay(hours)
    }

    Image {
        id: hourhand
        x: (backgroundDay.width/2) - (width/2)
        y: scene.isLandscapeView()?
           ((backgroundDay.height/2) - height + 16):
           ((backgroundDay.height/2) - height + 16)
        source: (!Code.isDay(hours))?
                (scene.isLandscapeView()?"image://theme/clock/obj_clock_night_hour_hand_l":"image://theme/clock/obj_clock_night_hour_hand_p"):
                (scene.isLandscapeView()?"image://theme/clock/obj_clock_day_hour_hand_l":"image://theme/clock/obj_clock_day_hour_hand_p")
        smooth: true
        transform: Rotation {
            id: hourRotation
            origin.x: hourhand.width/2
            origin.y: scene.isLandscapeView()?
                    (hourhand.height - 16):
                    (hourhand.height - 16)
            angle: (clock.hours * 30) + (clock.minutes * 0.5)
        }
    }

    Image {
        id: minutehand
        x: (backgroundDay.width/2) - (width/2)
        y: scene.isLandscapeView()?
           ((backgroundDay.height/2) - height + 14):
           ((backgroundDay.height/2) - height + 14)
        source: (!Code.isDay(hours))?
                (scene.isLandscapeView()?"image://theme/clock/obj_clock_night_minute_hand_l":"image://theme/clock/obj_clock_night_minute_hand_p"):
                (scene.isLandscapeView()?"image://theme/clock/obj_clock_day_minute_hand_l":"image://theme/clock/obj_clock_day_minute_hand_p")
        smooth: true
        transform: Rotation {
            id: minuteRotation
            origin.x: minutehand.width/2
            origin.y: scene.isLandscapeView()?
                    (minutehand.height - 14):
                    (minutehand.height - 14)
            angle: clock.minutes * 6
        }
    }

    Image {
        id: secondhand
        x: (backgroundDay.width/2) - (width/2)
        y: scene.isLandscapeView()?
           ((backgroundDay.height/2) - height + 14):
           ((backgroundDay.height/2) - height + 14)
        source: scene.isLandscapeView()?"image://theme/clock/obj_clock_day_second_hand_l":"image://theme/clock/obj_clock_day_second_hand_p"
        smooth: true
        transform: Rotation {
            id: secondRotation
            origin.x: secondhand.width/2
            origin.y: scene.isLandscapeView()?
                    (secondhand.height - 14):
                    (secondhand.height - 14)
            angle: clock.seconds * 6
        }
    }

    Image {
        id: centerImage
        anchors.centerIn: backgroundDay
        source: (!Code.isDay(hours))?
                (scene.isLandscapeView()?"image://theme/clock/obj_clock_night_centre_cap_l":"image://theme/clock/obj_clock_night_centre_cap_p"):
                (scene.isLandscapeView()?"image://theme/clock/obj_clock_day_centre_cap_l":"image://theme/clock/obj_clock_day_centre_cap_p")
    }
}
