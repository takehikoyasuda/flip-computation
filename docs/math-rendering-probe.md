# GitHub math rendering probe

A throwaway file for finding out what GitHub's markdown renderer actually does
with LaTeX math, so that the choice of format for `IMPLEMENTATION.md` can be made
from observation rather than guesswork.

**How to read it.** Each numbered item shows the source in a code block and then
the live version immediately below. If the live version looks like the code
block, that construct is broken. Note the numbers that fail.

Delete this file once the question is settled.

---

## A. The symbols that prompted the question

### 1. Blackboard bold via `\mathbb`

```
$\mathbb{P}^3$, $\mathbb{Q}$, $\mathbb{Z}$, $\mathbb{R}$, $\mathbb{A}^3$
```

$\mathbb{P}^3$, $\mathbb{Q}$, $\mathbb{Z}$, $\mathbb{R}$, $\mathbb{A}^3$

### 2. The same as Unicode (what `IMPLEMENTATION.md` currently does)

```
$ℙ^3$, $ℚ$, $ℤ$, $ℝ$, $𝔸^3$
```

$ℙ^3$, $ℚ$, $ℤ$, $ℝ$, $𝔸^3$

### 3. Script letters via `\mathcal`

```
$\mathcal{O}_X(-kmE)$ and $\mathcal{F}$
```

$\mathcal{O}_X(-kmE)$ and $\mathcal{F}$

### 4. The same as Unicode

```
$𝒪_X(-kmE)$
```

$𝒪_X(-kmE)$

### 5. Direct sums

```
$A \oplus B$, and $\bigoplus_{k \geq 0} \mathcal{O}_X(-kmE)$
```

$A \oplus B$, and $\bigoplus_{k \geq 0} \mathcal{O}_X(-kmE)$

### 6. The same as Unicode

```
$A ⊕ B$, and $⊕_{k \geq 0} 𝒪_X(-kmE)$
```

$A ⊕ B$, and $⊕_{k \geq 0} 𝒪_X(-kmE)$

### 7. Fraktur, and operator names

```
$\mathfrak{p}_i$, $\operatorname{Proj} R$, $\mathrm{Proj}\, R$, $\dim Z$
```

$\mathfrak{p}_i$, $\operatorname{Proj} R$, $\mathrm{Proj}\, R$, $\dim Z$

---

## B. Does the context matter?

Same expression, six places. GitHub's math parsing is reported to be uneven
across block types; this is where to look if item 1 rendered but the real
document did not.

### 8. In a plain paragraph

The flip is $Z = \mathrm{Proj}_X \bigoplus_k \mathcal{O}_X(-kmE)$, as expected.

### 9. In a bulleted list

- first, $K_X = \sum_i n_i D_i$
- second, $I^{(m)} = \mathcal{O}_X(-mE)$

### 10. In a numbered list

1. first, $K_X = \sum_i n_i D_i$
2. second, $I^{(m)} = \mathcal{O}_X(-mE)$

### 11. In a table

| construct | inline math | more |
|---|---|---|
| canonical | $K_X = \sum_i n_i D_i$ | $-K_X$ ample |
| ideal | $I^{(m)} = \mathcal{O}_X(-mE)$ | $\mathbb{P}^{r-1}$ |
| cone | $\langle v_1, v_3, v_4 \rangle$ | $K \cdot C = +1$ |

### 12. In a heading — $K_X = \sum_i n_i D_i$

### 13. In a blockquote

> The flip satisfies $K_Z \cdot C > 0$ on every curve $C$ contracted by $\pi$.

### 14. Next to bold and italic

The **flip** $Z \to X$ is *small*, so $\operatorname{codim} \operatorname{Exc}(\pi) \geq 2$.

### 15. In a nested list

- outer, with $\mathbb{P}^1 \times X$
  - inner, with $\mathcal{O}_X(-E)$
    - deeper, with $\bigoplus_k$

---

## C. Characters that fight with markdown

### 16. Two underscores in one line (could be read as emphasis)

```
$a_1$ and $b_2$ on the same line, then $x_i y_j$
```

$a_1$ and $b_2$ on the same line, then $x_i y_j$

### 17. Underscore and caret together

