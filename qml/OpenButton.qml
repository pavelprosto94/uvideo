/*  CalculatorButton.qml */
import QtQuick 2.7
import Ubuntu.Components 1.3

Rectangle {
    property alias text: label.text
    signal clicked

    color: "#43ac6a"
    radius: units.gu(1)
    border.width: units.gu(0.25)
    border.color: "white"
    height: units.gu(5)

    Label {
        id: label
        font.pixelSize: units.gu(2.5)
        anchors.centerIn: parent
        color: "#FFF"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: parent.clicked()
    }
}