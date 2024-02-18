using PEG

module Minia

include("rules.jl")

function load(filename::AbstractString)
    return join(readlines(filename), "\n")
end


function parse(filename::AbstractString)
    S = load(filename) |> preprocess
    return PEG.parse_whole(program, S)
end


function run(filename::AbstractString)
    ast = parse(filename)
    return eval(ast)
end



end