```
$x^2_i$, $\{x_i\}_{i=1}^{n}$, $I^{(m)}_{\mathrm{sat}}$
```

$x^2_i$, $\{x_i\}_{i=1}^{n}$, $I^{(m)}_{\mathrm{sat}}$

### 18. Asterisks

```
$f_* \mathcal{O}_Y = \mathcal{O}_Z$ and $a * b$
```

$f_* \mathcal{O}_Y = \mathcal{O}_Z$ and $a * b$

### 19. Vertical bars (the table-breaking character)

```
$|a|$, $\lvert a \rvert$, $\{x : |x| < 1\}$
```

$|a|$, $\lvert a \rvert$, $\{x : |x| < 1\}$

### 20. A vertical bar inside a table cell

| what | math |
|---|---|
| absolute value | $\lvert a \rvert$ |
| set | $\{x : \lvert x \rvert < 1\}$ |

### 21. Braces and backslash spacing

```
$\{v_1, v_2\}$, $(1,\, d_i - d_0)$, $a \; b$, $a \quad b$
```

$\{v_1, v_2\}$, $(1,\, d_i - d_0)$, $a \; b$, $a \quad b$

### 22. Dollar signs that are not math

```
The price is \$5 and the variable is $x$.
```

The price is \$5 and the variable is $x$.

---

## D. Display math

### 23. `$$` on a single line

```
$$Z = \mathrm{Proj}_X \bigoplus_{k \geq 0} \mathcal{O}_X(-kmE)$$
```

$$Z = \mathrm{Proj}_X \bigoplus_{k \geq 0} \mathcal{O}_X(-kmE)$$

### 24. `$$` spanning two source lines

```
$$\deg u_i = (1, d_i - d_0), \qquad
\deg x_j = (0, c_j)$$
```

$$\deg u_i = (1, d_i - d_0), \qquad
\deg x_j = (0, c_j)$$

### 25. `$$` on its own lines, content between

```
$$
Z = \mathrm{Proj}_X \bigoplus_{k \geq 0} \mathcal{O}_X(-kmE)
$$
```

$$
Z = \mathrm{Proj}_X \bigoplus_{k \geq 0} \mathcal{O}_X(-kmE)
$$

### 26. The `math` fenced code block

````
```math
Z = \mathrm{Proj}_X \bigoplus_{k \geq 0} \mathcal{O}_X(-kmE)
```
````

```math
Z = \mathrm{Proj}_X \bigoplus_{k \geq 0} \mathcal{O}_X(-kmE)
```

---

## E. Structures — the real test of "freedom"

### 27. `aligned`, with `\\` line breaks

```
$$\begin{aligned}
\deg u_i &= (1,\, d_i - d_0) \\
\deg x_j &= (0,\, c_j) \\
\deg t   &= (1,\, -d_0)
\end{aligned}$$
```

$$\begin{aligned}
\deg u_i &= (1,\, d_i - d_0) \\
\deg x_j &= (0,\, c_j) \\
\deg t   &= (1,\, -d_0)
\end{aligned}$$

### 28. `cases`

```
$$\operatorname{irr} = \begin{cases}
(u_i x_j) & X \text{ projective} \\
(u_1, \dots, u_r) & X \text{ affine}
\end{cases}$$
```

$$\operatorname{irr} = \begin{cases}
(u_i x_j) & X \text{ projective} \\
(u_1, \dots, u_r) & X \text{ affine}
\end{cases}$$

### 29. `pmatrix`

```
$$\begin{pmatrix} 1 & 0 & 0 \\ 0 & 1 & 0 \\ 1 & 3 & -2 \end{pmatrix}, \quad \det = -2$$
```

$$\begin{pmatrix} 1 & 0 & 0 \\ 0 & 1 & 0 \\ 1 & 3 & -2 \end{pmatrix}, \quad \det = -2$$

### 30. `array`

```
$$\begin{array}{lcr}
Y & \to & X \\
Z & \to & X
\end{array}$$
```

$$\begin{array}{lcr}
Y & \to & X \\
Z & \to & X
\end{array}$$

### 31. Equation numbering with `\tag`

```
$$K_Z \cdot C > 0 \tag{1}$$
```

$$K_Z \cdot C > 0 \tag{1}$$

