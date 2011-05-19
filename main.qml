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

Window {
    id: window

    // simplify orientation code
    property bool isLandscape: orientation == 1 || orientation == 3
    property bool isPortrait: orientation == 0 || orientation == 2

    showToolBarSearch: false

    bookMenuModel: [qsTr("Clocks"), qsTr("Alarms")]
    bookMenuPayload: [ clocksPage, alarmsPage ]
    Component { id: clocksPage; ClocksPage {} }
    Component { id: alarmsPage; AlarmsPage {} }
    Component.onCompleted: { switchBook(clocksPage) }
}
