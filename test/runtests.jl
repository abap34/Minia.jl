using Minia
using Test

onfail(body, _::Test.Pass) = true
onfail(body, _::Union{Test.Fail,Test.Error}) = body()


function load(filename::AbstractString)
    return join(readlines(filename), "\n")
end

function iserror(; expectederror::Type{<:Exception}=Exception)
    return ((e) -> e isa expectederror)
end

parseerror() = iserror(expectederror=Base.Meta.ParseError)

testcases = [
    ("\"hello\"", Minia.str) => (isequal("hello")),
    ("1", Minia.int) => (isequal(1)),
    ("10", Minia.int) => (isequal(10)),
    ("10.0", Minia.float) => (isequal(10.0)),
    (".0", Minia.float) => (iserror()),
    ("0.", Minia.float) => (iserror()),
    ("true", Minia.bool) => (isequal(true)),
    ("false", Minia.bool) => (isequal(false)),
    ("123.45", Minia.num) => (isequal(123.45)),
    ("123", Minia.num) => (isequal(123)),
    ("abc", Minia.ident) => (isequal(UndefVarError(:abc))),
    ("abc_123", Minia.ident) => (isequal(UndefVarError(:abc_123))),
    ("123abc", Minia.ident) => (parseerror()),
    ("if", Minia.ident) => (iserror()),
    ("true", Minia.ident) => (iserror()),
    ("1.0", Minia.unary) => (isequal(1.0)),
    ("-1.0", Minia.unary) => (isequal(-1.0)),
    ("-1", Minia.unary) => (isequal(-1)),
    ("1", Minia.unary) => (isequal(1)),
    ("\"hello\"", Minia.unary) => (isequal("hello")),
    ("true", Minia.unary) => (isequal(true)),
    ("false", Minia.unary) => (isequal(false)),
    ("abc", Minia.unary) => (isequal(UndefVarError(:abc))),
    ("abc_123", Minia.unary) => (isequal(UndefVarError(:abc_123))),
    ("123abc", Minia.unary) => (parseerror()),
    ("if", Minia.unary) => (iserror()),
    ("true", Minia.unary) => (isequal(true)),
]


function check(src::String, rule::Function, expected::Function)
    try
        ast = Minia._parse(src, rule=rule)
        result = eval(ast)
        success = expected(result)
        onfail(@test success) do
            @info "Failed. Expected: $expected, got: $result"
            @info "AST: $ast"
        end
    catch e
        result = e
        success = expected(e)
        onfail(@test success) do
            @info "Failed. Expected: $expected, got error: $e"
        end
    end

end


@testset "Minia.jl" begin
    for ((src, rule), expected) in testcases
        check(src, rule, expected)
    end
end
