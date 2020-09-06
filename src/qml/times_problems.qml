import QtQuick 2.6
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import org.julialang 1.0

ApplicationWindow {
  id: appRoot
  title: "Times Problems"
  width: Screen.desktopAvailableWidth*0.8
  height: Screen.desktopAvailableWidth*0.8/φ
  visible: true
  flags: lockedwindow ? Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint : Qt.Window

  property double fontSize: 0.35*questionBar.height

  function submit() {
    problem.answer = answer.text;
    answer.text = "";
    problem.answer = ""; // Workaround for setting the same value twice in a row
  }

  ColumnLayout {
    spacing: 6
    anchors.fill: parent

    RowLayout {
      id: questionBar
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignCenter
      Layout.topMargin: 5
      Layout.preferredHeight: appRoot.height*(1-1/φ)

      Text {
        id: questionText
        text: problem.question + " = "
        font.pixelSize: appRoot.fontSize
      }

      TextField {
          id: answer
          Layout.preferredWidth: 0.25*appRoot.width
          Layout.preferredHeight: 0.5*appRoot.height*(1-1/φ)
          font.pixelSize: appRoot.fontSize
          horizontalAlignment: TextInput.AlignHCenter
          validator: IntValidator {}
          focus: true
          onAccepted: submit();
      }

      Button {
        Layout.preferredWidth: 0.15*appRoot.width
        Layout.preferredHeight: answer.height
        text: "OK"
        onClicked: submit();
        enabled: answer.acceptableInput
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
          font.pixelSize: appRoot.fontSize/2
        }
        ProgressBar {
          id: progress
          Layout.alignment: Qt.AlignCenter
          Layout.preferredHeight: 0.1*questionBar.height
          Layout.preferredWidth: 0.9*questionBar.width
          value: problem.numcorrect / problem.maxnumcorrect
        }
      }

      MouseArea {
        id: clickArea
        anchors.fill: parent
      }

      states: [
        State {
            name: "STARTUP"
            PropertyChanges { target: feedback; color: "white"}
            PropertyChanges { target: statusText; text: qsTr("Please solve the problem") }
        },
        State {
            name: "CORRECT"
            PropertyChanges { target: feedback; color: "green"}
            PropertyChanges { target: statusText; text: "🎉 " + qsTr("Correct, try the next one!")  + " 🎉" }
        },
        State {
            name: "ERROR"
            PropertyChanges { target: feedback; color: "red"}
            PropertyChanges { target: statusText; text: qsTr("Wrong answer, please try again.") }
        },
        State {
            name: "FINISHED"
            PropertyChanges { target: feedback; color: "blue" }
            PropertyChanges { target: statusText; text: "🎉 " + qsTr("All done! Click to close.") + " 🎉" }
            PropertyChanges {
              target: questionBar
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
