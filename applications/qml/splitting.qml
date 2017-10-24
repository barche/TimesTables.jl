import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import QtQuick.Controls.Styles 1.4
import org.julialang 1.0

ApplicationWindow {
  id: appRoot
  title: "Splitting"
  width: Screen.desktopAvailableHeight*0.8/φ
  height: Screen.desktopAvailableHeight*0.8
  visible: true

  SystemPalette { id: pal; colorGroup: SystemPalette.Active }

  function submit() {
    Julia.check_answer(problem, answer.text);
    problem.update();
    answer.text = "";
  }

  ColumnLayout {
    spacing: 6
    anchors.fill: parent

    Canvas {
      id: canvas
      Layout.fillWidth: true
      height: appRoot.width
      contextType: "2d"

      property double w: 130
      
      onPaint: {
          context.fillStyle = Qt.rgba(0.0,0.2,1.0);
          context.fillRect(0, 0, width, height);
          
          context.strokeStyle = Qt.rgba(0.0,0.6,0.0);
          context.lineWidth = 3;
          context.moveTo(width/2,7+w);
          context.lineTo(10+w/2,height-7-w);
          context.stroke();

          context.moveTo(width/2,7+w);
          context.lineTo(width-10-w/2,height-7-w);
          context.stroke();
      }

      Rectangle {
        width: parent.w
        height: parent.w
        x: parent.width/2 - parent.w/2
        y: 10
        color: "yellow"

        Text {
          anchors.centerIn: parent
          text: problem.question.a
          font.pixelSize: 0.7*parent.height
        }
      }

      Rectangle {
        width: parent.w
        height: parent.w
        x: 10
        y: parent.height-10-parent.w
        color: "yellow"
        
        Text {
          anchors.centerIn: parent
          text: problem.question.b
          font.pixelSize: 0.7*parent.height
        }
      }

      TextField {
        id: answer
        width: parent.w
        height: parent.w
        x: parent.height-10-parent.w
        y: parent.height-10-parent.w
      
        style: TextFieldStyle {
          textColor: "black"
          background: Rectangle {
            color: "green"
          }
        }

        font.pixelSize: 0.7*parent.w
        horizontalAlignment: TextInput.AlignHCenter
        validator: IntValidator {}
        focus: true
        onAccepted: submit();
      }
    }

    Rectangle {
      id: feedback
      Layout.fillWidth: true
      Layout.fillHeight: true

      state: problem.state

      ColumnLayout {
        spacing: 6
        anchors.fill: parent
        Text {
          id: statusText
          Layout.alignment: Qt.AlignCenter
          font.pixelSize: 0.7*canvas.w
        }
        ProgressBar {
          id: progress
          Layout.alignment: Qt.AlignCenter
          value: problem.num_correct / max_correct
        }
      }

      MouseArea {
        id: clickArea
        anchors.fill: parent
      }

      states: [
        State {
            name: "STARTUP"
            PropertyChanges { target: feedback; color: "yellow"}
            PropertyChanges { target: statusText; text: "🤔" }
        },
        State {
            name: "CORRECT"
            PropertyChanges { target: feedback; color: "green"}
            PropertyChanges { target: statusText; text: "😄" }
        },
        State {
            name: "ERROR"
            PropertyChanges { target: feedback; color: "red"}
            PropertyChanges { target: statusText; text: "😭" }
        },
        State {
            name: "FINISHED"
            PropertyChanges { target: feedback; color: "blue" }
            PropertyChanges { target: statusText; text: "🎉" }
            PropertyChanges {
              target: canvas
              enabled: false
              visible: false
            }
            PropertyChanges { target: progress; visible: false }
            PropertyChanges { target: clickArea; onClicked: Qt.quit() }
        }
      ]
    }
  }
}
