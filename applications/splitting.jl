using QML
using TimesTables

# Sound stuff
import PortAudio
import LibSndFile

const cheer = LibSndFile.load("sounds/cheer.wav")
const ohno = LibSndFile.load("sounds/ohno.wav")
const woohoo = LibSndFile.load("sounds/woohoo.wav")

const audio_out = PortAudio.PortAudioStream("Built-in Output", 0, 2)

playsound(s) = PortAudio.write(audio_out, s)

const max_correct = 30

struct CustomSplitGen end

const generator = CustomSplitGen()

function TimesTables.generate(g::CustomSplitGen)
  a = rand([0,1,1,2,2,2,3,3,3,3,3,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5])
  b = rand(0:a)
  return Subtraction(a, b)
end

"""
Keep track of the current question and the answer
"""
mutable struct Problem
  question::Subtraction
  answer::Int
  num_correct::Int32
  state::String
  happyface::String
end

function happy()
  faces = ["😄", "😍", "😸", "😻"]
  return rand(faces)
end

# The current problem
const problem = Problem(generate(generator), 0, 0, "STARTUP", happy())

function playsound()
  if problem.state == "CORRECT"
    playsound(woohoo)
  end
  if problem.state == "FINISHED"
    playsound(cheer)
  end
  if problem.state == "ERROR"
    playsound(ohno)
  end
end

function check_answer(p::Problem, answer::String)
  p.answer = parse(Int, answer)
  if check(p.question, p.answer)
    p.num_correct += 1
    if p.num_correct == max_correct
      p.state = "FINISHED"
    else
      p.state = "CORRECT"
      p.happyface = happy()
      p.question = generate(generator)
    end
  else
    p.num_correct = 0
    p.state = "ERROR"
  end
end

@qmlfunction check_answer generate playsound happy
qmlfile = joinpath(dirname(@__FILE__), "qml", "splitting.qml")

if @qmlapp qmlfile φ problem max_correct
  exec()
end
