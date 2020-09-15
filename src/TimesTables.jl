module TimesTables

using QML
using Observables
using Pkg.Artifacts
using Pkg.TOML
using Dates
using Logging
import FileIO

# Sound stuff
# import PortAudio
# import LibSndFile

export TimesOp, Multiplication, Division, Addition, Subtraction, OpGenerator, DefaultOpGenerator
export compute, check, generate

const artifact_version = v"0.0.1"

assetroot() = joinpath(artifact"timestables-assets", "timestables-assets-$(artifact_version)")
qmlfile() = joinpath(assetroot(), "qml", "times_problems.qml")
soundsdir() = joinpath(assetroot(), "sounds")

"""
Base type for all operationd, e.g. multiplication and division
"""
abstract type TimesOp end

"""
Encapsulate a × b
"""
struct Multiplication <: TimesOp
  a::Int32
  b::Int32
end

"""
Encapsulate a ÷ b
"""
struct Division <: TimesOp
  a::Int
  b::Int

  function Division(a,b)
    if a % b != 0
      error("Division constructor: $a is not divisible by $b")
    end
    return new(a,b)
  end
end

"""
Encapsulate a + b
"""
struct Addition <: TimesOp
  a::Int
  b::Int
end

"""
Encapsulate a - b
"""
struct Subtraction <: TimesOp
  a::Int
  b::Int
end

"""
Compute the result of an op
"""
compute(op::Multiplication) = op.a * op.b
compute(op::Division) = op.a ÷ op.b
compute(op::Addition) = op.a + op.b
compute(op::Subtraction) = op.a - op.b

"""
Check the result of an op
"""
check(op::TimesOp, x::Number) = (x == compute(op))

"""
Base type for op generators
"""
abstract type OpGenerator end

"""
Default OpGenerator that generates any type of op, limiting divisions and multiplication operands
between `times_min` and `times_max` and the sum of operands to addition and subtraction to addition_max.
These defaults correspond to second grade of primary school in Belgium.
"""
struct DefaultOpGenerator <: OpGenerator
  times_min::Int
  times_max::Int
  subtraction_min::Int
  addition_max::Int
end

DefaultOpGenerator() = DefaultOpGenerator(1,10,0,100)

"""
Generate a random multiplication op
"""
generate(::Type{Multiplication}, g::DefaultOpGenerator) = Multiplication(rand(g.times_min:g.times_max), rand(g.times_min:g.times_max))

"""
Generate a random division op
"""
function generate(::Type{Division}, g::DefaultOpGenerator)
  a = rand(g.times_min:g.times_max)
  b = rand(g.times_min:g.times_max)
  return Division(a*b, b)
end

"""
Generate a random addition op
"""
function generate(::Type{Addition}, g::DefaultOpGenerator)
  a = rand(0:g.addition_max)
  b = rand(0:g.addition_max - a)
  return Addition(a, b)
end

"""
Generate a random Subtraction op
"""
function generate(::Type{Subtraction}, g::DefaultOpGenerator)
  a = rand(0:g.addition_max)
  b = rand(0:a-g.subtraction_min)
  return Subtraction(a, b)
end

function generate_type(g::DefaultOpGenerator)
  return rand([Multiplication, Division, Addition, Subtraction])
end

"""
Generate a random op
"""
generate(g::OpGenerator = DefaultOpGenerator()) = generate(generate_type(g), g)

Base.print(io::IO, o::Multiplication) = write(io, "$(o.a) × $(o.b)")
Base.print(io::IO, o::Division) = write(io, "$(o.a) : $(o.b)")
Base.print(io::IO, o::Addition) = write(io, "$(o.a) + $(o.b)")
Base.print(io::IO, o::Subtraction) = write(io, "$(o.a) - $(o.b)")

function getconfig()
  configfile = joinpath(first(DEPOT_PATH), "prefs", "TimesTables.toml")
  if !isfile(configfile)
    mkpath(dirname(configfile))
    defaultconfig = Dict(
      "timesmin" => 1,
      "timesmax" => 10,
      "subtractionmin" => 0,
      "additionmax" => 100,
      "maxnumcorrect" => 3,
      "uselogfile" => false,
      "lockedwindow" => false
    )
    open(configfile, write=true) do f
      TOML.print(f, defaultconfig)
    end
  end
  return TOML.parsefile(configfile)
end

const generator = Ref{OpGenerator}()
const currentop = Observable{TimesOp}()
const currentopstring = Observable("")
const answerstring = Observable("")
const numcorrect = Observable(0)
const maxnumcorrect = Observable(0)
const state = Observable("STARTUP")

on(currentop) do op
  currentopstring[] = string(op)
end

on(answerstring) do s
  if isempty(s)
    return
  end
  answer = parse(Int, s)
  if check(currentop[], answer)
    numcorrect[] += 1
    @info "Correct answer for $(currentop[]): $s"
    if numcorrect[] == maxnumcorrect[]
      state[] = "FINISHED";
      playsound(cheer[])
    else
      state[] = "CORRECT";
      currentop[] = generate(generator[])
      playsound(woohoo[])
    end
  else
    numcorrect[] = 0;
    @info "Wrong answer for $(currentop[]): $s"
    state[] = "ERROR";
    playsound(ohno[])
  end
end

const cheer = Ref{Any}()
const ohno = Ref{Any}()
const woohoo = Ref{Any}()

#const audio_out = Ref{PortAudio.PortAudioStream}()
playsound(s) = nothing #PortAudio.write(audio_out[], s)

function julia_main()
  config = getconfig()

  cheer[] = nothing # FileIO.load(joinpath(soundsdir(), "cheer.wav"))
  ohno[] = nothing # FileIO.load(joinpath(soundsdir(), "ohno.wav"))
  woohoo[] = nothing # FileIO.load(joinpath(soundsdir(), "woohoo.wav"))

  #audio_out[] = PortAudio.PortAudioStream(0, 2)

  if config["uselogfile"]
    logio = io = open(joinpath(first(DEPOT_PATH), "logs", "TimesTables.log"), "a+")
    global_logger(SimpleLogger(logio))
  end

  generator[] = DefaultOpGenerator(config["timesmin"], config["timesmax"], config["subtractionmin"], config["additionmax"])
  numcorrect[] = 0
  maxnumcorrect[] = config["maxnumcorrect"]
  currentop[] = generate(generator[])
  state[] = "STARTUP"
  load(qmlfile(),
    φ = Float64(Base.MathConstants.golden),
    lockedwindow = config["lockedwindow"],
    problem = JuliaPropertyMap(
      "question" => currentopstring,
      "answer" => answerstring,
      "state" => state,
      "numcorrect" => numcorrect,
      "maxnumcorrect" => maxnumcorrect,
    ))

  exec()

  if numcorrect[] != maxnumcorrect[]
    @warn "Premature exit on $(now())"
  else
    @info "Normal exit on $(now())"
  end

  if config["uselogfile"]
    close(logio)
  end

  return 0
end

end # module
