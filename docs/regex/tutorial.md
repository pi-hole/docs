# Pi-hole regular expressions tutorial

We provide a short but thorough introduction to our regular expressions implementation. This may come in handy if you are designing blocking or whitelisting rules (see also our cheat sheet below!). In our implementation, all characters match themselves except for the following special characters: `.[{}()\*+?|^$`. If you want to match those, you need to escape them like `\.` for a literal period, but no rule without exception (see character groups below for further details).

## Anchors (`^` and `$`)

First of all, we look at anchors that can be used to indicate the start or the end of a domain, respectively. If you don't specify anchors, the match may be partial (see examples below).

Example | Interpretation
--- | ---
`domain` | **partial match**. Without anchors, a text may appear anywhere in the domain. This matches `some.domain.com`, `domain.com` and `verylongdomain.com` and more
`^localhost$` | **exact match** matching *only* `localhost` but neither `a.localhost` nor `localhost.com`
`^abc` | matches any domain **starting** (`^`) in "abc" like `abcdomain.com`, `abc.domain.com` but not `def.abc.com`
`com$` | matches any domain **ending** (`$`) in "com" such as `domain.com` but not `domain.com.co.uk`

## Wildcard (`.`)

An unescaped period stands for any *single* character.

Example | Interpretation
--- | ---
`^domain.$` | matches `domaina`, `domainb`, `domainc`, but not `domain`

## Bounds and multipliers (`{}`, `*`, `+`, and `?`)

With bounds, one can denote the number of times something has to occur:

Bound | Meaning
--- | ---
`ab{4}` | matches a domain that contains a single `a` followed by four `b` (matching only `abbbb`)
`ab{4,}` | matches a domain that contains a single `a` followed by *at least* four `b` (matching also `abbbbbbbb`)
`ab{3,5}` | matches a domain that contains a single `a` followed by three to five `b` (matching only `abbb`, `abbbb`, and `abbbbb`)

Multipliers are shortcuts for some of the bounds that are needed most often:

Multipliers | Bounds equivalent | Meaning
--- | --- | ---
`?` | `{0,1}` | never or once (optional)
`*` | `{0,}` | never or more (optional)
`+` | `{1,}` | once or more (mandatory)

To illustrate the usefulness of multipliers (and bounds), we provide a few examples:

Example | Interpretation
--- | ---
`^r-*movie` | matches a domain like `r------movie.com` where the number of dashes can be arbitrary (also none)
`^r-?movie` | matches only the domains `rmovie.com` and `r-movie.com` but not those with more than one dash
`^r-+movie` | matches only the domains with at least one dash, i.e., not `rmovie.com`
`^a?b+` | matches domains like `abbbb.com` (zero or one `a` at the beginning followed by one or more `b`)

## Character groups (`[]`)

With character groups, a set of characters can be matched:

Character group | Interpretation
--- | ---
`[abc]` | matches `a`, `b`, or `c` (using explicitly specified characters)
`[a-c]` | matches `a`, `b`, or `c` (using a *range*)
`[a-c]+` | matches any non-zero number of `a`, `b`, `c`
`[a-z]` | matches any single lowercase letter
`[a-zA-Z]` | matches any single letter
`[a-z0-9]` | matches any single lowercase letter or any single digit
`[^a-z]` | **Negation** matching any single character *except* lowercase letters
`abc[0-9]+` | matches the string `abc` followed by a number of arbitrary length

