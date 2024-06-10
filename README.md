# StringCases

[![Build Status](https://github.com/acxz/StringCases.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/acxz/StringCases.jl/actions/workflows/CI.yml?query=branch%3Amain)

A Julia package for [string cases](https://stringcase.org/definitions)
that allows users to
- **define** their own string case
- **validate** strings on string cases
- **convert** between string cases

Comes with various common prebuilt string cases. See
[end of `src/stringcases.jl` file](https://github.com/acxz/StringCases.jl/blob/4a1e508ef24033e87ec301f7438e05eddc7eab63/src/stringcases.jl#L336)

## Add Package
In Julia REPL:
```julia-repl
julia> ]add https://github.com/acxz/StringCases.jl
```
[Info](https://pkgdocs.julialang.org/v1/managing-packages/#Adding-unregistered-packages)

## Remove Package
In Julia REPL:
```julia-repl
julia> ]rm StringCases
```
[Info](https://pkgdocs.julialang.org/v1/managing-packages/#Removing-packages)

## Example Usage
```julia
julia> using StringCases

julia> camel_case_acro = PatternStringCase("camelCaseACRO", lowercase, uppercase, lowercase, StringCases.acro_all_of_token, false);

julia> StringCases.convert("stringCasesFTW!", camel_case_acro, StringCases.PASCAL_CASE)
"StringCasesFtw!"
```
For more examples see
[`test/runtests.jl`](https://github.com/acxz/StringCases.jl/blob/main/test/runtests.jl)
file.

## Why you should use this library
While there are a myriad of string case libraries, few string case libraries
exist where string cases can be user defined, customized or extended. This
library is one of them. In addition, this library provides a larger feature set
out of the box. This includes unicode support and splitting a string based on a
delimiter or a matching pattern. Existing pattern support includes splitting a
string based on case change, having acronym support, having number support, and
combinations thereof.

In some libraries which allow custom cases, functions must be created for string
case related processing
([Case](https://github.com/nbubna/Case?tab=readme-ov-file#extending-case),
[cases](https://github.com/rossmacarthur/cases?tab=readme-ov-file#customizing)).
One particularly fascinating library,
[casex](https://github.com/pedsmoreira/casex?tab=readme-ov-file#how-it-works),
uses a self expressive pattern to define a string case.
[kasechange](https://github.com/pearxteam/kasechange/blob/6c274238ddae339b7cd0d50751855b710facf223/src/commonMain/kotlin/net/pearx/kasechange/formatter/CaseFormatterConfigurable.kt#L10-L22)
is a library that represents a string case as a type. This means that there is
an API that does not involve the user defining input functions.

In this library, a string case is represented as a type, not unlike the approach
taken in [kasechange](https://github.com/pearxteam/kasechange). However, this
library is more easy to read and succinct. It is also more generic, using a
union type to allow upper/lower/title/any cases and being
able to split tokens either on a delimiter or to match tokens based on a pattern.
The delimiter can be [specified as a character, collection of characters, string,
regular expression, or a function](https://docs.julialang.org/en/v1/base/strings/#Base.split)
and a pattern can be specified with a regex. Default pattern regexes are
provided that allow you to match based on case changes, acronyms, numbers, and
combinations thereof.
Compared to [kasechange](https://github.com/pearxteam/kasechange) which is using
a [boolean for allowing only upper/lower cases](https://github.com/pearxteam/kasechange/blob/6c274238ddae339b7cd0d50751855b710facf223/src/commonMain/kotlin/net/pearx/kasechange/formatter/CaseFormatterConfigurable.kt#L15)
and only allows specifing string splits via
[delimiters as a collection of characters](https://github.com/pearxteam/kasechange/blob/6c274238ddae339b7cd0d50751855b710facf223/src/commonMain/kotlin/net/pearx/kasechange/splitter/WordSplitterConfigurable.kt#L15).

## Related Projects
Here are some projects that allow user defined string cases. Feel free to submit
PRs to add to this list.
- [nbubna/Case](https://github.com/nbubna/Case)
- [pedsmoreira/casex](https://github.com/pedsmoreira/casex)
- [pearxteam/kasechange](https://github.com/pearxteam/kasechange)
- [rossmacarthur/cases](https://github.com/rossmacarthur/cases)

Another Julia string case library:
- [djsegal/StringCases.jl](https://github.com/djsegal/StringCases.jl)
