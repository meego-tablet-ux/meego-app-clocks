/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
import MeeGo.Media 0.1
import MeeGo.App.Clocks 0.1
import "functions.js" as Code

Item {
    id: container
    anchors.fill:parent

    property variant model: undefined
    property bool landscape: true

    property int itemHeight: 50
    property variant weekday: [
        "image://theme/clock/btn_Mo_up",
        "image://theme/clock/btn_Tu_up",
        "image://theme/clock/btn_We_up",
        "image://theme/clock/btn_Th_up",
        "image://theme/clock/btn_Fr_up",
        "image://theme/clock/btn_Sa_up",
        "image://theme/clock/btn_Su_up"
    ]
    property variant weekdayon: [
        "image://theme/clock/btn_Mo_dn",
        "image://theme/clock/btn_Tu_dn",
        "image://theme/clock/btn_We_dn",
        "image://theme/clock/btn_Th_dn",
        "image://theme/clock/btn_Fr_dn",
        "image://theme/clock/btn_Sa_dn",
        "image://theme/clock/btn_Su_dn"
    ]
    property variant onoroff: [qsTr("On"), qsTr("Off")]
    property variant soundtypeval: [qsTr("sound"), qsTr("track")]

    property string name: ""
    property int days: 0
    property int soundtype: 0
    property string soundfile: ""
    property string soundfileuri: ""
    property int snoozeval: 8
    property bool active: false
    property int hour: 12
    property int minute: 0
    property bool nameonline: false
    property bool soundonline: false

    signal triggered(string a_name, int a_days, int a_soundtype,
                     string a_soundname, string a_soundfile,
                     int a_snooze, bool a_active,
                     int a_hour, int a_minute)

    signal nuke()
    signal close()

    ListModel {
        id: snoozelist
        property bool ready: false
        property int idx: 1
        function init() {
            if(!ready)
            {
                clear();
                for(idx = 1; idx <= 30; idx++)
                    append({"num": idx});
                ready = true;
            }
        }
    }

    ListModel {
        id: defaultSounds

        ListElement {
            title: "Blurp"
            uri: "file:///usr/share/sounds/purple/alert.wav"
        }
        ListElement {
            title: "ChordUp"
            uri: "file:///usr/share/sounds/purple/login.wav"
        }
        ListElement {
            title: "ChordDown"
            uri: "file:///usr/share/sounds/purple/logout.wav"
        }
        ListElement {
            title: "ChimeUp"
            uri: "file:///usr/share/sounds/purple/receive.wav"
        }
        ListElement {
            title: "ChimeDown"
            uri: "file:///usr/share/sounds/purple/send.wav"
        }
    }

    function initialize(a_name, a_days, a_soundtype,
                        a_soundname, a_soundfile,
                        a_snooze, a_active,
                        a_hour, a_minute)
    {
        name = a_name;
        days = a_days;
        soundtype = ((a_soundtype < 2)?a_soundtype:0);
        soundbox.soundloader.sourceComponent = soundSelectorTracks;
        soundfile = a_soundname;
        soundfileuri = a_soundfile;
        snoozeval = a_snooze;
        active = a_active;
        hour = a_hour;
        minute = a_minute;
        hour = a_hour;
        nameonline = true;
        soundonline = true;
    }

    Component {
        id: highlighter
        Rectangle {
            color: "darkgray"
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
        function outsideClick()
        {
            timePicker.showing = false;
            snoozefield.activate = false;
            typefield.activate = false;
            soundfield.activate = false;
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                menu.outsideClick();
            }
        }

        Alarm {
            id: theclock
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.leftMargin: 20
            alarmHour: hour
            alarmMinute: minute
            minimal: true
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menu.outsideClick();
                }
            }
        }

        /* side of clock rect start */
        Item {
            id: clockrect
            anchors.top: theclock.top
            anchors.right: parent.right
            anchors.rightMargin: 20
            width: parent.width - theclock.width - 80
            height: theclock.height
            z: 10

            /* alarm time, switch rect start */
            Item {
                id: alarmtimerect
                anchors.top: parent.top
                anchors.right: parent.right
                width: parent.width
                height: parent.height/3
                z: 11
                Item {
                    id: alarmtime
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width/2
                    height: parent.height
                    Image {
                        id: timesel1
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/dropdown_white_60px_1"
                    }
                    Image {
                        id: timesel2
                        anchors.left: timesel1.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - timesel1.width - timesel3.width
                        source: "image://theme/dropdown_white_60px_2"
                    }
                    Image {
                        id: timesel3
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/dropdown_white_60px_3"
                    }
                    Text {
                        id: timeselection
                        anchors.fill: parent
                        anchors.margins: 10
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        text: Code.formatTime(hour, minute);
                        color: theme_fontColorNormal
                        font.pixelSize: theme_fontPixelSizeLarge
                    }
                    Item {
                        width: 240
                        height: 160
                        anchors.right: parent.right
                        anchors.top:  timeselection.bottom
                        TimePicker {
                            id: timePicker
                            property bool showing: false
                            property int xVal:0
                            property int yVal:0
                            onShowingChanged: {
                                if(showing)
                                {
                                    hours = hour;
                                    minutes = minute;
                                    timePicker.setValues();
                                    timePicker.show(xVal,yVal);
                                    //timePicker.visible = true;
                                }
                                else
                                {
                                    timePicker.visible = false;
                                }
                            }

                            hr24: true;
                            onTimeChanged: {
                                hour = hours;
                                minute = minutes;
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var map = mapToItem(scene.content,mouseX,mouseY);
                            timePicker.xVal = map.x;
                            timePicker.yVal = map.y;
                            timePicker.showing = !timePicker.showing;
                            clockrect.z = 10;
                            snoozerect.z = 0;
                            soundtypeselectrect.z = 0;
                            soundselectrect.z = 0;
                        }
                    }
                }

                Image {
                    id: onoffswitch
                    anchors.right: parent.right
                    anchors.top: parent.top
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
                                color: "white"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    menu.outsideClick();
                                    active = !index;
                                }
                            }
                        }
                    }
                    Image {
                        id: btnimage
                        x: (active?0:1) * onoffswitch.width/2
                        anchors.top: parent.top
                        width: onoffswitch.width/2
                        height: parent.height
                        source: (active)?"image://theme/clock/btn_switch_on":"image://theme/clock/btn_switch_off"
                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: onoroff[(active?0:1)]
                            font.pixelSize: theme_fontPixelSizeLarge
                            color: theme_buttonFontColor
                        }
                    }
                }
            }
            /* alarm time, switch rect end */

            Item {
                id: alarmnamerect
                anchors.top: alarmtimerect.bottom
                anchors.right: parent.right
                width: parent.width
                height: parent.height/3
                Image {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    source: "image://theme/clock/bg_alarm_edit_text_field"
                    TextInput {
                        id: textInputName
                        anchors.fill: parent
                        anchors.margins: 10
                        color: theme_fontColorNormal
                        font.pixelSize: theme_fontPixelSizeLarge
                        text: name
                        onTextChanged: {
                            name = displayText;
                            menu.outsideClick();
                            if(displayText.length > 0)
                                nameonline = true;
                            else
                                nameonline = false;
                        }
                    }
                }
            }

            /* day selection start */
            Item {
                id: daysrect
                anchors.top: alarmnamerect.bottom
                anchors.right: parent.right
                width: parent.width
                height: parent.height/3
                Image {
                    width: parent.width
                    source: (landscape)?"image://theme/clock/bg_date_select_l":"image://theme/clock/bg_date_select_p"
                    anchors.bottom: parent.bottom
                    Repeater {
                        model: 7
                        Item {
                            x: index * parent.width/7
                            width: parent.width/7
                            height: parent.height
                            anchors.top: parent.top
                            Image {
                                anchors.centerIn: parent
                                source: (days&(0x1 << index))?weekdayon[index]:weekday[index]
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        menu.outsideClick();
                                        if(days&(0x1 << index))
                                            days &= ~(0x1 << index)
                                        else
                                            days |= (0x1 << index)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            /* day selection end */
       }
       /* side of clock rect end */

        /* selection rect start */
        Item {
            id: selectrect
            anchors.top: clockrect.bottom
            anchors.right: clockrect.right
            width: clockrect.width
            height: clockrect.height

            /* snooze selection start */
            Item {
                id: snoozerect
                anchors.top: parent.top
                anchors.right: parent.right
                width: parent.width
                height: parent.height/3
                Text {
                    id: snoozetext
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: 100
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    text: qsTr("Snooze")
                    wrapMode: Text.WordWrap
                    color: theme_fontColorNormal
                    font.pixelSize: theme_fontPixelSizeLarge
                }
                Item {
                    id: snoozefield
                    anchors.left: snoozetext.right
                    anchors.top: parent.top
                    width: snoozerect.width - snoozetext.width
                    height: parent.height
                    property bool activate: false

                    Image {
                        id: snoozesel1
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/dropdown_white_60px_1"
                    }
                    Image {
                        id: snoozesel2
                        anchors.left: snoozesel1.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - snoozesel1.width - snoozesel3.width
                        source: "image://theme/dropdown_white_60px_2"
                    }
                    Image {
                        id: snoozesel3
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/dropdown_white_60px_3"
                    }
                    Text {
                        id: snoozefieldselection
                        anchors.fill: parent
                        anchors.margins: 10
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        text: (snoozeval == 1)?qsTr("1 Minute"):qsTr("%1 Minutes").arg(snoozeval)
                        color: theme_fontColorNormal
                        font.pixelSize: theme_fontPixelSizeLarge
                    }

                    Item {
                        id: snoozebox
                        anchors.bottom: snoozesel1.top
                        anchors.left: snoozefield.left
                        width: snoozefield.width
                        height: 0
                        opacity: 0

                        Image {
                            id: snoozebox1
                            anchors.top: parent.top
                            width: parent.width
                            opacity: parent.opacity
                            source: "image://theme/settings/pulldown_box_3"
                        }
                        Image {
                            id: snoozebox2
                            anchors.top: snoozebox1.bottom
                            width: parent.width
                            height: parent.height - snoozebox1.height - snoozebox3.height
                            opacity: parent.opacity
                            source: "image://theme/settings/pulldown_box_2"
                        }
                        Image {
                            id: snoozebox3
                            anchors.bottom: parent.bottom
                            width: parent.width
                            opacity: parent.opacity
                            source: "image://theme/settings/pulldown_box_1"
                        }

                        ListView {
                            id: snoozeListview
                            anchors.fill: parent
                            clip: true
                            model: snoozelist
                            highlight: highlighteroff
                            highlightMoveDuration: 1
                            delegate: Item {
                               id: snoozerect
                               height: 30
                               width: parent.width
                               Text {
                                   text: (num == 1)?qsTr("1 Minute"):qsTr("%1 Minutes").arg(num)
                                   anchors.fill: parent
                                   anchors.leftMargin: 10
                                   color: theme_fontColorNormal
                                   font.pixelSize: theme_fontPixelSizeLarge
                                   verticalAlignment: Text.AlignVCenter
                                   horizontalAlignment: Text.AlignLeft
                               }
                               MouseArea {
                                   anchors.fill: parent
                                   onClicked: {
                                       snoozeval = num;
                                       snoozefield.activate = false;
                                       snoozeListview.currentIndex = num-1;
                                   }
                               }
                            }
                        }
                        states: [
                            State {
                                name: "showmenu"
                                when: snoozefield.activate
                                PropertyChanges { target: snoozebox; height: 200; opacity:1 }
                            },
                            State {
                                name: "hidemenu"
                                when: !snoozefield.activate
                                PropertyChanges { target: snoozebox; height: 0; opacity:0 }
                            }
                        ]
                        transitions: [
                            Transition {
                                reversible: true
                                ParallelAnimation{
                                    PropertyAnimation { target: snoozebox; property: "height"; duration: 200 }
                                    PropertyAnimation { target: snoozebox; property: "opacity";  duration: 200 }
                                }
                            }
                        ]
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(!snoozelist.ready)
                                snoozelist.init();
//                                snoozeListview.currentIndex = snoozeval-1;
                            snoozerect.z = 10;
                            clockrect.z = 0;
                            soundtypeselectrect.z = 0;
                            soundselectrect.z = 0;
                            snoozefield.activate = !snoozefield.activate;
                        }
                    }
                }
            }
            /* snooze selection end */

            /* sound type selection start */
           Item {
                id: soundtypeselectrect
                anchors.top: snoozerect.bottom
                anchors.right: parent.right
                width: parent.width
                height: parent.height/3
                Text {
                    id: typetext
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: 100
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    text: qsTr("Type")
                    wrapMode: Text.WordWrap
                    color: theme_fontColorNormal
                    font.pixelSize: theme_fontPixelSizeLarge
                }
                Item {
                    id: typefield
                    anchors.left: typetext.right
                    anchors.top: parent.top
                    width: soundtypeselectrect.width - typetext.width
                    height: parent.height
                    property bool activate: false
                    Image {
                        id: typesel1
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/dropdown_white_60px_1"
                    }
                    Image {
                        id: typesel2
                        anchors.left: typesel1.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - typesel1.width - typesel3.width
                        source: "image://theme/dropdown_white_60px_2"
                    }
                    Image {
                        id: typesel3
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/dropdown_white_60px_3"
                    }
                    Text {
                        id: typefieldselection
                        anchors.fill: parent
                        anchors.margins: 10
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        text: soundtypeval[soundtype]
                        color: theme_fontColorNormal
                        font.pixelSize: theme_fontPixelSizeLarge
                    }
                    Item {
                        id: typebox
                        anchors.bottom: typesel2.top
                        anchors.left: typefield.left
                        width: typefield.width
                        height: 0
                        opacity: 0
                        Image {
                            id: typebox1
                            anchors.top: parent.top
                            width: parent.width
                            opacity: parent.opacity
                            source: "image://theme/settings/pulldown_box_3"
                        }
                        Image {
                            id: typebox2
                            anchors.top: typebox1.bottom
                            width: parent.width
                            height: parent.height - typebox1.height - typebox3.height
                            opacity: parent.opacity
                            source: "image://theme/settings/pulldown_box_2"
                        }
                        Image {
                            id: typebox3
                            anchors.bottom: parent.bottom
                            width: parent.width
                            opacity: parent.opacity
                            source: "image://theme/settings/pulldown_box_1"
                        }
                        Repeater {
                            model: 2
                            Text {
                                id: typefieldselector
                                y: index * (typebox.height/2)
                                anchors.top: typebox.top
                                anchors.left: typebox.left
                                anchors.leftMargin: 10
                                width: typebox.width
                                height: (typebox.height/2)
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                text: soundtypeval[index]
                                color: theme_fontColorNormal
                                font.pixelSize: theme_fontPixelSizeLarge
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if(index == 0)
                                            soundbox.soundloader.sourceComponent = soundSelectorSounds;
                                        else
                                            soundbox.soundloader.sourceComponent = soundSelectorTracks;
                                        if(soundtype != index)
                                        {
                                            soundfile = "";
                                            soundfileuri = "";
                                            soundonline = false;
                                        }
                                        soundtype = index;
                                        typefield.activate = false;
                                    }
                                }
                            }
                        }
                        states: [
                            State {
                                name: "showmenu"
                                when: typefield.activate
                                PropertyChanges { target: typebox; height: theme_fontPixelSizeLarge * 3; opacity:1 }
                            },
                            State {
                                name: "hidemenu"
                                when: !typefield.activate
                                PropertyChanges { target: typebox; height: 0; opacity:0 }
                            }
                        ]
                        transitions: [
                            Transition {
                                reversible: true
                                ParallelAnimation{
                                    PropertyAnimation { target: typebox; property: "height"; duration: 200 }
                                    PropertyAnimation { target: typebox; property: "opacity";  duration: 200 }
                                }
                            }
                        ]
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            clockrect.z = 0;
                            snoozerect.z = 0;
                            soundtypeselectrect.z = 10;
                            soundselectrect.z = 0;
                            parent.activate = !parent.activate;
                        }
                    }
                }
            }
            /* sound type selection end */

               /* sound selection start */
               Item {
                    id: soundselectrect
                    anchors.top: soundtypeselectrect.bottom
                    anchors.right: parent.right
                    width: parent.width
                    height: parent.height/3
                    Text {
                        id: soundtext
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 100
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("Sound")
                        wrapMode: Text.WordWrap
                        color: theme_fontColorNormal
                        font.pixelSize: theme_fontPixelSizeLarge
                    }
                    Item {
                        id: soundfield
                        anchors.left: soundtext.right
                        anchors.top: parent.top
                        width: soundselectrect.width - soundtext.width
                        height: parent.height
                        property bool activate: false
                        Image {
                            id: soundsel1
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            source: "image://theme/dropdown_white_60px_1"
                        }
                        Image {
                            id: soundsel2
                            anchors.left: soundsel1.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - soundsel1.width - soundsel3.width
                            source: "image://theme/dropdown_white_60px_2"
                        }
                        Image {
                            id: soundsel3
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            source: "image://theme/dropdown_white_60px_3"
                        }
                        Text {
                            id: soundfieldselection
                            anchors.fill: parent
                            anchors.margins: 10
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            text: soundfile
                            clip: true
                            color: theme_fontColorNormal
                            font.pixelSize: theme_fontPixelSizeLarge
                        }
                        Component {
                            id: soundSelectorTracks
                            ListView {
                                id: trackList
                                anchors.fill: parent
                                clip: true
                                model: MusicListModel {
                                    id: musicModel
                                    type: MusicListModel.ListofSongs
                                    limit: 0
                                    sort: MusicListModel.SortByTitle
                                }

                                highlight: highlighteroff
                                highlightMoveDuration: 1
                                delegate: Item {
                                   id: trackrect
                                   property string tracktitle: title
                                   height: 30
                                   width: parent.width
                                   Text {
                                       text: title
                                       anchors.left: trackrect.left
                                       anchors.leftMargin: 10
                                       anchors.verticalCenter: parent.verticalCenter
                                       color: theme_fontColorNormal
                                       font.pixelSize: theme_fontPixelSizeLarge
                                       verticalAlignment: Text.AlignVCenter
                                       horizontalAlignment: Text.AlignLeft
                                       wrapMode: Text.WordWrap
                                   }
                                   MouseArea {
                                       anchors.fill: parent
                                       onClicked: {
                                           soundfile = title;
                                           soundfileuri = uri;
                                           soundfield.activate = false;
                                           soundonline = true;
                                       }
                                   }
                                }
                            }
                        }
                        Component {
                            id: soundSelectorSounds
                            ListView {
                                id: soundList
                                anchors.fill: parent
                                clip: true
                                model: defaultSounds
                                highlight: highlighteroff
                                highlightMoveDuration: 1
                                delegate: Item {
                                   id: trackrect
                                   property string tracktitle: title
                                   height: 30
                                   width: parent.width
                                   Text {
                                       text: title
                                       anchors.left: trackrect.left
                                       anchors.leftMargin: 10
                                       anchors.verticalCenter: parent.verticalCenter
                                       color: theme_fontColorNormal
                                       font.pixelSize: theme_fontPixelSizeLarge
                                       verticalAlignment: Text.AlignVCenter
                                       horizontalAlignment: Text.AlignLeft
                                       wrapMode: Text.WordWrap
                                   }
                                   MouseArea {
                                       anchors.fill: parent
                                       onClicked: {
                                           soundfile = title;
                                           soundfileuri = uri;
                                           soundfield.activate = false;
                                           soundonline = true;
                                       }
                                   }
                                }
                            }
                        }
                        Item {
                            id: soundbox
                            anchors.bottom: soundsel2.top
                            anchors.left: soundfield.left
                            width: soundfield.width
                            height: 0
                            opacity: 0
                            property alias soundloader: loader
                            Image {
                                id: soundbox1
                                anchors.top: parent.top
                                width: parent.width
                                opacity: parent.opacity
                                source: "image://theme/settings/pulldown_box_3"
                            }
                            Image {
                                id: soundbox2
                                anchors.top: soundbox1.bottom
                                width: parent.width
                                height: parent.height - soundbox1.height - soundbox3.height
                                opacity: parent.opacity
                                source: "image://theme/settings/pulldown_box_2"
                            }
                            Image {
                                id: soundbox3
                                anchors.bottom: parent.bottom
                                width: parent.width
                                opacity: parent.opacity
                                source: "image://theme/settings/pulldown_box_1"
                            }
                            Loader {
                                id: loader
                                // set the initial state
                                sourceComponent:soundSelectorSounds
                                onStatusChanged: {
                                    if(status == Loader.Ready) {
                                        item.parent = loader.parent;
                                        item.anchors.centerIn = parent;
                                    }
                                }
                            }
                            states: [
                                State {
                                    name: "showmenu"
                                    when: soundfield.activate
                                    PropertyChanges { target: soundbox; height: Math.min((loader.item.count * 30), 200); opacity:1 }
                                },
                                State {
                                    name: "hidemenu"
                                    when: !soundfield.activate
                                    PropertyChanges { target: soundbox; height: 0; opacity:0 }
                                }
                            ]
                            transitions: [
                                Transition {
                                    reversible: true
                                    ParallelAnimation{
                                        PropertyAnimation { target: soundbox; property: "height"; duration: 200 }
                                        PropertyAnimation { target: soundbox; property: "opacity";  duration: 200 }
                                    }
                                }
                            ]
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                clockrect.z = 0;
                                snoozerect.z = 0;
                                soundtypeselectrect.z = 0;
                                soundselectrect.z = 10;
                                parent.activate = !parent.activate;
                            }
                        }
                    }
                }
               /* sound selection end */
            }
            /* selection rect end */

            Item {
                id: buttons
                height: menu.height - selectrect.height - clockrect.height
                width: parent.width
                anchors.bottom: parent.bottom
                Item {
                    width: parent.width - 40
                    height: parent.height
                    anchors.centerIn: parent
                    Button {
                        id: saveButton
                        height: 68
                        width: 208
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        active: (nameonline&&soundonline)
                        bgSourceUp: "image://theme/btn_blue_up"
                        bgSourceDn: "image://theme/btn_blue_dn"
                        title: qsTr("Save")
                        font.pixelSize: theme_fontPixelSizeLarge
                        color: theme_buttonFontColor
                        onClicked: {
                            if(nameonline&&soundonline)
                            {

                                container.triggered(name, days, soundtype, soundfile, soundfileuri, snoozeval, active, hour, minute);
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
                        title: qsTr("Cancel")
                        font.pixelSize: theme_fontPixelSizeLarge
                        color: theme_buttonFontColor
                        onClicked: {
                            container.close();
                        }
                    }
                }
            }
        }
    }

