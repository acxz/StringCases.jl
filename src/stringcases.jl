# passthrough function for keeping input casing on input
function anycase end
anycase(c::AbstractChar) = c
anycase(s::AbstractString) = s

UpperLowerTitleCase = Union{typeof(uppercase),typeof(lowercase),typeof(titlecase)}
UpperLowerTitleAnyCase = Union{UpperLowerTitleCase,typeof(anycase)}

# enum to handle options of how an acronym is used in a token
@enum AcronymInToken begin
    acro_all_of_token
    acro_start_of_token
    acro_end_of_token
    acro_none_of_token
end

# regex string (rs"") to define a regex but not to compile a regex (r"")
macro rs_str(s)
    s
end

# abstract type for string case
abstract type AbstractStringCase{
    TC<:UpperLowerTitleAnyCase,
    TCF<:UpperLowerTitleAnyCase,
    SCF<:UpperLowerTitleAnyCase,
} end

# string case which determines how to split based on delimiter
struct DelimiterStringCase{
    TC<:UpperLowerTitleAnyCase,
    TCF<:UpperLowerTitleAnyCase,
    SCF<:UpperLowerTitleAnyCase,
} <: AbstractStringCase{TC,TCF,SCF}
    name::String
    tokencase::TC
    tokencasefirst::TCF
    strcasefirst::SCF
    dlm::Union{AbstractChar,AbstractString}
end

# String Case which determines how to split based on token patterns
struct PatternStringCase{
    TC<:UpperLowerTitleCase,
    TCF<:UpperLowerTitleCase,
    SCF<:UpperLowerTitleCase,
} <: AbstractStringCase{TC,TCF,SCF}
    name::String
    tokencase::TC
    tokencasefirst::TCF
    strcasefirst::SCF

    # regex to identify what constitutes a token in a string
    pat::Regex

    function PatternStringCase(
        name::String,
        tokencase::TC,
        tokencasefirst::TCF,
        strcasefirst::SCF,
        pat::Regex,
    ) where {TC,TCF,SCF}
        return new{TC,TCF,SCF}(name, tokencase, tokencasefirst, strcasefirst, pat)
    end

    function PatternStringCase(
        name::String,
        tokencase::TC,
        tokencasefirst::TCF,
        strcasefirst::SCF,
        acronymintoken::AcronymInToken = acro_none_of_token,
        splitonnumber::Bool = false,
    ) where {TC,TCF,SCF}

        # for use in detecting a new token
        upper = rs"[\p{Lu}]"
        lower = rs"[\p{Ll}]"
        upperortitle = rs"[\p{Lu}|\p{Lt}]"

        # for use in continuing a token as long as there isn't a upper/title char
        notuppernottitle = rs"[^\p{Lu}&^\p{Lt}]"
        notlowernottitle = rs"[^\p{Ll}&^\p{Lt}]"

        # for use in continuing a token as long as there isn't a upper/title/number char
        notuppernottitlenotnumber = rs"[^\p{Lu}&^\p{Lt}&^\p{N}]"

        # for use in continuing a token as long as there isn't a lower case change
        # this is how tokens of multiple upper/title chars are handled (e.g. acronyms)
        # the magic is done via regex look ahead (?=) until we absolutely know that we
        # are now part of another token and then backtrack by 1 char (i.e. when we reach
        # a lower case char after a not lower case char)
        # "$" is for ensuring that we don't backtrack if we reach the end of the string
        notlowerseq = rs"([^\p{Ll}](?=[^\p{Ll}]|$))+"
        notuppernottitleseq = rs"([^\p{Lu}&^\p{Lt}](?=[^\p{Lu}&^\p{Lt}]|$))+"
        notlowernottitleseq = rs"([^\p{Ll}&^\p{Lt}](?=[^\p{Ll}&^\p{Lt}]|$))+"

        # see above explanation but extend lower with lower and number
        notlowernotnumberseq = rs"([^\p{Ll}&^\p{N}](?=[^\p{Ll}&^\p{N}]|$))+"

        # for use in detecting a new token with a number
        number = rs"[\p{N}]"

        # for use in inserting number in existing patterns
        unicodenumber = rs"\p{N}"

        # for use in ensuring a number acronym continues with any not lower char,
        # ensures we continue the number acronym token until we absolutely have to stop
        notlower = rs"[^\p{Ll}]"

        # prefix unary operator
        start = rs"^"
        not = rs"^"

        # postfix unary operator
        oneormore = rs"+"
        any = rs"*"

        # infix binary operator
        or = rs"|"
        and = rs"&"

        # wrap some regex in a lookahead
        # used for determining the end of an acronym
        function _lookahead(s)
            return rs"(" * s * rs"(?=" * s * rs"|$))+"
        end

        tokencasergxstr = rs""
        tokencasefirstrgxstr = rs""
        strcasefirstrgxstr = rs""
        acronymorrgxstr = rs""
        numberfirstrgxstr = rs""
        numberfirstacronymorrgxstr = rs""

        if tokencase isa typeof(uppercase)
            tokencasergxstr = notlowernottitle
        elseif tokencase isa typeof(lowercase)
            tokencasergxstr = notuppernottitle
        elseif tokencase isa typeof(titlecase)
            # titlecase also includes the uppercase characters
            # but if using titlecase, only the titlecase characters
            # of the corresponding lowercase character must be used
            # TODO: how to enforce this
            # do a check to see if a titlecase version exists for the character
            # if it does use that over the uppercase one
            tokencasergxstr = notlower
        end

        if tokencasefirst isa typeof(uppercase)
            tokencasefirstrgxstr = upper
        elseif tokencasefirst isa typeof(lowercase)
            tokencasefirstrgxstr = lower
        elseif tokencasefirst isa typeof(titlecase)
            tokencasefirstrgxstr = upperortitle
        end

        if strcasefirst isa typeof(uppercase)
            strcasefirstrgxstr = upper
        elseif strcasefirst isa typeof(lowercase)
            strcasefirstrgxstr = lower
        elseif strcasefirst isa typeof(titlecase)
            strcasefirstrgxstr = upperortitle
        end

        if acronymintoken ∈ [acro_all_of_token, acro_start_of_token, acro_end_of_token]
            acronymcasergxstr = rs""

            # create acronym case regex string based on tokencasefirst
            if tokencasefirst isa typeof(uppercase)
                acronymcasergxstr = notlowernottitle
            elseif tokencasefirst isa typeof(lowercase)
                acronymcasergxstr = notuppernottitle
            elseif tokencasefirst isa typeof(titlecase)
                acronymcasergxstr = notlower
            end

            # Four cases regarding acronyms (special casing of tokens)
            # followup lowercase letters (e.g. 23MHz vs 23M, Hz)
            # the regular acronym case would be: MW Hz Hello vs MWHz Hello
            # basically you have an acronym (only uppercase) or have
            # the token start with an acronym and follow up with
            # lower/tokencase
            # the other case is when the acronym is at the end, i.e. HzhHEL

            if acronymintoken == acro_all_of_token
                acronymrgxstr = _lookahead(acronymcasergxstr)
            elseif acronymintoken == acro_start_of_token
                acronymrgxstr =
                    tokencasefirstrgxstr * acronymcasergxstr * any * tokencasergxstr * any
            elseif acronymintoken == acro_end_of_token
                acronymrgxstr =
                    tokencasefirstrgxstr *
                    tokencasergxstr *
                    any *
                    _lookahead(acronymcasergxstr)
            end

            # add the prefix "or" to integrate with the final patrgxstr
            acronymorrgxstr = acronymrgxstr * or
        end

        # insert unicode number category into the tokencasergxstr and
        # acronymorrgxstr as needed
        if splitonnumber
            tokencasergxstr =
                replace(tokencasergxstr, r"]" => (and * not * unicodenumber * rs"]"))
            numberfirstrgxstr = number * oneormore * tokencasergxstr * any * or

            if !isempty(acronymorrgxstr)
                acronymorrgxstr =
                    replace(acronymorrgxstr, r"]" => (and * not * unicodenumber * rs"]"))
                numberfirstacronymorrgxstr = number * oneormore * acronymorrgxstr
            end
        end

        # acronymorgxstr has to match first otherwise the acronym token would get
        # split up
        firsttokenrgxstr = start * strcasefirstrgxstr * tokencasergxstr * any
        tokenrgxstr = or * tokencasefirstrgxstr * tokencasergxstr * any
        patrgxstr =
            numberfirstacronymorrgxstr *
            numberfirstrgxstr *
            acronymorrgxstr *
            firsttokenrgxstr *
            tokenrgxstr

        pat = Regex(patrgxstr)

        return new{TC,TCF,SCF}(name, tokencase, tokencasefirst, strcasefirst, pat)
    end
