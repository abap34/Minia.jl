using Minia
using PEG
using Test

onfail(body, _::Test.Pass) = true
onfail(body, _::Union{Test.Fail,Test.Error}) = body()


function load(filename::AbstractString)
    return join(readlines(filename), "\n")
end


testcases = [
    ("\"hello\"", Minia.str) => (isequal("hello")),
    ("1", Minia.int) => (isequal(1)),
    ("10", Minia.int) => (isequal(10)),
    ("10.0", Minia.float) => (isequal(10.0)),
    ("10 + 20", Minia.add) => (isequal(30)),
    ("10 * 20 + 10", Minia.expr) => (isequal(210)),
    ("\n", Minia.newline) => ((_) -> true),
    ("", Minia.maynewline) => ((_) -> true),
]




function check(src::String, rule, expected)
    ast = Minia._parse(src, rule=rule)
    result = eval(ast)
    success = expected(result)
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
