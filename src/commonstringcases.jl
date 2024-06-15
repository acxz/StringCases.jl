# Delimiter String Cases
const TITLE_CASE = DelimiterStringCase("Title Case", lowercase, titlecase, titlecase, " ")
const LENIENT_TITLE_CASE =
    DelimiterStringCase("LEnient Title Case", anycase, titlecase, titlecase, " ")
const SENTENCE_CASE =
    DelimiterStringCase("Sentence case", lowercase, lowercase, uppercase, " ")
const SNAKE_CASE = DelimiterStringCase("snake_case", lowercase, lowercase, lowercase, "_")
const SCREAMING_SNAKE_CASE =
    DelimiterStringCase("SCREAMING_SNAKE_CASE", uppercase, uppercase, uppercase, "_")
const KEBAB_CASE = DelimiterStringCase("kebab-case", lowercase, lowercase, lowercase, "-")
const COBOL_CASE = DelimiterStringCase("COBOL-CASE", uppercase, uppercase, uppercase, "-")
const ADA_CASE = DelimiterStringCase("Ada_Case", lowercase, uppercase, uppercase, "_")
const TRAIN_CASE = DelimiterStringCase("Train-Case", lowercase, uppercase, uppercase, "-")
const SPACE_CASE = DelimiterStringCase("space case", anycase, anycase, anycase, " ")
const PATH_CASE = DelimiterStringCase("path/case", anycase, anycase, anycase, "/")
const DOT_CASE = DelimiterStringCase("dot.case", anycase, anycase, anycase, ".")

# Pattern String Cases
const FLAT_CASE = PatternStringCase("flatcase", lowercase, lowercase, lowercase)
const UPPER_FLAT_CASE = PatternStringCase("UPPERFLATCASE", uppercase, uppercase, uppercase)
const PASCAL_CASE = PatternStringCase("PascalCase", lowercase, uppercase, uppercase)
const CAMEL_CASE = PatternStringCase("camelCase", lowercase, uppercase, lowercase)
const CAMEL_TITLE_CASE =
    PatternStringCase("camelTitleCase", lowercase, titlecase, lowercase)

const CAMEL_CASE_ACRO_NUM = PatternStringCase(
    "camelCaseACRO123",
    lowercase,
    uppercase,
    lowercase,
    acro_all_of_token,
    true,
)
