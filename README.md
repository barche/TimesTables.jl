# TimesTables

[![Build Status](https://travis-ci.org/barche/TimesTables.jl.svg?branch=master)](https://travis-ci.org/barche/TimesTables.jl)

The purpose of this package is to generate and test simple math problems for primary school.

## Installation

In Pkg mode (hit `]`):

```julia
add https://github.com/JuliaAudio/PortAudio.jl.git
add https://github.com/barche/TimesTables.jl.git
```

## Usage

```julia
using TimesTables
TimesTables.julia_main()
```
This should bring up the following GUI
![Screenshot](screenshot.png?raw=true "The interface")

## Configuration

Configuration happens through a config file in your home directory in `.julia/prefs/TimesTables.toml`:

```toml
additionmax = 1000
uselogfile = false
timesmin = 1
maxnumcorrect = 3
timesmax = 100
lockedwindow = false
subtractionmin = 0
```

This file is auto-generated with default suitable for the second year of primary school. The options are:
* `additionmax`: Maximum values of the terms in an addition
* `subtractionmin`: Minimum possible result from a subtraction exercise
* `timesmin` and `timesmax`: minimum and maximum value of the terms in multiplication and division exercises
* `maxnumcorrect`: Number of consecutive correct answers before the exercise is finished
* `uselogfile`: Log operations to `~/.julia/logs/TimesTables.log`
* `lockedwindow`: Keep the window on top and remove the border (no close button)
