using StringCases
using Test

@testset "StringCases.jl" begin
    @testset "Validate" begin
        @test StringCases.validate("StringCasePat", StringCases.PASCAL_CASE) == true
        @test StringCases.validate("stringCasePat", StringCases.CAMEL_CASE) == false
        @test StringCases.validate("String Case Dlm", StringCases.TITLE_CASE) == true
        @test StringCases.validate("α_β_δ", StringCases.SNAKE_CASE) == true
    end
    @testset "Convert" begin
        @test StringCases.convert(
            "StringCasePat",
            StringCases.PASCAL_CASE,
            StringCases.SNAKE_CASE,
        ) == "string_case_pat"
        @test StringCases.convert(
            "stringCasePat",
            StringCases.CAMEL_CASE,
            StringCases.SCREAMING_SNAKE_CASE,
        ) == "STRING_CASE_PAT"
        @test StringCases.convert(
            "string_case_dlm",
            StringCases.SNAKE_CASE,
            StringCases.TITLE_CASE,
        ) == "String Case Dlm"
        @test StringCases.convert(
            "α_β_δ",
            StringCases.SNAKE_CASE,
            StringCases.PASCAL_CASE,
        ) == "ΑΒΔ"
    end
    @testset "Pattern Splitting" begin
        camel_title_case_acroall = StringCases.PatternStringCase(
            "camelTitleCaseACRO",
            lowercase,
            titlecase,
            lowercase,
            StringCases.acro_all_of_token,
            false,
        )
        camel_title_case_acrostart = StringCases.PatternStringCase(
            "camelTitleCaseACro",
            lowercase,
            titlecase,
            lowercase,
            StringCases.acro_start_of_token,
            false,
        )
        camel_title_case_acroend = StringCases.PatternStringCase(
            "camelTitleCaseAcrO",
            lowercase,
            titlecase,
            lowercase,
            StringCases.acro_end_of_token,
            false,
        )
        camel_title_case_num = StringCases.PatternStringCase(
            "camelTitleCase23Num",
            lowercase,
            titlecase,
            lowercase,
            StringCases.acro_none_of_token,
            true,
        )
        camel_title_case_acroall_num = StringCases.PatternStringCase(
            "camelTitleCase23NUMACRO",
            lowercase,
            titlecase,
            lowercase,
            StringCases.acro_all_of_token,
            true,
        )
        camel_title_case_acrostart_num = StringCases.PatternStringCase(
            "camelTitleCase23NUmACro",
            lowercase,
            titlecase,
            lowercase,
            StringCases.acro_start_of_token,
            true,
        )
        camel_title_case_acroend_num = StringCases.PatternStringCase(
            "camelTitleCase23NuMAcRO",
            lowercase,
            titlecase,
            lowercase,
            StringCases.acro_end_of_token,
            true,
        )

        test_string = "q2eryǅnterfaceFOמࠇPrice2৶3MמWzHRate2r"
        @test StringCases.convert(
            test_string,
            StringCases.CAMEL_TITLE_CASE,
            StringCases.SPACE_CASE,
        ) == "q2ery ǅnterface F Oמࠇ Price2৶3 Mמ Wz H Rate2r"
        @test StringCases.convert(
            test_string,
            camel_title_case_acroall,
            StringCases.SPACE_CASE,
        ) == "q2ery ǅnterface FOמࠇ Price2৶3 Mמ Wz H Rate2r"
        @test StringCases.convert(
            test_string,
            camel_title_case_acrostart,
            StringCases.SPACE_CASE,
        ) == "q2ery ǅnterface FOמࠇPrice2৶3 MמWz HRate2r"
        @test StringCases.convert(
            test_string,
            camel_title_case_acroend,
            StringCases.SPACE_CASE,
        ) == "q2ery ǅnterfaceFOמࠇ Price2৶3Mמ WzH Rate2r"
        @test StringCases.convert(
            test_string,
            camel_title_case_num,
            StringCases.SPACE_CASE,
        ) == "q 2ery ǅnterface F Oמࠇ Price 2৶3 Mמ Wz H Rate 2r"
        @test StringCases.convert(
            test_string,
            camel_title_case_acroall_num,
            StringCases.SPACE_CASE,
        ) == "q 2ery ǅnterface FOמࠇ Price 2৶3Mמ Wz H Rate 2r"
        @test StringCases.convert(
            test_string,
            camel_title_case_acrostart_num,
            StringCases.SPACE_CASE,
        ) == "q 2ery ǅnterface FOמࠇPrice 2৶3MמWz HRate 2r"
        @test StringCases.convert(
            test_string,
            camel_title_case_acroend_num,
            StringCases.SPACE_CASE,
        ) == "q 2ery ǅnterfaceFOמࠇ Price 2৶3Mמ WzH Rate 2r"
    end
end
