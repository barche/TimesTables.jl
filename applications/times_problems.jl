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
      # Minimal number in a times computation
      const times_min = 1
      # Maximum number in a times computation
      const times_max = 10
      # Minimum of the subtraction result
      const subtraction_min = 0
      # Maximum sum of operands for addition and substraction
      const addition_max = 100
      const enable_logging = true
      const logfile = joinpath(dirname(@__FILE__), "times_problems_log.txt")
      # Enable locking down the window (no frame)
      const frameless = false
      """      
      )
    end
  end
end

generate_default_config()
include(CONFIG_FILE)

const generator = DefaultOpGenerator(times_min, times_max, subtraction_min, addition_max)

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
const problem = Problem(generate(generator), 0, 0, "STARTUP")

function exit_logging()
  if problem.num_correct != max_correct
    writelog("PREMATURE EXIT")
  end
end

atexit(exit_logging)

function check_answer(p::Problem, answer::String)
  p.answer = parse(Int, answer)
  if check(p.question, p.answer)
    p.num_correct += 1
    writelog(p)
    if p.num_correct == max_correct
      p.state = "FINISHED";
    else
      p.state = "CORRECT";
      p.question = generate(generator)
    end
  else
    p.num_correct = 0;
    writelog(p)
    p.state = "ERROR";
  end
end

@qmlfunction check_answer generate
qmlfile = joinpath(dirname(@__FILE__), "qml", "times_problems.qml")

if @qmlapp qmlfile φ problem max_correct frameless
  exec()
end
