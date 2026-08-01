# GitHub math rendering probe, round 2: workarounds

Round 1 found two separate faults:

1. **Backslash-punctuation is eaten before the math is typeset.** `\,` came out
   as a comma, `\{` `\}` vanished, and `\\` was lost, so `cases` and `pmatrix`
   ran onto one line. All of these are `\` followed by an ASCII punctuation
   character, which markdown treats as an escape.
2. **Some commands are simply unsupported**: `\mathbb`, `\mathcal`, `\mathfrak`,
   `\operatorname` — while `\mathrm` works. Since `\mathrm{Proj}` and
   `\operatorname{Proj}` both take a braced argument, braces are not the problem.

This round tests whether either fault has a workaround. Same format: source in a
code block, live version below.

---

## A. Doubling the backslash

If fault 1 is markdown's escape rule, then writing two backslashes should leave
one for the typesetter.

### 1. Thin space

```
plain:  $a \, b$
doubled: $a \\, b$
```

plain: $a \, b$

doubled: $a \\, b$

### 2. Braces

```
plain:   $\{v_1, v_2\}$
doubled: $\\{v_1, v_2\\}$
lbrace:  $\lbrace v_1, v_2 \rbrace$
```

plain: $\{v_1, v_2\}$

doubled: $\\{v_1, v_2\\}$

lbrace: $\lbrace v_1, v_2 \rbrace$

### 3. Line break in `aligned` — doubled

```
$$\begin{aligned}
a &= b \\\\
c &= d
\end{aligned}$$
```

$$\begin{aligned}
a &= b \\\\
c &= d
\end{aligned}$$

### 4. Line break in `aligned` — `\cr` instead

```
$$\begin{aligned}
a &= b \cr
c &= d
\end{aligned}$$
```

$$\begin{aligned}
a &= b \cr
c &= d
\end{aligned}$$

### 5. `cases` with doubled backslashes

```
$$x = \begin{cases}
1 & \text{if } a \\\\
0 & \text{otherwise}
\end{cases}$$
```

$$x = \begin{cases}
1 & \text{if } a \\\\
0 & \text{otherwise}
\end{cases}$$

### 6. `pmatrix` with doubled backslashes

```
$$\begin{pmatrix} 1 & 0 \\\\ 0 & 1 \end{pmatrix}$$
```

$$\begin{pmatrix} 1 & 0 \\\\ 0 & 1 \end{pmatrix}$$

### 7. Spacing without backslashes at all

```
$a \quad b$ and $a \qquad b$ and $a \: b$ and $a \; b$
```

$a \quad b$ and $a \qquad b$ and $a \: b$ and $a \; b$

---

## B. Substitutes for the unsupported font commands

### 8. Blackboard bold, four ways

```
mathbb:  $\mathbb{P}^3$
no brace: $\mathbb P^3$
Bbb:     $\Bbb{P}^3$
unicode: $ℙ^3$
```

mathbb: $\mathbb{P}^3$

no brace: $\mathbb P^3$

Bbb: $\Bbb{P}^3$

unicode: $ℙ^3$

### 9. Script, four ways

```
mathcal:  $\mathcal{O}_X$
no brace: $\mathcal O_X$
mathscr:  $\mathscr{O}_X$
unicode:  $𝒪_X$
```

mathcal: $\mathcal{O}_X$

no brace: $\mathcal O_X$

mathscr: $\mathscr{O}_X$

unicode: $𝒪_X$

### 10. Fraktur

```
mathfrak: $\mathfrak{p}_i$
frak:     $\frak{p}_i$
unicode:  $𝔭_i$
```

mathfrak: $\mathfrak{p}_i$

frak: $\frak{p}_i$

unicode: $𝔭_i$

### 11. Operator names

```
operatorname: $\operatorname{Proj} R$
mathrm:       $\mathrm{Proj}\ R$
text:         $\text{Proj } R$
mbox:         $\mbox{Proj } R$
```

operatorname: $\operatorname{Proj} R$

mathrm: $\mathrm{Proj}\ R$

text: $\text{Proj } R$

mbox: $\mbox{Proj } R$

### 12. Which font commands *do* work?

```
$\mathrm{A}$, $\mathbf{A}$, $\mathit{A}$, $\mathsf{A}$, $\mathtt{A}$, $\boldsymbol{A}$
```

$\mathrm{A}$, $\mathbf{A}$, $\mathit{A}$, $\mathsf{A}$, $\mathtt{A}$, $\boldsymbol{A}$

### 13. Spacing after an upright operator

```
$\mathrm{Proj} R$ versus $\mathrm{Proj}\ R$ versus $\mathrm{Proj}~R$
```

$\mathrm{Proj} R$ versus $\mathrm{Proj}\ R$ versus $\mathrm{Proj}~R$

---

## C. Does the fenced `math` block behave differently?

The fenced block is not inline markdown, so the escape rule may not apply there.
If it does not, this is the escape hatch: write every display formula as a fence.

### 14. Backslash-punctuation inside a `math` fence

````
```math
\begin{aligned}
\deg u_i &= (1,\, d_i - d_0) \\
\deg x_j &= (0,\, c_j)
\end{aligned}
```
````

```math
\begin{aligned}
\deg u_i &= (1,\, d_i - d_0) \\
\deg x_j &= (0,\, c_j)
\end{aligned}
```

### 15. `cases` inside a `math` fence, single backslashes

````
```math
x = \begin{cases}
1 & \text{if } a \\
0 & \text{otherwise}
\end{cases}
```
````

```math
x = \begin{cases}
1 & \text{if } a \\
0 & \text{otherwise}
\end{cases}
```

### 16. `pmatrix` and set braces inside a `math` fence

````
```math
\begin{pmatrix} 1 & 0 & 0 \\ 0 & 1 & 0 \\ 1 & 3 & -2 \end{pmatrix},
\qquad \{v_1, v_2\}, \qquad \mathbb{P}^3, \qquad \operatorname{Proj} R
```
````

```math
\begin{pmatrix} 1 & 0 & 0 \\ 0 & 1 & 0 \\ 1 & 3 & -2 \end{pmatrix},
\qquad \{v_1, v_2\}, \qquad \mathbb{P}^3, \qquad \operatorname{Proj} R
```

---

## What this decides

- **If section A works** (doubled backslashes, or the `\cr` variant): markdown is
  usable, but every formula has to be written in a dialect that is not LaTeX, and
  the source can no longer be pasted into the paper. Workable, unpleasant.
- **If section C works** while the `$$` forms do not: write all display math as
  ` ```math ` fences and keep ordinary LaTeX inside them. This would be the good
  outcome — real LaTeX source, correct output, no dialect.
- **If neither works**: markdown cannot carry this document, and the choice is
  between Quarto and plain LaTeX.

Section B decides the notation regardless: if `\mathbb` and `\operatorname` never
work, the document has to use `\mathrm` and Unicode letters throughout, which is
survivable but means the source again differs from the paper's.
