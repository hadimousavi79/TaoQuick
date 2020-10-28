import QtQuick 2.9
import QtQuick.Controls 2.2
import ".."
import "../.."

ListView {
    id: cusTableView

    property real tableAreaX: CusTableConstant.column0Width
    signal pressed(real mouseX, real mouseY)
    signal released()
    signal positionChanged(real mouseX, real mouseY)
    signal doubleClicked(real mouseX, real mouseY)

    focus: true
    clip: true
    interactive: false
    snapMode: ListView.SnapToItem
    cacheBuffer: 12000
    property string noDataText: qsTr("No Data") + CusConfig.transString

    ScrollBar.horizontal: CusScrollBar {
        id: hbar
        opacity: cusTableView.contentWidth > cusTableView.width ? 1.0 : 0.0
        visible: opacity > 0
        active: visible
    }
    ScrollBar.vertical: CusScrollBar {
        id: vBar
        opacity: cusTableView.contentHeight > cusTableView.height ? 1.0 : 0.0
        visible: opacity > 0
        active: visible
    }
    CusShortCutKeys {
        id: tableKeys
        onSelectAllPressed: {
            cusTableView.model.selectAll()
        }
        onEscPressed: {
            cusTableView.model.deselectAll()
        }
    }
    Keys.enabled: true
    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_Control:
            tableKeys.ctrlPressed = true
            break
        case Qt.Key_Shift:
            tableKeys.shiftPressed = true
            break
        case Qt.Key_Escape:
            tableKeys.escPressed()
            break
        case Qt.Key_A:
            if (tableKeys.ctrlPressed) {
                tableKeys.selectAllPressed()
            }
            break
        default:
            break
        }
    }
    Keys.onReleased: {
        switch (event.key) {
        case Qt.Key_Control:
            tableKeys.ctrlPressed = false
            break
        case Qt.Key_Shift:
            tableKeys.shiftPressed = false
            break
        case Qt.Key_Escape:
            tableKeys.escReleased()
            break
        case Qt.Key_A:
            if (tableKeys.ctrlPressed) {
                tableKeys.selectAllReleased()
            }
            break
        default:
            break
        }
    }
    //Qt 5.9 not support, need 5.10 or grater
    //    Shortcut {
    //        sequence: StandardKey.SelectAll
    //        onActivated: {
    //            cusTableView.model.selectAll()
    //        }
    //    }
    //    Shortcut {
    //        sequence: StandardKey.Cancel
    //        onActivated: {
    //            cusTableView.model.deselectAll()
    //        }
    //    }
    highlightFollowsCurrentItem: false
    add: null
    addDisplaced: null
    displaced: null
    move: null
    moveDisplaced: null
    remove: null
    removeDisplaced: null
    populate: null
    BasicText {
        text: noDataText
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 10
        }
        visible: cusTableView.count <= 0
    }
    CusRectDraw {
        id: tableRectItem
        x: tableAreaX
        width: parent.width - x - CusConfig.scrollBarSize
        height: parent.height
        onPressed: {
            cusTableView.forceActiveFocus()
            cusTableView.pressed(mouseX + tableAreaX, mouseY)
        }
        onReleased: {
            cusTableView.released()
        }
        onPositionChanged: {
            cusTableView.positionChanged(mouseX + tableAreaX, mouseY)
        }
        onDoubleClicked: {
            cusTableView.doubleClicked(mouseX + tableAreaX, mouseY)
        }
        onWheelEvent: {
            //angle
            if (vBar.visible) {
                if (angle > 0) {
                    vBar.decrease()
                } else if (angle < 0) {
                    vBar.increase()
                }
            }
        }
    }
    function doPress(mouseX, mouseY) {
        var outRange = false
        if (cusTableView.contentHeight < cusTableView.height &&  mouseY > cusTableView.contentHeight)
        {
            outRange = true
        }
        var index = cusTableView.indexAt(mouseX, mouseY + cusTableView.contentY)
        cusTableView.model.doPress(index, tableKeys.shiftPressed,
                                   tableKeys.ctrlPressed, outRange)
    }
    function doRelease() {
        cusTableView.model.doRelease()
    }
    function doPositionChanged(mouseX, mouseY) {
        var outRange = false
        if (cusTableView.contentHeight < cusTableView.height &&  mouseY > cusTableView.contentHeight)
        {
            outRange = true
        }
        var index = cusTableView.indexAt(mouseX, mouseY + cusTableView.contentY)
        cusTableView.model.doMove(index, outRange)
    }
    function doUpdateInputGeo(input, mouseX, mouseY) {
        var item = cusTableView.itemAt(mouseX, mouseY + cusTableView.contentY)
        if (item) {
            var gPos = item.mapToGlobal(item.x, item.y)

            var lPos = input.mapFromGlobal(gPos.x, gPos.y)
            input.x = lPos.x
            input.y = lPos.y
            input.width = item.width
            input.height = item.height
        }
    }
}
