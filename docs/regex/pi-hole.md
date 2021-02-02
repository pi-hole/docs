# Pi-hole regex extensions

## Only match specific query types

You can amend the regular expressions by special keywords added at the end to fine-tine regular expressions to match only specific query types.

Example:

``` plain
abc;querytype=AAAA
```

will block

``` bash
dig AAAA abc
```

but not

``` bash
dig A abc
```

This allows you to do query type based black-/whitelisting. Some user-provided examples are:

- `.*;querytype=!A`
  
    A regex blacklist entry for blocking `AAAA` (in fact, everything else than `A`, call it "anti-`A`") requests for all clients assigned to the same group. This has been mentioned to be benefitial for devices like Chromecast. You may want to fine-tune this further to specific domains.

- `.*;querytype=PTR`
  
    A regex whitelist entry used to permit `PTR` lookups with the above "anti-`A`" regex

- `.*;querytype=ANY`
  
    A regex blacklist entry to block `ANY` request network wide.

## Invert matching

Sometimes, it may be useful to be able to invert a regular expression altogether. Hence, we added the keyword `;invert` to achieve exactly this.

For instance,

``` plain
^abc$;querytype=AAAA;invert
```

will not block `abc` with type `AAAA` (but everything else) for the clients assigned to the same groups. This inversion is independent for the query type, e.g.

``` plain
^abc$;invert
```

will block **not** block `abc` but **everything else**.

## Comments

You can specify comments withing your regex using the syntax

``` plain
(?#some comment here)
```

The comment can contain any characters except for a closing parenthesis `)` (for the sole reason being the terminating element). The text in the comment is completely ignored by the regex parser and it used solely for readability purposes.

``` plain
$ pihole-FTL regex-test "doubleclick.net" "(^|\.)doubleclick\.(?#TODO: We need to maybe support more than just .net here)net$"

FTL Regex test:
  Domain: "doubleclick.net"
   Regex: "(^|\.)doubleclick\.(?#TODO: We need to maybe support more than just .net here)net$"
Step 1: Compiling regex filter...
        Compiled regex filter in 0.167 msec
Step 2: Checking domain...
        Done in 0.032 msec

MATCH
```

## Back-references

A back reference is a backslash followed by a single non-zero decimal digit `d`. It matches *the same sequence* of characters matched by the `d`th parenthesized subexpression.

Example:

``` plain
"cat.foo.dog---cat%dog!foo" is matched by "(cat)\.(foo)\.(dog)---\1%\3!\2"
```

Another (more complex example is):

``` plain
(1234|4321)\.(foo)\.(dog)--\1
```

``` plain
   MATCH: 1234.foo.dog--1234
   MATCH: 4321.foo.dog--4321
NO MATCH: 1234.foo.dog--4321
```

Mind that the last line gives no match as `\1` matches **exactly** the same sequence the first character group matched. And `4321` is not the same as `1234` even when both are valid replies for `(1234|4321)` Back references are not defined for POSIX EREs (for BREs they are, surprisingly enough). We add them to ERE in the BRE style.

``` plain
$ pihole-FTL regex-test "someverylongandmaybecomplexthing.foo.dog--someverylongandmaybecomplexthing" "(someverylongandmaybecomplexthing|somelesscomplexitem)\.(foo)\.(dog)--\1"

FTL Regex test:
  Domain: "someverylongandmaybecomplexthing.foo.dog--someverylongandmaybecomplexthing"
   Regex: "(someverylongandmaybecomplexthing|somelesscomplexitem)\.(foo)\.(dog)--\1"
Step 1: Compiling regex filter...
        Compiled regex filter in 0.563 msec
Step 2: Checking domain...
        Done in 0.031 msec

MATCH
```

## More character classes for bracket expressions

A bracket expression specifies a set of characters by enclosing a nonempty list of items in brackets. Normally anything matching any item in the list is matched. If the list begins with `^` the meaning is negated; any character matching no item in the list is matched.

1. Multiple characters: `[abc]` matches `a`, `b`, and `c`.
2. Character ranges: `[0-9]` matches any decimal digit.
3. Character classes:
    - `[:alnum:]` alphanumeric characters
    - `[:alpha:]` alphabetic characters
    - `[:blank:]` blank characters
    - `[:cntrl:]` control characters
    - `[:digit:]` decimal digits (0 - 9)
    - `[:graph:]` all printable characters except space
    - `[:lower:]` lower-case letters (FTL matches case-insensitive by default)
    - `[:print:]` printable characters including space
    - `[:punct:]` printable characters not space or alphanumeric
    - `[:space:]` white-space characters
    - `[:upper:]` upper case letters (FTL matches case-insensitive by default)
    - `[:xdigit:]` hexadecimal digits

Furthermore, there are two shortcurts for some character classes:

- `\d` - Digit character (equivalent to `[[:digit:]]`)
- `\D` - Non-digit character (equivalent to `[^[:digit:]]`)

{!abbreviations.md!}