### 32. `align` with automatic numbering (likely unsupported)

```
$$\begin{align}
a &= b \\
c &= d
\end{align}$$
```

$$\begin{align}
a &= b \\
c &= d
\end{align}$$

### 33. `equation` with a `\label` (cross-referencing test)

```
$$\begin{equation}\label{eq:flip} K_Z \cdot C > 0 \end{equation}$$
```

$$\begin{equation}\label{eq:flip} K_Z \cdot C > 0 \end{equation}$$

Referring back to it: does `\eqref{eq:flip}` resolve? $\eqref{eq:flip}$

### 34. Labelled arrows and stacking

```
$$Y \xrightarrow{\ h\ } Z \xrightarrow{\ g\ } X, \qquad
\overset{\text{flip}}{\longrightarrow}, \qquad
\underset{k \geq 0}{\bigoplus}$$
```

$$Y \xrightarrow{\ h\ } Z \xrightarrow{\ g\ } X, \qquad
\overset{\text{flip}}{\longrightarrow}, \qquad
\underset{k \geq 0}{\bigoplus}$$

### 35. `substack` and large operators

```
$$\sum_{\substack{i = 1 \\ i \neq j}}^{n} n_i D_i, \qquad
\varinjlim_k \mathcal{O}_X(-kmE)$$
```

$$\sum_{\substack{i = 1 \\ i \neq j}}^{n} n_i D_i, \qquad
\varinjlim_k \mathcal{O}_X(-kmE)$$

### 36. Text inside math, including Japanese

```
$$Z \text{ is normal and } \pi \text{ is small}$$

$$Z \text{ は正規で } \pi \text{ は small}$$
```

$$Z \text{ is normal and } \pi \text{ is small}$$

$$Z \text{ は正規で } \pi \text{ は small}$$

---

## F. Custom macros — the decisive test

If macros persist from one block to the next, most of the verbosity objection to
markdown disappears. If they do not, every `\operatorname{Proj}` has to be
written out every time.

### 37. Define here

```
$$\newcommand{\Proj}{\operatorname{Proj}}
\newcommand{\Ox}{\mathcal{O}_X}
\Proj R \text{ and } \Ox$$
```

$$\newcommand{\Proj}{\operatorname{Proj}}
\newcommand{\Ox}{\mathcal{O}_X}
\Proj R \text{ and } \Ox$$

### 38. Use in a *later, separate* block

```
$$\Proj_X \bigoplus_{k \geq 0} \Ox(-kmE)$$
```

$$\Proj_X \bigoplus_{k \geq 0} \Ox(-kmE)$$

### 39. Use inline, further down still

Inline use of the same macros: $\Proj R$ and $\Ox$.

### 40. `\def` instead of `\newcommand`

```
$$\def\Kx{K_X} \Kx = \sum_i n_i D_i$$
```

$$\def\Kx{K_X} \Kx = \sum_i n_i D_i$$

Later use of `\def`: $\Kx$

---

## G. Long expressions and wrapping

### 41. A wide display formula (does it overflow or scroll?)

$$Z^m = \mathrm{Proj} \, R[I^{(m)}t] = \mathrm{Proj} \bigoplus_{k \geq 0} I^{(mk)} t^k \longrightarrow X = \mathrm{Proj}\, R, \qquad I^{(m)} = \mathcal{O}_X(-mE), \qquad E = \operatorname{div}(s) - K_X$$

### 42. Inline math that is nearly a full line

The condition is $\operatorname{codim} \operatorname{Exc}(\pi) \geq 2$ together with $\operatorname{codim} \operatorname{Ext}^j(A, S) \geq j + 2$ for every $j > \operatorname{codim} I$, which is Serre's $S_2$ on the source.

---

## What to record

For each failing number, note *how* it failed:

- **raw** — the LaTeX source is shown verbatim, not typeset
- **wrong** — it typesets but the output is not what was written
- **partial** — some of the line typesets and some does not

The interesting comparisons are **1 against 2**, **3 against 4**, **5 against 6**
(is the Unicode workaround actually necessary?), the whole of **section B**
(is the problem the construct or the context?), and **37–40** (do macros
persist?). Section E decides whether markdown can carry the structure of a
mathematical document at all.