end

# Case tokens based on string case
function _case!(tokens, sc::AbstractStringCase)
    # Case all token letters
    tokens[begin:end] = sc.tokencase.(tokens)

    # Case first letter of all but first token
    tokens[(begin + 1):end] = _casefirst.(tokens[(begin + 1):end], sc.tokencasefirst)

    # Case first letter of first token
    tokens[begin] = _casefirst(first(tokens), sc.strcasefirst)
end

# Case first char of token if not empty, otherwise passthrough
function _casefirst(token::AbstractString, case::UpperLowerTitleAnyCase)
    if isempty("")
        token
    else
        case(first(token)) * SubString(token, nextind(token, firstindex(token)))
    end
end

function split(s::AbstractString, dsc::DelimiterStringCase)
    return Base.split(s, dsc.dlm)
end

function split(s::AbstractString, psc::PatternStringCase)
    return [m.match for m in eachmatch(psc.pat, s)]
end

function join(tokens, dsc::DelimiterStringCase)
    _case!(tokens, dsc)
    return Base.join(tokens, dsc.dlm)
end

function join(tokens, psc::PatternStringCase)
    _case!(tokens, psc)
    return Base.join(tokens)
end

function convert(
    s::AbstractString,
    input_sc::AbstractStringCase,
    output_sc::AbstractStringCase,
)
    # Split string based on delimiter or pattern
    tokens = split(s, input_sc)

    # Join tokens based on delimiter or pattern
    return join(tokens, output_sc)
end

# TODO: add isvalid, validated_tokens, and correct_tokens as output to an
# encompassing validate function,
# this helps redundant splits if we run validate inside convert
function validate(s::AbstractString, sc::AbstractStringCase)
    # Split string based string case
    tokens = split(s, sc)

    # Validate split tokens with respect to the original string
    is_valid_str = s == join(tokens, sc)

    # Check case for all but first token
    correct_tokens = Vector{SubString{typeof(s)}}()
    for token in tokens[(begin + 1):end]
        correct_token_wip = sc.tokencase(token)
        correct_token = _casefirst(correct_token_wip, sc.strcasefirst)

        if token != correct_token
            is_valid_str = false
        end

        push!(correct_tokens, correct_token)
    end

    # Check case for first token
    correct_first_token_wip = sc.tokencase(first(tokens))
    correct_first_token = _casefirst(correct_first_token_wip, sc.strcasefirst)

    if first(tokens) != correct_first_token
        is_valid_str = false
    end

    pushfirst!(correct_tokens, correct_first_token)

    correct_str = join(correct_tokens, sc)

    return is_valid_str
end
