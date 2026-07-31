# 開発計画（引き継ぎ用メモ）

作成日: 2026-07-31。別の PC で作業を継続するための覚書。
対象論文: T. Yasuda, *An algorithm for the minimal model program in dimension three*,
[arXiv:2603.13703](https://arxiv.org/abs/2603.13703)、第7章 Algorithm 3。

## 1. 現状

コミット `003525a` までで以下が動いている。

* `FlipComputation.m2` + `FlipComputation/{basics,divisors,rees,segre,flip,doc}.m2`
* Algorithm 3 の Step 1–5 を実装（`computeFlip`）
* Lemma 2.6 の B2M projection → graph morphism 変換（`b2mToGraphMorphism`）
* テスト5件（`M2 --script tests/run-tests.m2`、約1秒で通過）
  * 3次元 ODP の small resolution が正規かつ small と判定される
  * P^3 の点のブローアップが small でないと判定される
  * K_{P^3} = -4H
  * Segre 積の Hilbert 基底の個数
  * graph morphism 変換後の次元
* `examples/ordinary-double-point.m2`、`docs/implementation-notes.md`

**未検証**: 本物のフリップの例で `computeFlip` 全体を通したことがない。ODP は
K_X が Cartier なのでフロップであり、Step 1–3（K_X から I を作る部分）と
Step 4–5 のループを通した実例がまだない。

## 2. 別の PC でのセットアップ

```
git clone git@github.com:takehikoyasuda/flip-computation.git
cd flip-computation
M2 --script tests/run-tests.m2      # "all tests passed" が出れば OK
```

必要なのは Macaulay2 本体のみ（1.24.05 で確認）。使用パッケージ
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

## 3. 次の作業 A: 局所（アフィン）版サポートとトーリック例での検証

目的は Algorithm 3 の中核（Rees 代数・正規性・例外集合の判定）を、本物のフリップ
特異点で確かめること。射影的な非 Q-Gorenstein 3-fold を同次座標環として書き下すと
変数と次数が増えて計算が重いので、まず局所版で検証する。論文のスコープ外の補助機能
という位置づけ。

### A-1. 実装（小さい変更で済む）

* `B2MProjection` にキー `baseIsProjective`（Boolean、既定 `true`）を追加する。
* 次元補正を切り替える。
  * `geometricDimension`: 射影 `dim totalRing - 2` / アフィン `dim totalRing - 1`
  * `bigradedDim`: 同様に `-2` / `-1`
  * `imageDimension`: 射影 `dim(R/q0) - 1` / アフィン `dim(R/q0)`
  * `irrelevantIdeal`: アフィンの場合は `ideal(u_1,...,u_r)`（x 側の錐がない）
* `bigradedReesProjection` にオプション `BaseIsProjective => true` を追加。アフィン
  の場合は `deg u_i = 1`, `deg x_j = 0` の単一次数付けでよく、`singleDegreeIdeal`
  による次数揃えも不要（生成元の次数を揃える必要がそもそもない）。消去による
  Rees イデアル計算は `deg t = -1`（または重み付けなし）で行う。
* `isSmallProjection` のロジックは共通のまま使える。

### A-2. 検証に使うトーリック例

3次元の非 Q-Gorenstein なフリップ特異点として

```
sigma = cone( v1=(1,0,0), v2=(0,1,0), v3=(0,0,1), v4=(1,1,-2) )
```

を使う。circuit 関係は `v1 + v2 = 2 v3 + v4`（正側の重み和 2、負側 3）で、
4本の生成線が同一アフィン超平面に乗らない（`m·v_i = 1` を満たす `m` が存在しない）
ので X = Spec k[σ^∨ ∩ M] は Q-Gorenstein ではない。σ の2通りの三角形分割が
フリップの両側 Y, Z を与える。

手順:

1. σ^∨ ∩ M の Hilbert 基底を計算する（`Polyhedra` の `hilbertBasis` を
   `dualCone` に適用。`segre.m2` の `segreHilbertBasis` と同じ使い方）。
2. 生成元を単項式写像 `k[y_1..y_s] → k[t1^±,t2^±,t3^±]` の像として、その核
   （トーリックイデアル）を `ker` で計算し、R = k[y]/I を得る。
3. `canonicalDivisor(R)`（`IsGraded => false`）で K_X を計算し、Step 2, 3 を通す。
   トーリックなので K_X = -Σ D_i（D_i は torus 不変素因子）になるはずで、
   `canonicalDivisorData` の出力と突き合わせて確認する。
4. `computeFlip(R, BaseIsProjective => false)` を走らせ、m = 1 で small かつ正規
   になるかを見る。
5. 期待される結果の突き合わせ:
   * 例外集合が曲線（余次元2）であること
   * Z の扇が σ の「もう一方の三角形分割」に一致すること
     （`NormalToricVarieties` で作った期待値と、Z の定義イデアルの比較）
   * K_Z が π-ample であること（フリップであってアンチフリップでないこと）の確認方法
     を決める。トーリックでは discrepancy の計算で判定できる。

### A-3. その後の射影版

局所版が通ったら、同じ特異点を含む射影的 3-fold を作って論文どおりの設定で
確かめる。A-2 の X_aff を `D_+(w)` として含む射影錐 `Proj(A[w])`（A に正の次数
付けを入れる）を使えば3次元射影多様体になり、変数の増加も1個で済む。ただし
頂点以外にも特異点が出るので、Algorithm 3 が返すものが「その特異点でのフリップ」
になっているかは局所的に確認する必要がある。

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

## 6. 論文に照らして確認したい点

* **Step 3 の符号**。論文は `I := prod p_i^{n_i - m_i}` と書いているが、
  E = div(s) - K_X が有効因子なので O_X(K_X - div(s)) = O_X(-E) に対応する
  イデアルの指数は `m_i - n_i` になる。実装は後者。誤植かどうかの確認。
* **Step 5 の `V(h) ⊂ X × P^{r-1}`**。u_i の次数を (0,1) にすると、I^(m) の生成元の
  次数が揃っていないと Rees の関係式が双斉次にならない。実装では I^(m) をその
  D 次成分で生成し直して回避している（層としては同じなのでブローアップも同じ）。
  論文の記述にこの但し書きを入れるか、重み付き射影束 P(d) を使う形に直すか。
* **Lemma 7.2 の適用**。実装は Exc(π) ⊆ V(I O_Z) と Zariski の主定理から、
  「V(I O_Z) の余次元1の既約成分で潰れるものが無い」を判定条件にしている
  （`docs/implementation-notes.md` 参照）。この同値性の議論を論文の書き方と
  突き合わせておきたい。
