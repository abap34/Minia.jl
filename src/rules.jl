using PEG

@rule program = (expr, newline)[*] |> build_program
@rule expr = assign, call, relational, _if, _while, _function, seq
@rule _function = ("function" & ident & "(" & ident & ")" & seq) |> build_function
@rule _if = ("if" & "(" & expr & ")" & maynewline & seq & maynewline & "else" & maynewline & seq) |> build_if
@rule _while = ("while" & "(" & expr & ")" & seq) |> build_while
@rule seq = ("{" & maynewline & (expr&"\n")[*] & "}" & maynewline) |> build_seq
@rule call = (ident & "(" & expr & ")") |> build_call
@rule assign = (ident & "=" & expr) |> build_assign
@rule relational = (add & (("!=", "<=", "=<", ">", "<", "==")&add)[*]) |> build_binop
@rule add = (mul & (("+", "-")&mul)[*]) |> build_binop
@rule mul = (unary & (("*", "/", "%")&unary)[*]) |> build_binop
@rule unary = (("+", "-")[:?] & primary) |> build_unary
@rule primary = (num, str, ident, "(" & expr & ")") |> identity
@rule ident = r"^(?!.*(function|if|else|while))[a-zA-Z_][a-zA-Z0-9_]*" |> build_ident
@rule num = float, int
@rule str = ("\"" & r"[^\"]"[*] & "\"") |> (w -> getindex(w, 2)) |> join
@rule int = (r"0", r"[0-9]"[+]) |> build_int
@rule float = (r"[0-9]"[+] & "." & r"[0-9]"[+]) |> build_float
@rule fail = r"[^\n]"[*] |> (w -> error("Failed to parse: $w"))
@rule maynewline = "\n"[:?]
@rule newline = "\n" |> (w -> nothing)

function build_program(w)
    return Expr(:let, (filter(x -> x !== nothing, w))...)
end

function build_function(w)
    name = w[2]
    arg = w[4]
    body = w[6]
    return Expr(:function, Expr(:call, name, arg), body)
end


function build_if(w)
    cond = w[3]
    body = w[6]
    else_body = w[10]
    return Expr(:if, cond, body, else_body)
end


function build_while(w)
    cond = w[3]
    body = w[5]
    return Expr(:while, cond, body)
end


function build_call(w)
    ident = w[1]
    expr = w[3]
    return Expr(:call, ident, expr)
end


function build_seq(w)
    body = w[3]
    exprs = [line[1] for line in body]
    return Expr(:block, exprs...)
end



function build_assign(w)
    ident = w[1]
    expr = w[3]
    return Expr(:(=), ident, expr)
end


as_opsymbols = Dict(
    "+" => :+,
    "-" => :-,
    "*" => :*,
    "/" => :/,
    "%" => :%,
    ">" => :(>),
    "<" => :(<),
    "==" => :(==),
    "!=" => :(!=),
    "<=" => :(<=),
    ">=" => :(>=)
)


function build_binop(w)
    lhs = w[1]
    for ex in w[2]
        op, rhs = ex
        lhs = Expr(:call, as_opsymbols[op], lhs, rhs)
    end
    return lhs
end



function rec_join(arr::AbstractArray)
    return join(map(rec_join, arr))
end

function rec_join(s::AbstractString)
    return s
end


build_int(w::AbstractArray) = build_int(rec_join(w))
build_int(w::AbstractString) = Meta.parse(w)

build_float(w::AbstractArray) = build_float(rec_join(w))
build_float(w::AbstractString) = Meta.parse(w)


function build_unary((op, expr))
    if op == ["-"]
        return Expr(:call, :(-), expr)
    else
        return expr
    end
end

function build_ident(w)
    return Symbol(w)
end



# スペースを削除. 改行はそのまま
function preprocess(s::AbstractString)
    return join(filter(x -> x != ' ', s))
end
