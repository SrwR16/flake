pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtCore

Item {
    id: root

    // Track if any popup is currently open
    property bool anyPopupOpen: false
    property bool shouldShowBar: false
    // Allow dynamic control of the hide delay (in milliseconds)
    property int barHideDelayMs: 1000

    // Timer for delayed bar hiding
    Timer {
        id: hideBarTimer
        interval: root.barHideDelayMs
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
            // Ensure the timer uses the latest delay value
            hideBarTimer.interval = root.barHideDelayMs
            hideBarTimer.restart()
        }
    }
}
