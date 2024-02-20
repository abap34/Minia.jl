using PEG

module Minia

include("rules.jl")


function dropspaces(s::AbstractString)
    return join(filter(x -> x != ' ', s))
end


function load(filename::AbstractString)
    return join(readlines(filename), "\n")
end


function _parse(src::String; rule=program, preprocess=dropspaces)
    return PEG.parse_whole(rule, preprocess(src))
end


function parse(filename::AbstractString; rule=program, preprocess=dropspaces)
    S = load(filename)
    return _parse(S, rule=rule, preprocess=preprocess)
end


function run(filename::AbstractString)
    ast = parse(filename)
    return eval(ast)
end



end
