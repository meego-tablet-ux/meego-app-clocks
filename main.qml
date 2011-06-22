/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1
import MeeGo.Labs.Components 0.1 as Labs
import MeeGo.App.Clocks 0.1

Window {
    id: window

    // simplify orientation code
    property bool isLandscape: window.inLandscape || window.inInvertedLandscape
    property bool isPortrait: window.inPortrait || window.inInvertedPortrait

    showToolBarSearch: false

    bookMenuModel: [qsTr("Clocks"), qsTr("Alarms")]
    bookMenuPayload: [ clocksPage, alarmsPage ]
    Component { id: clocksPage; ClocksPage {} }
    Component { id: alarmsPage; AlarmsPage {} }

    property string indexValueName: "window.bookMenuSelectedIndex"  // i18n ok

    Labs.LocaleHelper {
        id: localeHelper
    }

    SaveRestoreState {
        id: windowState
        onSaveRequired: {
            // Save the book page we're on.
            setValue(indexValueName, window.bookMenuSelectedIndex)
            sync()
        }
    }

    Component.onCompleted: {
        // Load the page we were previously on if necessary.  Otherwise, load the clocks
        // page by default.

        var i = (windowState.restoreRequired ? windowState.value(indexValueName, 0) : 0)

        switchBook(bookMenuPayload[i])
    }

    onBookMenuSelectedIndexChanged: windowState.invalidate()
}
