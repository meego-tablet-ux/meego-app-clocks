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

    property int hours: 0
    property int minutes: 0
    property int seconds: 0
    property alias showSeconds: secondhand.visible

    Image {
        id: backgroundDay
        source: "image://themedimage/widgets/apps/clocks/clock-day"
        visible: Code.isDay(hours)
    }

    Image {
        id: backgroundNight
        height: backgroundDay.height
        width: backgroundDay.width
        source: "image://themedimage/widgets/apps/clocks/clock-night"
        visible: !Code.isDay(hours)
    }

    Image {
        id: hourhand
        x: (backgroundDay.width/2) - (width/2)
        y: ((backgroundDay.height/2) - height + 16)
        source: (Code.isDay(hours))?
                ("image://themedimage/widgets/apps/clocks/hand-day-hour"):
                ("image://themedimage/widgets/apps/clocks/hand-night-hour")
        smooth: true
        transform: Rotation {
            id: hourRotation
            origin.x: hourhand.width/2
            origin.y: (hourhand.height - 16)
            angle: (clock.hours * 30) + (clock.minutes * 0.5)
        }
    }

    Image {
        id: minutehand
        x: (backgroundDay.width/2) - (width/2)
        y: ((backgroundDay.height/2) - height + 14)
        source: (Code.isDay(hours))?
                ("image://themedimage/widgets/apps/clocks/hand-day-minute"):
                ("image://themedimage/widgets/apps/clocks/hand-night-minute")
        smooth: true
        transform: Rotation {
            id: minuteRotation
            origin.x: minutehand.width/2
            origin.y: (minutehand.height - 14)
            angle: clock.minutes * 6
        }
    }

    Image {
        id: secondhand
        x: (backgroundDay.width/2) - (width/2)
        y: ((backgroundDay.height/2) - height + 14)
        source: "image://themedimage/widgets/apps/clocks/hand-day-second"
        smooth: true
        transform: Rotation {
            id: secondRotation
            origin.x: secondhand.width/2
            origin.y: (secondhand.height - 14)
            angle: clock.seconds * 6
        }
    }

    Image {
        id: centerImage
        anchors.centerIn: backgroundDay
        source: "image://themedimage/widgets/apps/clocks/clock-hands-cap"
    }
}
