using TimesTables
using Test

@testset "Multiplication" begin
  m = Multiplication(3,4)
  @test compute(m) == 12
  @test check(m,12)
  @test !check(m,13)
end

@testset "Division" begin
  @test_throws ErrorException d = TimesTables.Division(63,6)

  d = Division(63,7)
  @test compute(d) == 9
  @test check(d,9)
  @test !check(d,7)
end

@testset "Addition" begin
  m = Addition(3,4)
  @test compute(m) == 7
  @test check(m,7)
  @test !check(m,8)
end

@testset "Subtraction" begin
  m = Subtraction(4,3)
  @test compute(m) == 1
  @test check(m,1)
  @test !check(m,2)
end

@testset "Generation" begin
  @test typeof(generate(Multiplication, DefaultOpGenerator())) == Multiplication
  @test typeof(generate(Division, DefaultOpGenerator())) == Division
  @test typeof(generate(Addition, DefaultOpGenerator())) == Addition
  @test typeof(generate(Subtraction, DefaultOpGenerator())) == Subtraction
  @show g = generate()
  @test check(g, compute(g))
  @test !check(g, 2*compute(g))
  println(g)
end