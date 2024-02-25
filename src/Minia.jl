using PEG

module Minia

include("rules.jl")
include("builder.jl")


function load(filename::AbstractString)
    return join(readlines(filename), "\n")
end


function _parse(src::String; rule=program)
    return PEG.parse_whole(rule, src)
end


function parse(filename::AbstractString; rule=program)
    S = load(filename)
    return _parse(S, rule=rule)
end


function run(filename::AbstractString)
    ast = parse(filename)
    return eval(ast)
end



end
