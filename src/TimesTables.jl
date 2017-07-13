module TimesTables

export TimesOp, Multiplication, Division
export compute, check, generate

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
Compute the result of an op
"""
compute(op::Multiplication) = op.a * op.b
compute(op::Division) = op.a ÷ op.b

"""
Check the result of an op
"""
check(op::TimesOp, x::Number) = (x == compute(op))

"""
Generate a random multiplication op
"""
generate(::Type{Multiplication}, min=1, max = 10) = Multiplication(rand(min:max), rand(min:max))

"""
Generate a random division op
"""
function generate(::Type{Division}, min=1, max = 10)
  a = rand(min:max)
  b = rand(min:max)
  return Division(a*b, b)
end

"""
Generate a random op
"""
generate(min=1, max=10) = generate(rand([Multiplication, Division]), 1, 10)

Base.print(io::IO, m::Multiplication) = write(io, "$(m.a) × $(m.b)")
Base.print(io::IO, m::Division) = write(io, "$(m.a) : $(m.b)")

end # module
