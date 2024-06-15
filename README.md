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
Feel free to copy this in your REPL or run it as a script
```julia
using StringCases;

# Let's define a pattern string case for camel case with acronyms, camelCaseACRO

# specify the casing of all the letters besides the first letter of each token
# and the first leter of the string
tokencase = lowercase;

# specify the casing of first letters of each token
tokencasefirst = uppercase;

# specify the casing of the first letter of the string
strcasefirst = lowercase;

# Options for all the cases include:
# lowercase
# uppercase
# titlecase
# StringCases.anycase

# Acronym (i.e. opposite casing of the tokencase) specifier to determine if
# acronyms exist in all/start/end of a token
# Options include:
# StringCases.acro_all_of_token: i.e. Speed30MPH
# StringCases.acro_start_of_token: i.e. Speed30Mph
# StringCases.acro_end_of_token: ie. Speed30mpH
# StringCases.acro_none_of_token: i.e. Speed30mph
acronymintoken = StringCases.acro_all_of_token;

# Split new tokens on numbers
splitonnumber = false;

camel_case_acro = PatternStringCase(
    "camelCaseACRO",
    tokencase,
    tokencasefirst,
    strcasefirst,
    acronymintoken,
    splitonnumber
);

# Convert a string from our newly defined string case, camel_case_acro, to a
# common string case already defined in StringCases.jl (StringCases.PASCAL_CASE)
# For more string cases provided out of the box, take a look at the end of the
# `src/stringcases.jl` file

StringCases.convert("stringCasesFTW!", camel_case_acro, StringCases.PASCAL_CASE)
# Output: "StringCasesFtw!"

# Now let's define a delimiter string case with hyphens, -, while preserving the
# original casing of the string via StringCases.anycase
# this is useful for keeping the acronym around
camel_train_any_case = DelimiterStringCase(
    "camel-Train-ANY-Case",
    anycase,
    uppercase,
    lowercase,
    "-"
);

StringCases.convert("stringCasesFTW!", camel_case_acro, camel_train_any_case)
# Output: "string-Cases-FTW!"

# Let's say you have your own regex to pattern match tokens with
# Source: https://stackoverflow.com/a/70164741
wordpat = r"
^[a-z]+ |                  #match initial lower case part
[A-Z][a-z]+ |              #match Words Like This
\d*([A-Z](?=[A-Z]|$))+ |   #match ABBREV 30MW
\d+                        #match 1234 (numbers without units)
"x;

# You can use it like so:
my_pattern_case = PatternStringCase(
    "myCamelCaseACRO123",
    lowercase,
    uppercase,
    lowercase,
    wordpat
);

StringCases.convert("askBest30MWPrice", my_pattern_case, StringCases.SNAKE_CASE)
# Output: "ask_best_30mw_price"

# However, this pattern can already be specified by this library
# so you don't have to create your own regex
camel_case_acro_num = PatternStringCase(
    "camelCaseACRO123",
    lowercase,
    uppercase,
    lowercase,
    StringCases.acro_all_of_token,
    true,
);

StringCases.convert("askBest30MWPrice", camel_case_acro_num, StringCases.SNAKE_CASE)
# Output: "ask_best_30mw_price"

# Morever, it can handle unicode instead of just the latin letters like the
# custom regex
StringCases.convert("askBest30MWΠrice", my_pattern_case, StringCases.SNAKE_CASE)
# Output: "ask_best_30mw"

# Notice that the uppercase Greek letter Π denotes the start of a new token
# and is also lowercased as required by the snake case convention
StringCases.convert("askBest30MWΠrice", camel_case_acro_num, StringCases.SNAKE_CASE)
# Output: ask_best_30mw_πrice"

# You can also customize delimiters, in fact they can be any one of a string,
# regular expression, function, single character or collection of characters.

# Let's create a regex delimiter to split on one or more (+) characters in the
# Unicode punctuation category (\p{P})
dlm = r"\p{P}+"

camel_case_punc = DelimiterStringCase(
    "camel.Case-_Punctuation!",
    lowercase,
    uppercase,
    lowercase,
    dlm
);

StringCases.convert("string.Cases-_FTW!", camel_case_punc, StringCases.SNAKE_CASE)
# Output: "string_cases_ftw"
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
