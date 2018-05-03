A regular expression, or regex for short, is a pattern that can be used for building arbitrarily complex blocking rules in *FTL*DNS.
We implement the Extended Regular Expressions flavor similar to the one used by the UNIX `egrep` (or `grep -E`) command.

Obviously, this brief description cannot explain everything there is to know about regular expressions. For detailed information, consult one of the excelent regular expressions tutorial that are available online.

## Language implementation
We provide a short cheat sheet for our regular expressions implementation that may come in handy when designing blocking rules. Note that this table is not complete and will be extended over time.

### Character classes
Expression | Meaning | Example
------------ | ------------- | -----------
`*` | Match zero, one or more of the previous  | Ah* matches "Ahhhhh" or "A"
`?` | Match zero or one of the previous  | Ah? matches "Al" or "Ah"
`+` | Match one or more of the previous  | Ah+ matches "Ah" or "Ahhh" but not "A"
`\` | Used to escape a special character  | Hungry\? matches "Hungry?"
`.` | Wildcard character, matches any character  | `do.*` matches "do", dog", "door", "dot", etc.
| | `do.+` matches "dog", "door", "dot", etc. but not "do" (at wildcard with `+` requires to match at least one extra character)
`( )` | Group | See below example for alternation (`|`)
`|` | Alternation | `(Mon|Tues)day` matches "Monday" or "Tuesday" but not "Friday" or "Mond"
`[ ]` | Matches a range of characters  | `[cbf]ar` matches "car", "bar", or "far"
| | `[0-9]+`  matches any positive integer
| | `[a-zA-Z]` |  matches ascii letters a-z (uppercase and lower case)
| | `[^0-9]` |  matches any character not 0-9.
`{ }` | Matches a specified number of occurrences of the previous  | `[0-9]{3}` matches any three-digit number like "315" but not "31"
| | `[0-9]{2,4}` matches two- to four-digit numbers like "12", "123", and "1234" but not "1" or "12345"
| | `[0-9]{2,}` matches any number with two or more digits like "1234567", "123456789", but not "1"
`^`  | Beginning of string | `^client` matches strings that begin with "client", such as `client.server.com` but not `more.client.server.com`
| Exception: within a character range (`[]`) `^` means negation | `[^0-9]` matches any character not 0-9.
`$` | End of string | `ing$` matches "exciting" but not "ingenious"


### Example
We compiled an example to demonstrate the power of regex-based blocking:

Consider the following regex:
```
^ab.+\.com$
```
This pattern will block all domains that start with "ab" (`^ab`), have at least one further character (`.+`) and end in ".com" (`\.com$`).

Examples for what would be blocked by this rule:

  - `abc.com`
  - `abtest.com`
  - `ab.test.com`
  - `abr-------.whatever.com`

Examples for what would not be blocked by this rule:

  - `testab.com` (the domain doesn't start with "ab")
  - `tab.test.com` (the domain doesn't start with "ab")
  - `ab.com` (there is no character in between "ab" and ".com")
  - `test.com.something` (the domain doesn't end in ".com")
