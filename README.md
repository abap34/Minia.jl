# Minia

    
[![Build Status](https://github.com/abap34/Minia.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/abap34/Minia.jl/actions/workflows/CI.yml?query=branch%3Amain)



https://github.com/kmizu/minis と https://github.com/momeemt/minim を参考に作ったJulia製のインタプリタです。

Minia.jl は、ソースコードをJuliaのASTに変換し、それを実行します。


文法はだいたい https://github.com/momeemt/minim に沿っています。




# Install

```plaintext
] add https://github.com/abap34/Minia.jl
```

# Usage

```julia
# 入力としてファイルを渡すと、 そのファイルを Juliaの AST に変換します.
ast = Minia.parse("path/to/file.minia")

# ファイルを実行します.
Minia.run("path/to/file.minia")
```

# Example

`fizzbuzz.minia`:

```c++
i = 0
while (i < 100) {
    if (i % 3 == 0) {
        println("Fizz")
    } else {
        0
    }

    if (i % 5 == 0) {
        println("Buzz")
    } else {
        0
    }

    if (i % 15 == 0) {
        println("FizzBuzz")
    } else {
        0
    }

    i = i + 1
}
```

これを `Minia.parse` に渡すと、以下のようなASTが得られます:

```julia
julia> Minia.parse("fizzbuzz.minia") |> dump
Expr
  head: Symbol let
  args: Array{Any}((2,))
    1: Expr
      head: Symbol =
      args: Array{Any}((2,))
        1: Symbol i
        2: Int64 0
    2: Expr
      head: Symbol while
      args: Array{Any}((2,))
        1: Expr
          head: Symbol call
          args: Array{Any}((3,))
            1: Symbol <
            2: Symbol i
            3: Int64 100
        2: Expr
          head: Symbol block
          args: Array{Any}((4,))
            1: Expr
              head: Symbol if
              args: Array{Any}((3,))
                1: Expr
                2: Expr
                3: Expr
            2: Expr
              head: Symbol if
              args: Array{Any}((3,))
                1: Expr
                2: Expr
                3: Expr
            3: Expr
              head: Symbol if
              args: Array{Any}((3,))
                1: Expr
                2: Expr
                3: Expr
            4: Expr
              head: Symbol =
              args: Array{Any}((2,))
                1: Symbol i
                2: Expr
```

これは Juliaのコードで言うと以下のようなものになります:

```julia
julia> Minia.parse("fizzbuzz.minia") |> println
let i = 0
    while i < 100
        if i % 3 == 0
            println("Fizz")
        else
            0
        end
        if i % 5 == 0
            println("Buzz")
        else
            0
        end
        if i % 15 == 0
            println("FizzBuzz")
        else
            0
        end
        i = i + 1
    end
end
```

