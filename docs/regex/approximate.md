# Approximative matching

You may or not be know `agrep`. It is basically a "forgiving" `grep` and is, for instance, used for searching through (offline) dictionaries. It is tolerant against errors (up to degree you specify). It may be beneficial is you want to match against domains where you don't really know the pattern. It is just an idea, we will have to see if it is actually useful.

This is a somewhat complicated topic, we'll approach it by examples as it is very complicated to get the head around it by just listening to the specifications.

The approximate matching settings for a subpattern can be changed by appending *approx-settings* to the subpattern. Limits for the number of errors can be set and an expression for specifying and limiting the costs can be given:

## Accepted **insertions** (`+`)

Use `(something){+x}` to specify that the regex should still be matching when `x` characters would need it be *inserted* into the sub-expression `something`.

Example:

- `doubleclick.net` is matched by `^doubleclick\.(nt){+1}$`

The missing `e` in `nt` is inserted.

Similarly:

- `doubleclick.net` is matched by `^(doubleclk\.nt){+3}$`

The missing characters in the domain are substituted. The maximum number of insertions spans the entire domain as is wrapped in the sub-expression `(...)`.

## Accepted **deletions** (`-`)

Use `(something){-x}` to specify that the regex should still be matching when `x` characters would need it be *deleted* from the sub-expression `something`:

Example:

- `doubleclick.net` is matched by `^doubleclick\.(neet){-1}$`

The surplus `e` in `neet` is deleted.

Similarly:

- `doubleclick.net` is matched by `^(doubleclicky\.netty){-3}$`
- `doubleclick.net` is NOT matched by `^(doubleclicky\.nettfy){-3}$`

## Accepted **substitutions** (`#`)

Use `(something){#x}` to specify that the regex should still be matching when `x` characters would need to be *substituted* from the sub-expression `something`:

Example 1:

- `oobargoobaploowap` is matched by `(foobar){#2~2}`
Hint: `goobap` is `foobar` with two substitutions `f->g` and `r->p`

Example 2:

- `doubleclick.net` is matched by `^doubleclick\.n(tt){#1}$`

The incorrect `t` in `ntt` is substituted. Note that substitutions are necessary when a character needs to be replaced as the corresponding realization with one insertion and one deletion is **not identical**:

`doubleclick.net` is matched by `^doubleclick\.n(tt){+1-1}$`

(`t` is removed, `e` is added), however

- `doubleclick.nt` is ALSO matched by `^doubleclick\.n(tt){+1-1}$`

(the `t` is just removed, nothing had to be added) but

- `doubleclick.nt` is NOT matched by `^doubleclick\.n(tt){#1}$`

doesn't match as substitutions always require characters to be swapped by others.

## Combinations and total error limit (`~`)

All rules from above can be combined like as `{+2-5#6}` allowing (up to!) two insertions, five deletions, and six substitutions. You can enforce an upper limit on the number of tried realizations using the tilde. Even when `{+2-5#6}` can lead to up to 13 operations being tried, this can be limited to (at most) seven tries using `{+2-5#6~7}`.

Example:

- `oobargoobploowap` is matched by `(foobar){+2#2~3}`

    Hint: `goobaap` is `foobar` with
            - two substitutions `f->g` and `r->p`, and
            - one addition `a` between `bar` (to have `baap`)

Specifying `~2` instead of `~3` will lead to no match as three errors need to be corrected in total for a match in this example.

## Advanced topic: Cost-equation

You can even weight the "costs" of insertions, deletions or substitutions. This is really an advanced topic and should only be touched when really needed.

A *cost-equation* can be thought of as a mathematical equation, where `i`, `d`, and `s` stand for the number of insertions, deletions, and substitutions, respectively. The equation can have a multiplier for each of `i`, `d`, and `s`.
The multiplier is the **cost of the error**, and the number after `<` is the maximum allowed total cost of a match. Spaces and pluses can be inserted to make the equation more readable. When specifying only a cost equation, adding a space after the opening `{` is **required** .

Example 1: `{ 2i + 1d + 2s < 5 }`

This sets the cost of an insertion to two, a deletion to one, a substitution to two, and the maximum cost to five.

Example 2: `{+2-5#6, 2i + 1d + 2s < 5 }`

This sets the cost of an insertion to two, a deletion to one, a substitution to two, and the maximum cost to five. Furthermore, it allows only up to 2 insertions (coming at a total cost of 4), five deletions and up to 6 substitutions. As six substitutions would come at a cost of `6*2 = 12`, exceeding the total allowed costs of 5, they cannot all be realized.
