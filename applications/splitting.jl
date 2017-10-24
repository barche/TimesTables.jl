using QML
using TimesTables

const max_correct = 3

struct CustomSplitGen
  defgen::TimesTables.DefaultOpGenerator
end

const generator = CustomSplitGen(TimesTables.DefaultOpGenerator(0,10,0,5))

TimesTables.generate(g::CustomSplitGen) = TimesTables.generate(Subtraction, generator.defgen)

"""
Keep track of the current question and the answer
"""
mutable struct Problem
  question::Subtraction
  answer::Int
  num_correct::Int32
  state::String
end

# The current problem
const problem = Problem(generate(generator), 0, 0, "STARTUP")

function check_answer(p::Problem, answer::String)
  p.answer = parse(Int, answer)
  if check(p.question, p.answer)
    p.num_correct += 1
    if p.num_correct == max_correct
      p.state = "FINISHED"
    else
      p.state = "CORRECT"
      p.question = generate(generator)
    end
  else
    p.num_correct = 0
    p.state = "ERROR"
  end
end

@qmlfunction check_answer generate
qmlfile = joinpath(dirname(@__FILE__), "qml", "splitting.qml")

if @qmlapp qmlfile φ problem max_correct
  exec()
end