Bracket expressions are an exception to the character escape rule. Inside them, all special characters, including the backslash (`\`), lose their special powers, i.e. they match themselves exactly. Furthermore, to include a literal `]` in the list, make it the first character (like `[]]` or `[^]]` if negated). To include a literal `-`, make it the first or last character, or the second endpoint of a range (e.g. `[a-z-]` to match `a` to `z` and `-`).

## Groups (`()`)

Using groups, we can enclose regular expressions, they are most powerful when combined with bounds or multipliers (see also alternations below).

Example | Interpretation
--- | ---
`(abc)` | matches `abc` (trivial example)
`(abc)*` | matches zero or more copies of `abc` like `abcabc` but not `abcdefabc`
`(abc){1,3}` | matches one, two or three copies of `abc`: `abc`, `abcabc`, `abcabcabc` but nothing else

## Alternations (`|`)

Alternations can be used as an "or" operator in regular expressions.
<!-- markdownlint-disable MD056 -->
Example | Interpretation
--- | ---
`(abc)|(def)` | matches `abc` *and* `def`
`domain(a|b)\.com` | matches `domaina.com` and `domainb.com` but not `domain.com` or `domainx.com`
`domain(a|b)*\.com` | matches `domain.com`, `domainaaaa.com` `domainbbb.com` but not `domainab.com` (any number of `a` or `b` in between `domain` and `.com`)
<!-- markdownlint-enable MD056 -->
## Character classes (`[:class:]`)

In addition to character groups, there are also some special character classes available, such as

Character class | Group equivalent | Pi-hole specific | Interpretation
--------------- | ---------------- | ---------------- | ---------------
`[:digit:]` | `[0-9]` | No | matches digits
`[:lower:]` | `[a-z]` | No | matched lowercase letters(FTL matches case-insensitive by default)
`[:upper:]` | `[A-Z]` | No | matched uppercase letters(FTL matches case-insensitive by default)
`[:alpha:]` | `[A-Za-z]` | No | matches alphabetic characters
`[:alnum:]` | `[A-Za-z0-9]` | No | matches alphabetic characters and digits
`[:blank:]` | `[ \t]` | Yes | blank characters
`[:cntrl:]` | N/A | Yes | control characters
`[:graph:]` | N/A | Yes | all printable characters except space
`[:print:]` | N/A | Yes | printable characters including space
`[:punct:]` | N/A | Yes | printable characters not space or alphanumeric
`[:space:]` | `[ \f\n\r\t\v]` | Yes | white-space characters
`[:xdigit:]` | `[0-9a-fA-F]` | Yes | hexadecimal digits

# Advanced examples

After going through our quick tutorial, we provide some more advanced examples so you can test your knowledge.

## Block domain with only numbers

```
^[0-9][^a-z]+\.((com)|(edu))$
```

Blocks domains containing only numbers (no letters) and ending in `.com` or `.edu`. This blocks `555661.com`, and `456.edu`, but not `555g555.com`

### Block domains without subdomains

```
^[a-z0-9]+([-]{1}[a-z0-9]+)*\.[a-z]{2,7}$
```

A domain name shall not start or end with a dash but can contain any number of them. It must be followed by a TLD (we assume a valid TLD length of two to seven characters)

# Cheatsheet
<!-- markdownlint-disable MD056 -->
Expression | Meaning | Example
------------ | ------------- | -----------
`^`  | Beginning of string | `^client` matches strings that begin with `client`, such as `client.server.com` but not `more.client.server.com` (exception: within a character range (`[]`) `^` means negation)
`$` | End of string | `ing$` matches `exciting` but not `ingenious`
`*` | Match zero or more of the previous | `ah*` matches `ahhhhh` or `a`
`?` | Match zero or one of the previous | `ah?` matches `a` or `ah`
`+` | Match one or more of the previous | `ah+` matches `ah` or `ahhh` but not `a`
`.` | Wildcard character, matches any character  | `do.*` matches `do`, `dog`, `door`, `dot`, etc.;<br>`do.+` matches `dog`, `door`, `dot`, etc. but not `do` (wildcard with `+` requires at least one extra character for matching)
`( )` | Group | Enclose regular expressions, see the example for `|`
`|` | Alternation | `(mon|tues)day` matches `monday` or `tuesday` but not `friday` or `mondiag`
`[ ]` | Matches a range of characters  | `[cbf]ar` matches `car`, `bar`, or `far`;
`[^]`| Negation | `[^0-9]` matches any character *except* `0` to `9`
`{ }` | Matches a specified number of occurrences of the previous  | `[0-9]{3}` matches any three-digit number like `315` but not `31`;<br>`[0-9]{2,4}` matches two- to four-digit numbers like `12`, `123`, and `1234` but not `1` or `12345`;<br>`[0-9]{2,}` matches any number with two or more digits like `1234567`, `123456789`, but not `1`
`\` | Used to escape a special character not inside `[]` | `google\.com` matches `google.com`
<!-- markdownlint-enable MD056 -->
