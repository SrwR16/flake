pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtCore

Singleton {
    id: root

    // Track if any popup is currently open
    property bool anyPopupOpen: false

    // Functions to update popup state
    function setPopupOpen(open) {
        anyPopupOpen = open
    }
}
