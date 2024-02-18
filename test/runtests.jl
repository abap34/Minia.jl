using Minia
using PEG
using Test

onfail(body, _::Test.Pass) = true
onfail(body, _::Union{Test.Fail,Test.Error}) = body()


function load(filename::AbstractString)
    return join(readlines(filename), "\n")
end


testcases = [
    ("\"hello\"", Minia.str) => "hello",
    ("10", Minia.num) => 10,
    ("0", Minia.num) => 0,
    ("1.25", Minia.num) => 1.25,
    ("-1", Minia.unary) => -1,
    ("10 * 10", Minia.mul) => 100,
    ("10 * 20 / 10", Minia.mul) => 20,
    ("1 + 2", Minia.add) => 3,
    ("1 + 2 * 3", Minia.add) => 7,
    ("1.5 * 2 - 10", Minia.add) => -7,
    ("a = 10", Minia.assign) => 10,
    ("a + 2", Minia.add) => 12,
    ("10 < 20", Minia.relational) => true,
    ("10 > 20", Minia.relational) => false,
    ("10 == 10", Minia.relational) => true,
    ("10 != 10", Minia.relational) => false,
    ("cos(0)", Minia.call) => 1.0,
    ("i = 0", Minia.assign) => 0,
    ("println(i)", Minia.call) => nothing,
]




function check(src::String, rule, expected)
    ast = PEG.parse_whole(rule, Minia.rm_space(src))
    result = eval(ast)
    success = expected == "ANYWAY" ? true : result == expected
    return onfail(@test success) do
        @info "Failed. Expected: $expected, got: $result"
        @info "AST: $ast"
    end
end


@testset "Minia.jl" begin
    for ((src, rule), expected) in testcases
        @info "Test for... \n$src"
        check(src, rule, expected)
    end
end
