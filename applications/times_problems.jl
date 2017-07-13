using QML
using TimesTables

const CONFIG_FILE = joinpath(dirname(@__FILE__), "times_problems_config.jl")

function generate_default_config()
  if !isfile(CONFIG_FILE)
    open(CONFIG_FILE, "w") do f
      write(f,
      """
      # Number of questions to answer correctly
      const max_correct = 3
      const enable_logging = true
      const logfile = joinpath(dirname(@__FILE__), "times_problems_log.txt")
      """      
      )
    end
  end
end

generate_default_config()
include(CONFIG_FILE)

"""
Keep track of the current question and the answer
"""
mutable struct Problem
  question::TimesOp
  answer::Int
  num_correct::Int32
  state::String
end

function writelog(s::String)
  if !enable_logging
    return
  end
  open(logfile, "a") do f
    write(f, "$(string(now()))\t$s\n")
  end
end

function writelog(p::Problem)
  writelog("$(p.question)\t$(p.answer)\t$(p.num_correct)")
end

# The current problem
const problem = Problem(generate(), 0, 0, "STARTUP")

function check_answer(p::Problem, answer::String)
  p.answer = parse(Int, answer)
  if check(p.question, p.answer)
    p.num_correct += 1;
    if p.num_correct == max_correct
      p.state = "FINISHED";
    else
      p.state = "CORRECT";
      p.question = generate()
    end
  else
    p.num_correct = 0;
    p.state = "ERROR";
  end
  writelog(p)
end

@qmlfunction check_answer generate
qmlfile = joinpath(dirname(@__FILE__), "qml", "times_problems.qml")

if @qmlapp qmlfile φ problem max_correct
  exec()
end

if problem.num_correct != max_correct
  writelog("PREMATURE EXIT")
end