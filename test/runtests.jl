using TimesTables
using Base.Test

m = Multiplication(3,4)
@test compute(m) == 12
@test check(m,12)
@test !check(m,13)

@test_throws ErrorException d = TimesTables.Division(63,6)

d = Division(63,7)
@test compute(d) == 9
@test check(d,9)
@test !check(d,7)

@test typeof(generate(Multiplication)) == Multiplication
@test typeof(generate(Division)) == Division
@show g = generate()
@test check(g, compute(g))
@test !check(g, 2*compute(g))
println(g)
