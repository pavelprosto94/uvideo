/*  ImgItem.qml */
import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3

Rectangle {
        id: root
        signal clicked
        signal subclick
        signal subup
        signal subdown
        clip: true
        radius: units.gu(0.5)
        border.width: units.gu(0.1)
        color: theme.palette.normal.background
        border.color: theme.palette.normal.base
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
          left: itemmenu.right
        }
    }
    property alias text: label.text
    Text {
        id: label
        font.pixelSize: units.gu(2)
        clip: true
        anchors{
          top: parent.top
          topMargin: units.gu(2)
          left: img.right
          right: parent.right
          rightMargin: units.gu(1)
        }
        wrapMode : Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        color: theme.palette.normal.backgroundText
    }
    MouseArea {
        id: mouseArea
        anchors{
      top: parent.top
      bottom: parent.bottom
      left: itemmenu.right
      right: parent.right
      leftMargin: units.gu(2)
      }
        onClicked: {
          if (menu_width==0){
            if (!itemmenu.hover)
          {parent.clicked()}
          else
          {
            itemmenu.hover=false
          }
          }
        }

        hoverEnabled: true
      property real oldpos: -1
      property real stposx: -1
      property real stposy: -1
      onPressed: {
        oldpos=mouse.x
        stposx=mouse.x
        stposy=mouse.y
        if (menu_width>units.gu(2))
        {itemmenu.hover=true}
      }
      onPositionChanged: {
        if (oldpos>0){
          var xdist=stposx-mouse.x
          if (xdist<0) {xdist=mouse.x-stposx}
           var ydist=stposy-mouse.y
          if (ydist<0) {ydist=mouse.y-stposy}
          if (ydist<xdist && xdist>units.gu(2))
          {
          root.subup()
        var newpos=oldpos-mouse.x 
        newpos=menu_width-newpos
        oldpos=mouse.x
        if (newpos>=0 && newpos<=units.gu(7))
        {menu_width=newpos
          imageM=-newpos
        }}}
      }
      onReleased: {
        oldpos=0
        root.subdown()
        if (menu_width>units.gu(3) && menu_width!=units.gu(7)) 
        {menu_width=units.gu(7)
         imageM= -menu_width
        }
        if (menu_width<units.gu(3) && menu_width!=0)
        {menu_width=units.gu(0)
          imageM= -menu_width
        }
      }
    }

    property real menu_width: 0
    NumberAnimation on menu_width {
          id: hidemenu
          alwaysRunToEnd: true
          from: menu_width; to: 0;
          }
    Rectangle {
        id: itemmenu
        property bool hover: false
        clip: true
        border.width: units.gu(0.1)
        border.color: theme.palette.normal.base
        width: menu_width 
        color: theme.palette.normal.base
        anchors{
          top:parent.top
          bottom: parent.bottom
          left: parent.left
        }
        Image {
          source: "../src/img/grad.png"
          fillMode: Image.TileVertically
          anchors.fill: parent
        }
        Image {
          source: "../src/img/noise-texture.png"
          fillMode: Image.Tile
          anchors.fill: parent
        }
        
        Image {
          id: whatsapp
          property int animopa
          source: "../src/img/remove-128.png"
          width: units.gu(5)
          height: units.gu(5)
          opacity: 0.5+animopa/40
          fillMode: Image.PreserveAspectCrop
          anchors{
            top: itemmenu.top
            topMargin: units.gu(1)
            left: itemmenu.left
            leftMargin: units.gu(1.1)
          }
          MouseArea {
          id: whatmouse
          hoverEnabled: true
          anchors.fill: parent
          onClicked: root.subclick()
          }
          NumberAnimation on animopa {
          id: anim1w
          alwaysRunToEnd: true
          running: whatmouse.pressed
          from: 0; to: 20;
          onRunningChanged: {
            if (!running) {
            anim2w.start()
            }
          }
          }
          NumberAnimation on animopa {
          id: anim2w
          alwaysRunToEnd: true
          from: 20; to: 0;
          }
        }
      }
}