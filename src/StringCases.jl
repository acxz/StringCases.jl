module StringCases

include("stringcases.jl")
include("commonstringcases.jl")

export AbstractStringCase, DelimiterStringCase, PatternStringCase

export convert, validate

export anycase, AcronymInToken

end
