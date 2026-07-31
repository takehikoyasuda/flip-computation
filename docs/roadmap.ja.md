# 開発計画（引き継ぎ用メモ）

作成日: 2026-07-31。別の PC で作業を継続するための覚書。
対象論文: T. Yasuda, *An algorithm for the minimal model program in dimension three*,
[arXiv:2603.13703](https://arxiv.org/abs/2603.13703)、第7章 Algorithm 3。

## 1. 現状

以下が動いている（テスト7件、`M2 --script tests/run-tests.m2` が約1秒で通過）。

* `FlipComputation.m2` + `FlipComputation/{basics,divisors,rees,segre,flip,doc}.m2`
* Algorithm 3 の Step 1–5 を実装（`computeFlip`）
* Lemma 2.6 の B2M projection → graph morphism 変換（`b2mToGraphMorphism`）
* 局所（アフィン）版サポート（`BaseIsProjective => false`）
* テスト内容
  * 3次元 ODP の small resolution が正規かつ small と判定される（射影版・アフィン版）
  * P^3 の点のブローアップ／A^3 の原点のブローアップが small でないと判定される
  * K_{P^3} = -4H
  * Segre 積の Hilbert 基底の個数
  * graph morphism 変換後の次元
  * **トーリックなフリップの例を端から端まで検証**（下記）
* `examples/ordinary-double-point.m2`、`examples/toric-flip.m2`、
  `docs/implementation-notes.md`

**本物のフリップでの検証は完了した。** 非 Q-Gorenstein トーリック3-fold
`sigma = cone((1,0,0),(0,1,0),(0,0,1),(1,1,-2))` に対し、`computeFlip` が m = 1 で
フリップを返し、その扇が期待される三角形分割 `<v1,v3,v4>, <v2,v3,v4>` に一致すること、
例外集合が曲線であること、K_Z が π-ample であること（フリップであってアンチフリップ
でないこと）まで確認済み。詳細は `docs/implementation-notes.md` の
「The toric test case」節。

## 2. 別の PC でのセットアップ

```
git clone git@github.com:takehikoyasuda/flip-computation.git
cd flip-computation
M2 --script tests/run-tests.m2      # "all tests passed" が出れば OK
```

必要なのは Macaulay2 本体のみ（1.24.05 と 1.24.11 で確認）。使用パッケージ
`Divisor`, `SymbolicPowers`, `MinimalPrimes`, `IntegralClosure`, `Elimination`,
`Polyhedra` はすべて M2 同梱。

macOS + Homebrew の注意: `macaulay2 1.24.05` は `icu4c` 74 系にリンクしており、
Homebrew の `icu4c` が 78 に上がると `libicudata.74.dylib not found` で起動しなく
なる。今の Mac では次の回避策を入れてある（`brew reinstall macaulay2` でも直る）。

```
mkdir -p /opt/homebrew/lib/Macaulay2/lib
for f in libicudata.74.dylib libicui18n.74.dylib libicuuc.74.dylib; do
  ln -sf /opt/homebrew/Cellar/icu4c/74.2/lib/$f /opt/homebrew/lib/Macaulay2/lib/$f
done
```

## 3. 作業 A: 局所（アフィン）版サポートとトーリック例での検証

### A-1, A-2 は完了

実装は roadmap の当初案どおり（`baseIsProjective` キー、次元補正の切り替え、
`BaseIsProjective` オプション、`isSmallProjection` は共通のまま）。実際に書いてみて
分かった点だけ記す。

* アフィンの場合、`k[u,x]` に `deg x_j = 0` を入れると heft ベクトルが取れず
  `basis` などが壊れる。u 次数付けは**明示せず**、標準次数の環で計算している。
  実際に使う操作（gb, `eliminate`, `minimalPrimes`, `dim`, `isNormal`）はいずれも
  次数付けを必要としないので問題ない。
* `b2mToGraphMorphism` はアフィンでは意味を持たない（Lemma 2.3 の Segre 構成が
  両方の次数付けを要る）ので明示的にエラーにした。
* `canonicalDivisorData` / `antiCanonicalSection` / `flipDivisorData` にも
  `BaseIsProjective` を通した（`Divisor` の `IsGraded` に渡すだけ）。
* パッケージ本体の `load "FlipComputation/basics.m2"` が相対パスだったため、
  `check` がサブプロセスでテストを走らせるとファイルが見つからず落ちていた。
  `currentFileDirectory` 基準に修正済み。
* TEST ブロックからは `PackageImports` の `Divisor` のシンボル（`canonicalDivisor`,
  `divisor`）が見えない（`Polyhedra` のものは見える）。テストではパッケージ自身の
  `canonicalDivisorData` を使い、線形同値の確認は `examples/toric-flip.m2` 側で
  `needsPackage "Divisor"` して行っている。

検証結果（`examples/toric-flip.m2`、実行約 0.7 秒）:

* `K_X` は `-D_1 - D_3` として返る。トーリックな `-Σ D_i` とは主因子
  `div(y_1) = D_2 + D_4` の分だけ違い、線形同値であることを確認した。
  当初「`-Σ D_i` になるはず」と書いたが、`Divisor` パッケージが返すのは
  標準加群から作った代表元なので一致する必要はない。
* `s = 1`, `E = D_1 + D_3`, `I = O_X(-E)` の生成元はちょうど2個。したがって
  Z ⊂ P^1 × X で、これは Z の極大錐の個数と一致する。
* **m = 1 で通る**（正規かつ small）。
* トーラス固定点上のファイバーは1次元 → 例外集合は曲線。
* 2つのチャートはいずれも3次元で smooth。I の生成元から復元した扇は
  `<v1,v3,v4>, <v2,v3,v4>` に一致。壁 `<v3,v4>` での wall relation から
  `K·C = +1 > 0`、すなわち K_Z は π-ample。反対側 Y では `K·C = -1 < 0`。
  つまり `computeFlip` はフリップを返しており、入力側の縮約ではない。

### A-3. 次: 射影版

同じ特異点を含む射影的 3-fold を作って論文どおりの設定で確かめる。A-2 の X_aff を
`D_+(w)` として含む射影錐 `Proj(A[w])`（A に正の次数付けを入れる）を使えば3次元
射影多様体になり、変数の増加も1個で済む。ただし頂点以外にも特異点が出るので、
Algorithm 3 が返すものが「その特異点でのフリップ」になっているかは局所的に確認する
必要がある。射影版では `singleDegreeIdeal` による次数揃えが効いてくるので、そこが
本当に正しいブローアップを与えているかの実地確認も兼ねる。

### A-4. トーリック例をもう少し増やす

今の例は m = 1 で通ってしまい、Step 4 のループ（m を増やす部分）が一度も回っていない。
`m > 1` を要求する例が欲しい。候補は circuit の重みを上げた
`cone((1,0,0),(0,1,0),(0,0,1),(1,1,-3))` など（Z 側の錐が特異になり、K_Z の指数が
1 でなくなる）。B-2（m の刻み）の検討にも必要。

## 4. 次の作業 B: Algorithm 3 の精緻化

優先度順。

1. **正規性判定**（`isNormalSource`）。現状は双斉次座標環（= Z^m 上の錐）の正規性
   を見ており、十分条件でしかない。Z^m 自身が正規でも錐が正規でない場合に m を
   無駄に増やしてしまう。改良案:
   * 標準次数（すべての重みが1）の場合はアフィンチャート `u_i = 1, x_j = 1` ごとに
     `isNormal` を呼ぶ。r(m+1) 個のチャートだが各々は小さい。
   * 重み付きの場合は `D_+(x_j)` の座標環が次数0部分（Veronese）になるので、
     `Polyhedra`/`Normaliz` で生成元を出す必要がある。後回しでよい。
   * Serre 条件 R1 + S2 を直接見る実装も検討（`Divisor` パッケージの補助関数）。
2. **m の刻み**。論文は m = 1!, 2!, 3!, … だが symbolic power の計算量が爆発する。
   実用上は m = 1, 2, 3, 4, 6, 12, 24 のような列（`Multipliers` オプションで指定可）
   の方が速い。既定値をどうするか要検討。「sufficiently factorial」の必要条件から
   下限を見積もれないか（X の特異点の指数 index を計算して m をその倍数に取る）。
3. **s の選択**（Step 2）。今は最小次数の生成元を取っている。s の選び方で I が変わり、
   必要な m も変わる。トーリック例で s を変えて m の必要値を比較する実験をしたい。
4. **symbolic power**。`divisorialIdeal` は `intersect_i symbolicPower(p_i, m e_i)`
   で計算している。`SymbolicPowers` の Strategy 比較と、m を増やすときに前の結果を
   使い回せないかの検討。
5. **Rees イデアル**。現状は t を消去する自前実装（`bigradedReesIdeal`）。
   `ReesAlgebra` パッケージの `reesIdeal` を `flattenRing` 経由で双次数環に写す実装と
   速度比較をする。
6. **例外集合判定の高速化**。`minimalPrimes` は重い。余次元1成分の有無だけが必要
   なので、`V(J O_Z)` の equidimensional part や `codim` の判定で済ませられないか。

## 5. 後回しにする作業

* Algorithm 1（Stein 分解、5章）、Algorithm 2（contraction 射、6章）、
  Algorithm 4（MMP 全体、7章）。
* public 化の準備: ライセンス選定（未定、README に明記済み）、GitHub Actions で
  Macaulay2 のテストを回す CI、`installPackage` が通るドキュメント整備。
  * **既知の不具合（今回の変更以前から存在）**: `installPackage` が
    `can't convert symbol 'Section' to external string because it is shadowed by
    'Section'` で失敗する。export しているオプション名 `Section` が `SimpleDoc`
    側の `Section` と衝突している。`AntiCanonicalSection` などに改名すれば直る
    見込み。`check`（= `tests/run-tests.m2`）は影響を受けないので通る。

## 6. 論文に照らして確認したい点

* **Step 3 の符号**。論文は `I := prod p_i^{n_i - m_i}` と書いているが、
  E = div(s) - K_X が有効因子なので O_X(K_X - div(s)) = O_X(-E) に対応する
  イデアルの指数は `m_i - n_i` になる。実装は後者。誤植かどうかの確認。
  トーリック例で実装の符号が正しい答え（K_Z が π-ample な側）を返すことは確認済み
  なので、論文側の誤植と見てよさそう。
* **Step 2 の s の存在**。トーリック例では K_X の係数がすべて負だったので
  `s = 1` になった。論文の記述では s は `prod p_i^max(0,n_i)` の元だが、
  この積が単位イデアルになる場合の扱いを明示しておきたい。
* **Step 5 の `V(h) ⊂ X × P^{r-1}`**。u_i の次数を (0,1) にすると、I^(m) の生成元の
  次数が揃っていないと Rees の関係式が双斉次にならない。実装では I^(m) をその
  D 次成分で生成し直して回避している（層としては同じなのでブローアップも同じ）。
  論文の記述にこの但し書きを入れるか、重み付き射影束 P(d) を使う形に直すか。
* **Lemma 7.2 の適用**。実装は Exc(π) ⊆ V(I O_Z) と Zariski の主定理から、
  「V(I O_Z) の余次元1の既約成分で潰れるものが無い」を判定条件にしている
  （`docs/implementation-notes.md` 参照）。この同値性の議論を論文の書き方と
  突き合わせておきたい。
