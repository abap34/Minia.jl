recjoin(arr::AbstractArray) = join(recjoin.(arr))
recjoin(s::AbstractString) = s

build_bool(w::AbstractString) = w == "true" ? true : false


build_str(w::AbstractArray) = recjoin(w[2])

build_int(w::AbstractString) = Base.parse(Int, w)
build_int(w::AbstractArray) = build_int(recjoin(w))

build_float(w::AbstractString) = Base.parse(Float64, w)
build_float(w::AbstractArray) = build_float(recjoin(w))


function build_ident(w)
    name = recjoin(w)
    return Symbol(name)
end

function build_unary(w::AbstractArray)
    op, expr = w
    if op == ["-"]
        return Expr(:call, :(-), expr)
    else
        return expr
    end
end


function build_binop(w::AbstractArray)
    lhs = w[1]
    for ex in w[2]
        op, rhs = ex
        lhs = Expr(:call, Symbol(op), lhs, rhs)
    end
    return lhs
end


function build_assign(w::AbstractArray)
    ident = w[1]
    expr = w[3]
    return Expr(:(=), ident, expr)
end


function build_call(w::AbstractArray)
    name = w[1]
    args = w[3]
    return Expr(:call, name, args...)
end


function build_args(w::AbstractArray)
    args = Any[w[1],]
    restargs = w[2]
    for arg in restargs
        push!(args, arg[2])
    end
    return args
end


function build_seq(w::AbstractArray)
    bodies = w[2]
    return Expr(:block, bodies...)
end


function build_if(w::AbstractArray)
    cand = w[3]
    body = w[5]
    elseifs = w[6]

    if isempty(elseifs)
        if isempty(w[7])
            return Expr(:if, cand, body)
        else
            else_body = w[7][1][2]
            return Expr(:if, cand, body, else_body)
        end
    else
        elseif_conds = [_elseif[3] for _elseif in elseifs]
        elseif_bodies = [_elseif[5] for _elseif in elseifs]

        n = length(elseif_conds)

        if isempty(w[7])
            ex = Expr(:elseif, elseif_conds[end], elseif_bodies[end])
            for i in n-1:-1:1
                ex = Expr(:elseif, elseif_conds[i], elseif_bodies[i], ex)
            end
            return Expr(:if, cand, body, ex)
        else
            else_body = w[7][1][2]
            ex = Expr(:elseif, elseif_conds[end], elseif_bodies[end], else_body)
            for i in n-1:-1:1
                ex = Expr(:elseif, elseif_conds[i], elseif_bodies[i], ex)
            end
            return Expr(:if, cand, body, ex)
        end
    end
end


function build_argnames(w)
    args = Any[w[1],]
    restargs = w[2]
    for arg in restargs
        push!(args, arg[2])
    end
    return args
end


function build_function(w)
    name = w[2]
    args = w[4]
    body = w[6]
    return Expr(:function, Expr(:call, name, args...), body)
end


function build_while(w)
    cond = w[3]
    body = w[5]
    return Expr(:while, cond, body)
end

function build_return(w)
    return Expr(:return, w[2])
end


function build_program(w)
    exprs = filter(x -> x !== nothing, w)
    return Expr(:let, Expr(:block), Expr(:block, exprs...))
end
