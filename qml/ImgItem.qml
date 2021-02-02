/*  ImgItem.qml */
import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3

Rectangle {
        id: root
        signal clicked
        clip: true
        radius: units.gu(0.5)
        border.width: units.gu(0.1)
        border.color: "#77777720"
        width: parent.width
        height: units.gu(8)
    
    property string adress: ""
    property alias image: img.name
    Icon {
      id: img
      width: units.gu(8)
      height: units.gu(6)
      name: "folder"
      anchors{
          margins: units.gu(1)
          top: parent.top
          left: parent.left
        }
    }
    property alias text: label.text
    Text {
        id: label
        font.pixelSize: units.gu(2)
        anchors{
          top: parent.top
          topMargin: units.gu(2)
          left: img.right
          right: parent.right
        }
        rightPadding: units.gu(1)
        wrapMode : Text.WordWrap
        verticalAlignment: Text.AlignVCenter
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: parent.clicked()
    }
}