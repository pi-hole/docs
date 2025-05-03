# Approximate matching

You may or may not know `agrep`, it is basically a "forgiving" `grep` and is, for instance, used for searching through (offline) dictionaries. It is tolerant against errors up to a degree you specify. It may be beneficial if you want to match against domains where you don't really know the pattern. It is just an idea, we will have to see if it is actually useful.

This is a somewhat complicated topic, we'll approach it by examples as it is very complicated to get your head around it by just listening to the specifications.

The approximate matching settings for a subpattern can be changed by appending *approx-settings* to the subpattern. Limits for the number of errors can be set and an expression for specifying and limiting the costs can be given:

## Accepted **insertions** (`+`)

Use `(something){+x}` to specify that the regex should still match when `x` characters would need to be *inserted* into the sub-expression `something`.

Example:

- `doubleclick.net` is matched by `^doubleclick\.(nt){+1}$`

The missing `e` in `nt` is inserted.

Similarly:

- `doubleclick.net` is matched by `^(doubleclk\.nt){+3}$`

The missing characters in the domain are substituted. The maximum number of insertions spans the entire domain as is wrapped in the sub-expression `(...)`.

## Accepted **deletions** (`-`)

Use `(something){-x}` to specify that the regex should still match when `x` characters would need to be *deleted* from the sub-expression `something`:

Example:

- `doubleclick.net` is matched by `^doubleclick\.(neet){-1}$`

The surplus `e` in `neet` is deleted.

Similarly:

- `doubleclick.net` is matched by `^(doubleclicky\.netty){-3}$`
- `doubleclick.net` is **not** matched by `^(doubleclicky\.nettfy){-3}$`

## Accepted **substitutions** (`#`)

Use `(something){#x}` to specify that the regex should still match when `x` characters would need to be *substituted* in the sub-expression `something`:

Example 1:

- `oobargoobaploowap` is matched by `(foobar){#2}`
    - Hint: `goobap` is `foobar` with `f` substituted for `g` and `r` substituted for `p`

Example 2:

- `doubleclick.net` is matched by `^doubleclick\.n(tt){#1}$`

The incorrect `t` in `ntt` is substituted. Note that substitutions are necessary when a character needs to be replaced as the following example (with 1 insertion and 1 deletion) is **not identical**:

- `doubleclick.net` is matched by `^doubleclick\.n(tt){+1-1}$`

(`t` is removed, `e` is added), however

- `doubleclick.nt` is **also** matched by `^doubleclick\.n(tt){+1-1}$`

(the `t` is removed but nothing has to be added) but

- `doubleclick.nt` is **not** matched by `^doubleclick\.n(tt){#1}$`

doesn't match as substitutions always require characters to be replaced by others.

## Combinations and total error limit (`~`)

All rules from above can be combined, for example `{+2-5#6}` allows up to 2 insertions, 5 deletions, and 6 substitutions. You can enforce an upper limit on the number of attempted operations using `~x`, for example even though `{+2-5#6}` can lead to up to 13 operations being tried, this can be limited to at most 7 operations using `{+2-5#6~7}`.

Example:

- `oobargoobploowap` is matched by `(foobar){+2#2~3}`
    - Hint: `goobaap` is `foobar` with
        - 2 substitutions (`f` to `g` and `r` to `p`)
        - 1 addition (`a` in `bar` to make `baap`)

Specifying `~2` instead of `~3` will not match as there are 3 errors which need to be corrected in this example.

## Advanced topic: Cost-equation

You can even weight the "costs" of insertions, deletions or substitutions. This is an advanced topic and should only be touched when really needed.

A *cost-equation* can be thought of as a mathematical equation where `i`, `d`, and `s` stand for the number of insertions, deletions, and substitutions respectively. The equation can have a multiplier for each of `i`, `d`, and `s`.
The multiplier is the **cost of the error**, and the number after `<` is the maximum allowed total cost of a match. Spaces and pluses can be inserted to make the equation more readable. When specifying only a cost equation, adding a space after the opening `{` is **required**.

Example 1:

- `{ 2i + 1d + 2s < 5 }`

This sets the cost of an insertion to 2, a deletion to 1, a substitution to 2, and the maximum cost to 5.

Example 2:

- `{ +2-5#6, 2i + 1d + 2s < 5 }`

This sets the cost of an insertion to 2, a deletion to 1, a substitution to 2, and the maximum cost to 5. Furthermore, it allows only up to 2 insertions (for a total cost of 4), up to 5 deletions, and up to 6 substitutions. As 6 substitutions would come at a cost of `6*2 = 12`, exceeding the total allowed costs of 5, they cannot all be performed.
