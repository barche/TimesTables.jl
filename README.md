# TimesTables

[![Build Status](https://travis-ci.org/barche/TimesTables.jl.svg?branch=master)](https://travis-ci.org/barche/TimesTables.jl)

The purpose of this package is to generate and test simple math problems for primary school. The basic package contains the code to generate and check problems, while the `applications` directory contains a QML GUI.

## Usage

```julia
using TimesTables
# Generate a random problem using default settings
prob = generate()
# Print the problem
println(prob)
# Check the answer
println(check(prob, parse(Int,readline(STDIN))) ? "Correct" : "Wrong, the correct answer was $(compute(prob))")
```

## GUI
The GUI by default asks the user to generate solve 3 consecutive problems correctly. Parameters for the GUI can be adjusted in the
`times_problems_config.jl` file that is generated automatically, answers can be checked in the log file. Screenshot:

![Screenshot](screenshot.png?raw=true "Plots example")

By setting `frameless` to true in the options the GUI can be made to stay on top and be apparently "unclosable", which can be useful to "force" the target to solve the exercices, especially when the GUI lanches automatically upon login and again after a certain timeout.

The GUI application can be copied anywhere, as long as the `qml` directory is next to the `times_problems.jl` file.