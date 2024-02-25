# Minia

    
[![Build Status](https://github.com/abap34/Minia.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/abap34/Minia.jl/actions/workflows/CI.yml?query=branch%3Amain)



https://github.com/kmizu/minis と https://github.com/momeemt/minim を参考に作ったJulia製のインタプリタです。

Minia.jl は、ソースコードをJuliaのASTに変換し、それを実行します。


文法はだいたい https://github.com/momeemt/minim に沿っています。

詳細は　`src/rules.jl` を参照してください。


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

```julia
function fizzbuzz(n) {
    i = 0
    while (i < 100){
        i = i + 1
        if (i % 15 == 0) {
            println("FizzBuzz")
        } elseif (i % 3 == 0) {
            println("Fizz")
        } elseif (i % 5 == 0) {
            println("Buzz")
        } else {
            println(i)
        }
    }
}

fizzbuzz(100)
```

これを `Minia.parse` に渡すと、以下のようなASTが得られます:

```julia
julia> Minia.parse("fizzbuzz.minia") |> dump
Expr
  head: Symbol let
  args: Array{Any}((2,))
    1: Expr
      head: Symbol block
      args: Array{Any}((0,))
    2: Expr
      head: Symbol block
      args: Array{Any}((2,))
        1: Expr
          head: Symbol function
          args: Array{Any}((2,))
            1: Expr
              head: Symbol call
              args: Array{Any}((2,))
                1: Symbol fizzbuzz
                2: Symbol n
            2: Expr
              head: Symbol block
              args: Array{Any}((2,))
                1: Expr
                2: Expr
        2: Expr
          head: Symbol call
          args: Array{Any}((2,))
            1: Symbol fizzbuzz
            2: Int64 100
```

つまり、以下のようなコードが得られています:


```julia
julia> Minia.parse("fizzbuzz.minia") |> println
let
    function fizzbuzz(n)
        i = 0
        while i < 100
            i = i + 1
            if i % 15 == 0
                println("FizzBuzz")
            elseif i % 3 == 0
                println("Fizz")
            elseif i % 5 == 0
                println("Buzz")
            else
                println(i)
            end
        end
    end
    fizzbuzz(100)
end
```


なので、実行すると以下のようになります:


```julia
julia> Minia.run("fizzbuzz.minia")
1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
16
```

