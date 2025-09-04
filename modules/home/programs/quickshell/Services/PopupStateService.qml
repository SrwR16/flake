pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtCore

Item {
    id: root

    // Track if any popup is currently open
    property bool anyPopupOpen: false
    property bool shouldShowBar: false

    // Timer for delayed bar hiding
    Timer {
        id: hideBarTimer
        interval: 3000
        onTriggered: {
            if (!anyPopupOpen) {
                shouldShowBar = false
            }
        }
    }

    // Functions to update popup state
    function setPopupOpen(open) {
        anyPopupOpen = open
        if (open) {
            shouldShowBar = true
            hideBarTimer.stop()
        } else {
            // Start the 5-second delay timer when popup closes
            hideBarTimer.restart()
        }
    }
}
