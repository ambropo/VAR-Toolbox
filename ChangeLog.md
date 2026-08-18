## 2026-08-16 — Fix nine lower-severity defects from the external audit reports

Second follow-up to the audit reports in `VAR-Toolbox-Archive/Comments` (issues 9, 12, 13,
18, 19, 20, 21, 29, 30 of the consolidated register). Every item was verified in MATLAB
before and after the change.

### Code
- **BREAKING (behaviour):** `VAR/VARlag.m` — the information criteria used `NOBS = aux.nobs + i`, reintroducing a candidate-specific sample size after every candidate had been estimated on a common sample. The likelihood scaling and both penalty denominators were therefore wrong by `maxlag - i` for every candidate but the longest. Now `NOBS = aux.nobs`, the observation count actually used in estimation, common to all candidates by construction. Symptom: the selected lag differed from the common-sample reference in **24 of 200 simulated replications (12%)**; it now agrees in 200/200. Selected lags may change relative to v4.0.
- **Fixed:** `VAR/VARlag.m` — the effective sample was not in fact common when `lag_ex > 1`: the input was trimmed by `maxlag - i` but `VARmodel` then trims `max(i, lag_ex)`. The trim is now `maxlag + 1 - max(i, lag_ex)`, so every candidate starts at observation `maxlag+1`. Added a guard rejecting `lag_ex > maxlag`. (Found while fixing the item above; not in the audit reports.)
- **Fixed:** `VAR/VARlag.m` — `AIC = find(AIC==min(AIC))` returned **every** tied minimiser, so the documented scalar lag order could be a vector (exact ties) or empty (all-`NaN` criteria), and the natural downstream call `VARmodel(ENDO,AIC,const)` then failed inside `VARmakexy`. Now `[~,AIC] = min(AIC)`, with an explicit error when no criterion value is finite.
- **BREAKING (behaviour):** `VAR/compute_IR.m` — with `VARopt.shut ~= 0` the shut-down variable was held at zero **on impact only** under the default `recurs='wold'`, because `PSI` is built by `compute_wold` from the unmodified lag polynomial while `shut` zeroes a row of `Fcomp`. The two recursion options implemented different counterfactuals. Symptom: the shut variable responded −0.031, −0.021, … from horizon 2 onwards under `'wold'` while `'comp'` held it at exactly 0. The companion recursion is now used whenever `shut` is active, irrespective of `recurs`; `shut = 0` is unaffected (`'wold'` and `'comp'` agree to 3e-16 as before).
- **Fixed:** `VAR/SignRestrictions.m` — `counter` was incremented **before** the budget test, so the loop performed at most `sr_rot - 1` complete rotations, and `sr_rot = 1` built `startingMat`, broke immediately, and returned `B = []` unconditionally: `SR.m` then treated every attempt as a rejection and cycled until the `sr_draw` budget aborted with the misleading message that the restrictions were too tight. The test now precedes both the increment and the construction of `startingMat`, so exactly `sr_rot` rotations are attempted, and `n_tried = counter` reports the true count feeding `accept_rate`. Verified: `sr_rot = 1` now completes normally.
- **Fixed:** `VAR/VARmodel.m`, `VAR/OLSmodel.m`, `VAR/LPmodel.m`, `VAR/VARlag.m` — `const` was validated only from above (`const > 2`), so the same invalid input produced three different outcomes: `VARmodel` errored late inside `VARmakexy`; `OLSmodel` **silently ran with no deterministics at all** (its `if const==1 / elseif const==2` chain has no final `else`) while recording `OLS.const = -1`; `LPmodel` **silently included constant plus trend** (its final `else` catches everything unmatched). All four entry points now use `ismember(const,[0 1 2])` with a scalar check.
- **Fixed:** `Auxiliary/ztcrit.m` — the `p > 5` guard assigned `crit = zeros(6,1)` but did not `return`, so the table lookup two lines later overwrote it on every path. Out-of-domain `p` silently returned critical values for a different trend order (`ztcrit(100,6)` returned the `nobs`-group-2, `p=-1` row) or raised an opaque index error (`ztcrit(500,6)`). Now raises an explicit error for `p` outside `[-1,5]`. Reachable from `adf` and `Stats/SummStats`.
- **Fixed:** `Auxiliary/adf.m` — with `l = 0` the augmentation loop did not execute, `z` stayed `[]`, and `trimr(z,0,0)` raised `Attempting to trim too much in trimr`, so zero augmentation (the plain Dickey-Fuller specification) was unreachable. `z` is now initialised as `zeros(rows(ch),0)`, which also keeps `rows(z)` correct in the subsequent `ptrend` call. Identical results for `l >= 1`.
- **Fixed:** `Utils/CommonSample.m` — an empty input reached `isnan(temp(1))` on a 0-element vector and raised an index error. Empty input now returns unchanged with `fo = lo = 0`.
- **Fixed:** `Auxiliary/ols.m` — `results.sige` divides by `nobs-nvar` but the confidence-interval critical value used `tdis_inv(.025,nobs)`, so `results.bint` was too narrow relative to the stated residual degrees of freedom, and `Auxiliary/ols.m` and `VAR/OLSmodel.m` reported different intervals for identical inputs. Both now use `nobs-nvar`.

### Notes
- Not addressed in this pass (register items left open): 7 (no stability screen on sign-posterior draws), 10 (greedy sign-column matching without backtracking), 11 (`dy-ds>1` accepted silently), 14–16 (LP-IV first-stage F degrees of freedom, first-instrument-column-only, no NaN screen), 17 (`compute_IR` has no `else` for an unrecognised `recurs`), 22 (bootstrap has no attempt cap), 23 (`nlag_ex > nlag` inconsistently defined), 24 (`CorrTable` header promises listwise deletion), 26 (`tdis_prb` clamp assumes a column vector), 27 (undocumented full-length NaN-padded `VARopt.IV` contract), 28 (`VAR.Fp` third dimension follows `nsteps`, not `nlag`).

---

## 2026-08-16 — Reject the i.i.d. bootstrap under IV; add the moving block bootstrap

### Code
- **BREAKING:** `VAR/VARmodel.m` — `VARopt.method = 'bs'` is now **rejected** when `VARopt.ident = 'iv'`. Before: the combination ran and returned bands whose identifying instrument/innovation pairing had been destroyed (see the previous entry). After: `VARmodel` raises an error directing the user to `'mbb'` or `'wild'`. This is the default `method`, so any script that set only `ident='iv'` with `inference=1` and did not set `method` must now choose one explicitly. `'bs'` is unaffected for all other identification schemes, and `inference=0` is unaffected. No shipped script is affected: `Replic/GK2015` and `Exercise/Exercise_Solution.m` already set `method='wild'` for their IV blocks, and `Primer/VARToolbox_Primer.m` runs its IV section with `inference=0`.
- **Added:** `VAR/VARmodel.m` — moving block bootstrap, `VARopt.method = 'mbb'`, following Jentsch and Lunsford. The effective sample is covered by `ceil(T/l)` blocks of `l` consecutive residuals drawn with replacement from the `T-l+1` admissible starting dates, concatenated, trimmed to `T`, and recentred so each within-block position has mean zero. Under `ident='iv'` the instrument is blocked with the **same** starting indices, so each artificial residual keeps the instrument observation it was paired with in the data; instrument recentring uses the deviation of the block-position mean from the full-sample mean and is applied to observed (non-NaN) entries only, so a partially observed proxy is handled correctly. Available for every identification scheme, not only `iv`.
- **Added:** `VAR/VARoption.m` — `VARopt.mbb_blocksize` (default `[]`, which sets `floor(5.03*nobs^0.25)`).
- **Validation:** the `'mbb'` implementation was checked against the reference implementation in `ambropo/MP_HighFrequencyUK` (`doMBBbootstrap_adj.m`, Cesa-Bianchi, Thwaites and Vicondoa, EER 2020), using that paper's own data and specification (7 variables, 2 lags, 1992m1–2015m1, block length 20). Given identical block indices the two produce identical bootstrap residual samples (`max abs diff 1.4e-11`, i.e. OLS noise) and identical residual recentring (`1.6e-13`). Re-estimating CTV Figure 2 through `VARmodel` and renormalising to their unit-impact convention reproduces the published IRFs (surface correlation `0.99997`) and the 68% MBB bands (median band-width ratio `0.999`, band-width correlation `0.9998`, median interval overlap `0.964`). The remaining point-estimate gap is entirely attributable to one convention difference: `recover_B` runs both IV stages with an intercept, whereas the reference code uses the raw moment ratio `Gamma_j/Gamma_1`. Suppressing the intercept reproduces the reference ratios to `4.3e-14`.

### Manual
- **Revised:** `VAR_Handbook.tex`, options table — `method` now lists `'bs' | 'mbb' | 'wild'` and records that `'bs'` is rejected under `ident='iv'`; added the `mbb_blocksize` row.
- **Revised:** `VAR_Handbook.tex`, "Bootstrap Inference (Point-Identified Models)" — added the moving block bootstrap as a third variant with its block construction and default block length. Replaced the paragraph recommending the wild bootstrap for external instruments with one that states the identifying requirement (each `z_t` must stay attached to its `u_t`), explains why the residual bootstrap violates it and is therefore rejected, and compares the two admissible schemes.
- **Revised:** `VAR_Primer_Slides.tex`, "Bootstrap for point-identified models" — three variants instead of two; added the `ident='iv'` restriction.

---

## 2026-08-16 — Fix IV bootstrap pairing, wild-bootstrap weights, HD components, and SR posterior residuals

Follow-up to the external audit reports in `VAR-Toolbox-Archive/Comments`. All five issues
below were verified in MATLAB before and after the change.

### Code
- **Fixed:** `VAR/VARmodel.m` (`method='bs'` with `ident='iv'`) — the standard bootstrap resampled residual rows i.i.d. while passing the **original** instrument through unchanged, so artificial residual `t` came from a random date but was still paired with `z_t`. Identification rests on that contemporaneous pairing, so it was destroyed on every draw. Symptom: on GK2015 the bootstrap mean impact response was **−0.024 against a point estimate of 0.193**, with **55.5% of draws carrying the wrong sign** and bands 12.6× wider than the wild bootstrap. Cause: residuals and instrument were drawn independently. Superseded on the same date: the combination is now rejected outright (see the entry above), and `'mbb'` was added as the serial-dependence-preserving alternative to `'wild'`.
- **Fixed:** `VAR/VARmodel.m` (`method='wild'` with `ident='iv'`) — `u = resid .* (rr*ones(size(IV,2),nvar))` is a matrix product, so with `k` instruments the `k` independent Rademacher columns were **summed**. With two instruments the residual weights had support `{-2,0,+2}` instead of `{-1,+1}` and **38% of residual rows were annihilated**; each instrument column meanwhile received its own sign rather than the common one. Now one weight per observation is applied to the residual row and to every instrument column. Verified to be a **no-op for a single instrument** (identical weights and identical RNG consumption), so `Replic/GK2015` is bit-identical.
- **Fixed:** `VAR/compute_HD.m` — the identified exogenous shock (`ident='exog'`) had **no component at all**: the file ran section 6 → section 8 and `HDendo` omitted the `X_ES` forcing term. Symptom: components missed the data by `max|HD.endo − Y| = 4.11` against a series s.d. of 1.37. Added section 7 computing the contribution of the whole `X_ES` block (contemporaneous plus every included lag), exposed as the new field **`HD.exoshock`**, and included in `HDendo`.
- **Fixed:** `VAR/compute_HD.m` — lagged exogenous variables were omitted from the decomposition. The loop read only `VAR.X_EX(:,ii)` and one coefficient column, so with `nlag_ex>0` every lagged `EXOG` regressor was dropped. Symptom: `max|HD.endo − Y| = 3.52` (s.d. 1.47) at `nlag_ex=2`, against 1.8e-15 at `nlag_ex=0`. The forcing term now sums over all lags `kk = 0…nlag_ex`, reading column `kk*nvar_ex+ii` of `X_EX` with its own coefficient. After both fixes the reconstruction identity holds to machine precision in every configuration tested: plain, `const=2`, `nlag_es ∈ {0,2}`, `nlag_ex ∈ {0,1,2,3}`, multiple exogenous variables, and exoshock combined with lagged `EXOG`.
- **Fixed:** `VAR/SR.m` — under `inference=1` the posterior draw replaced `Ft`, `F`, `Fcomp`, and `sigma` but **not** `resid`, so narrative restrictions (`e = B\resid'`) and `compute_HD` used point-estimate innovations alongside drawn dynamics and covariance. Residuals are now recomputed as `VAR.Y - VAR.X*Ft_draw` (they differ by ~17% in relative Frobenius norm, so this was not a null change). The HD reconstruction identity now holds for the drawn model. Sign-restriction acceptance is unaffected: it depends only on `B` from `sigma_draw`.
- **Added:** `VAR/VARmodel.m`, `VAR/VARhdplot.m` — `HD.exoshock` threaded through bootstrap storage (`HDall`, `HDbar`, `HDinf`, `HDsup`) and added to the stacked-area plot as its own band, so the stacked components continue to sum to the plotted data line under `ident='exog'`.

---

## 2026-08-16 — Fix IV sample alignment in recover_B

### Code
- **Fixed:** `VAR/recover_B.m` (`ident='iv'`) — the residuals of the non-instrumented equations were misaligned with the instrument sample. Symptom: with an instrument that is missing at the end of the sample or has interior gaps, the second-stage regressions and `sigma_b` paired residuals from the wrong dates, silently corrupting the IV impact vector, its normalisation, and every downstream IRF/VD/HD (including bootstrap bands). No error was raised because the two blocks had equal row counts. Cause: `CommonSample` drops every row containing a NaN, so `p` and `Z_iv` sat on the instrument's dates, but `q` was rebuilt as the *last* `length(p)` rows of `uq` — a row count, not a date selection. That shortcut is correct only when all missing observations are leading. Replaced by a logical mask over dates (`keep = ~any(isnan([up IVtrim]),2)`) applied identically to `p`, `q`, and `Z_iv`.
  - Reported by an external user (first raised December 2023).
  - Results are bit-identical to the previous version when the instrument is missing only at the start of the sample. The shipped `Replic/GK2015` replication is that case (`ff4_tc` observed from obs 127 to 396 of 396, no interior or trailing gaps) and is therefore unchanged — verified as an exact zero difference in `p`, `q`, and `Z_iv`.
  - Users who ran `ident='iv'` with an instrument ending before the VAR sample, or with interior gaps, should re-run their results.

---

## 2026-06-27 — v4.0 Release

VAR Toolbox 4.0 — the first release shipped with a full handbook and slide decks. This entry is the consolidated record of all changes relative to v3.1 (`VAR-Toolbox-3.1`), the last released version.

---

### BREAKING CHANGES

- **BREAKING:** `VAR/VARmodel.m` — function signature changed. Old: `[VAR, VARopt] = VARmodel(ENDO, nlag, const, EXOG, nlag_ex)`. New: `VAR = VARmodel(ENDO, nlag, const, VARopt, EXOG, nlag_ex)`. Single output; `VARopt` is now the 4th input (not a second output). Identification and bootstrap inference are controlled through `VARopt` fields and computed inside `VARmodel`; the separate functions `VARir`, `VARirband`, `VARvd`, `VARvdband`, `VARhd`, `VARhdband` no longer exist.

- **BREAKING:** `VAR/VARmodel.m` — exogenous shock for `ident='exog'` is now supplied via `VARopt.exoshock` (new field), not as the positional `EXOG` argument. Before: `VARmodel(X, nlag, const, VARopt, mps, 0)`. After: `VARopt.exoshock = mps; VARmodel(X, nlag, const, VARopt)`. The `EXOG` positional argument is retained for general exogenous regressors.

- **BREAKING:** `VAR/VARoption.m` — `VARopt.ident` default changed from `'short'` to `''` (reduced form only). Scripts that relied on identification being active by default must now set `VARopt.ident` explicitly.

- **BREAKING:** `VAR/VARoption.m` — removed fields `VARopt.datesnum`, `VARopt.datestxt`, `VARopt.datestype` (vestigial; never read by any toolbox function). Use `VARopt.firstdate` and `VARopt.frequency` to control axis date labels.

- **BREAKING:** `VAR/VARoption.m` — `VARopt.latex` default changed from `0` to `1`; `VARopt.figsize` default changed from `[26, 24]` to `[]` (auto-size).

- **BREAKING:** `VAR/VARoption.m` — removed `VARopt.sr_mod`; `VARopt.inference` default changed from `0` to `1`. Before: `sr_mod = 1` drew `(F,Σ)` from the posterior inside the sign-restriction rotation loop; `inference` was ignored by the sign path. After: `inference = 1` (now the default) draws from the Normal-Inverse-Wishart posterior before rotating (parameter + identification uncertainty); `inference = 0` fixes parameters at OLS. Any script that set `VARopt.sr_mod` explicitly must replace it with `VARopt.inference`.

- **BREAKING:** `VAR/LPoption.m` — `LPopt.LAGS` renamed to `LPopt.CONTROLS`. Any caller that sets `LPopt.LAGS` must update to `LPopt.CONTROLS`.

- **BREAKING:** `VAR/LPmodel.m` — signature changed from `[IR,LPout,INF,SUP] = LPmodel(ENDO,S,LPopt)` to `LP = LPmodel(ENDO,TREAT,CTRL,nlag,const,LPopt,EXOG,nlag_ex)`. The second argument is renamed `S`→`TREAT` (it is the shock in OLS mode, the endogenous treatment in IV mode; see below). `CTRL`, `nlag`, `const` are now required positional arguments (previously set via `LPopt.CONTROLS`, `LPopt.nlag`, `LPopt.const`). `EXOG` and `nlag_ex` are optional positional arguments after `LPopt` (`EXOG` was previously `LPopt.EXOG`; `nlag_ex` is new and defaults to 0). The output is a single struct `LP`; access responses as `LP.IR`, `LP.INF`, `LP.SUP`.

- **BREAKING:** `VAR/LPoption.m` — removed fields `CONTROLS`, `EXOG`, `nlag`, `const` (now explicit arguments in `LPmodel`).

- **BREAKING:** `VAR/LPmodel.m`, `VAR/LPoption.m` — second argument renamed `S`→`TREAT` and its role swapped with `LPopt.IV`. Before: `S` (second argument) was the external instrument and `LPopt.IV` held the endogenous treatment. After: `TREAT` is always the treatment — the shock entering directly in OLS mode (math notation $s_t$), the endogenous variable instrumented in IV mode (math notation $r_t$) — and `LPopt.IV` holds the external instrument (math notation $z_t$). The output field `LP.S` is likewise renamed `LP.TREAT`. Callers using LP-IV must swap: pass the endogenous variable as `TREAT` and move the instrument into `LPopt.IV`. The name `TREAT` is accurate in both modes (in OLS the shock is the treatment; in IV the endogenous policy variable is), unlike `S`, which read as "shock" and was misleading in IV mode.

- **BREAKING:** `VAR/recover_B.m` — `VAR.Biv` removed from output. Use `VAR.B(:,1)` instead.

- **BREAKING:** `Utils/datatreat.m` — signature and contract changed. Old: `OUT = datatreat(DATA, vtreat, nlag)`, a matrix-in/matrix-out primitive on a single series. New: `DATA = datatreat(DATA, tnames, ttype, tscale, nlag)`, which operates on the `DATA` struct, loops over the variables in `tnames`, applies the transform in `ttype`, rescales by `tscale`, and writes each result back as a new field named by a fixed prefix convention: `1=Log`→`ln`, `2=First difference`→`d`, `3=Log difference`→`dln`, `4=Fractional change`→`g` (e.g. log-difference of `gdp`→`dlngdp`). Code `0` (no treatment) removed (raw levels already live in `DATA` under their own name). Numeric codes 1–4 retain their previous meaning and the underlying transforms are unchanged. The function errors if a target field name already exists in `DATA`, preventing silent overwriting. Consequence: the GDP-growth series is named `dlngdp` (was `dgdp`) throughout the toolbox.

- **BREAKING (minor):** `VAR/VARmodel.m`, `VAR/LPmodel.m` — per-equation/per-outcome sub-struct field names are now taken exclusively from `VARopt.mnem` / `LPopt.mnem` (new fields), never from `vnames`. Before, valid-identifier `vnames` could supply the field names; a script that set `vnames` to valid identifiers (and no `mnem`) and accessed `VAR.<name>` now receives `VAR.eq1,...` instead. No in-repo script is affected (all set `mnem`). The codebase-wide data-load convention is now `vnames` = full display names and `mnem` = mnemonics (with `DATA` keyed by `mnem`); the former `vnames`/`vnames_long` pairing — which had the roles reversed — is eliminated.

- **BREAKING:** `Figure/cmap.m` — color sequence replaced. New entries 1–8: Blue, Tomato, Gold_Dark, Mint_Dark, Pink, Choco_Light, BoEacqua, BoEpurple_Dark; entries 9+ fall back to parula. Code relying on `cmap(n)` by index will get a different color.

- **BREAKING:** Sign-restricted output fields renamed for consistency with point-identified schemes. Old → new:
  - `VAR.B` → `VAR.Bfp` (Fry–Pagan structural impact matrix)
  - `VAR.IR` → `VAR.IRfp` (IRF from Fry–Pagan draw)
  - `VAR.VD` → `VAR.VDfp` (FEVD from Fry–Pagan draw)
  - `VAR.HD` → `VAR.HDfp` (HD struct from Fry–Pagan draw)
  - `VAR.HDmed`, `VAR.HDinf`, `VAR.HDsup` → now full structs (`.shock` = median/percentile bands; non-shock components = OLS point estimates)
  - Affects: `VAR/SR.m`, `VAR/VARmodel.m`

- **BREAKING:** Point-identified bootstrap output renamed and recomputed:
  - `VAR.IRmed` → `VAR.IRbar` (computation changed from median to mean)
  - `VAR.VDmed` → `VAR.VDbar` (computation changed from median to mean)
  - `VAR.HDmed` → `VAR.HDbar` (full struct; all components as bootstrap mean)
  - `VAR.HDinf`, `VAR.HDsup` → now full structs (all components as percentile bands)
  - Affects: `VAR/VARmodel.m`

- **BREAKING:** `const=3` (constant + linear trend + quadratic trend) removed toolbox-wide. Passing `const=3` to any toolbox function now raises a hard error. Before: `VARmakexy`, `OLSmodel`, and `build_LAGplus` accepted `const=3` and built a quadratic trend column; `compute_HD` computed `HD.trend2`; `VARhdplot` plotted it. After: `VARmakexy`, `OLSmodel`, `build_LAGplus`, `VARlag`, `ARDLmodel`, and `VARmodel` all raise a hard error on `const > 2`.

---

### Code — Added

- **Added:** `VAR/compute_IR.m` — computes impulse response functions given structural impact matrix `B` and Wold multipliers. Factored out of old `VARir.m`; called internally by `VARmodel`.

- **Added:** `VAR/compute_VD.m` — computes forecast error variance decompositions. Factored out of old `VARvd.m`; called internally by `VARmodel`.

- **Added:** `VAR/compute_HD.m` — computes historical decompositions. New API: `HD = compute_HD(VAR, B)`. Output struct separates all components: `.shock` `(nobs+nlag × nvar × nvar)`, `.init`, `.const`, `.trend`, `.exo` `(nobs+nlag × nvar × nvar_ex)`, `.endo`. Called internally by `VARmodel`.

- **Added:** `VAR/compute_wold.m` — computes the Wold moving-average representation (companion-form Wold multipliers). Called internally by `VARmodel`.

- **Added:** `VAR/recover_B.m` — recovers the structural impact matrix `B` from the reduced-form VCV under the identification scheme in `VARopt.ident` (`short`, `long`, `iv`, `exog`). Set-identified schemes (`sign`, `narr`, `sign+iv`) are handled by `SR.m`/`SignRestrictions.m`, not `recover_B`. Called internally by `VARmodel`.

- **Added:** `VAR/build_LAGplus.m` — augments a lag vector with deterministic components for use in the bootstrap simulation loop. Includes `else error(...)` guard for invalid `const` values.

- **Added:** `Figure/BestCornerLoc.m` — identifies the emptiest corner quadrant (ne/nw/se/sw) of an axes for automatic legend placement. Called by `VARvdplot` and `VARhdplot` when `VARopt.legloc = 'best'`.

- **Added:** `Figure/TitlePad.m` — widens the panel→title gap by `pad` points without moving the title higher on the page. Shrinks the axes from the top by `pad` and places the title `pad` above the new top (i.e. at the original top level), preventing clipping under `exportgraphics` tight crop. Called by `SetAxesDual` after all `yyaxis` switches so the position survives ruler resets; idempotent on repeated calls. Applies to all toolbox panels via `SetAxesDual`.

- **Added:** dual-axis panel style is now an option. New field `dualaxis` (default `1`, preserving the previous always-on appearance) in `VAR/VARoption.m`, `VAR/LPoption.m`, `Figure/PlotLineOption.m`, and `Figure/PlotSwatheOption.m`, plus a 7th `dualaxis` argument (default `1`) in `Figure/PlotStatesShaded.m`. The `SetAxesDual(gca)` calls in `VARirplot`, `LPirplot`, `VARhdplot`, `VARvdplot`, and `PlotStatesShaded` are gated on the flag; `PlotLine` and `PlotSwathe` now apply `SetAxesDual` themselves when their `dualaxis` field is on (the four VAR/LP plotters set `dualaxis=0` on their internal `SwatheOpt` so the panel is styled once, under the user-facing `VARopt.dualaxis`/`LPopt.dualaxis` toggle). `Figure/SetAxesDual.m` gains an optional second argument `yl` (`[lo hi]`) that locks both rulers to an explicit y-limit — for hand-built panels where several swathes share one axis and the limits must span all layers, not only the first drawn. Setting `dualaxis = 0` reverts to plain single-axis panels.

- **Added:** `Replic/GO_ALL.m` — master wrapper that runs all six replication scripts (BQ1989, SW2001, Uhlig2005, GK2015, ADRR2018, JT2025) in chronological order. Uses `mfilename('fullpath')` for portable paths.

- **Added:** `VARoption.m` new fields: `VARopt.inference` (0 = point only; 1 = bootstrap/Bayesian; default 1), `VARopt.mnem` (endogenous variable mnemonics: valid MATLAB identifiers used to name the per-equation sub-structs `VAR.(.)`), `VARopt.IV`, `VARopt.exoshock`, `VARopt.nlag_exoshock`, `VARopt.R`, `VARopt.font`, `VARopt.legcols`, `VARopt.legloc`, `VARopt.hd_colors`, `VARopt.hd_detc`, `VARopt.dates`, `VARopt.datenticks` (target number of date ticks on HD x-axis; default 5). `LPoption.m` gains the analogous `LPopt.mnem` (used to name the per-outcome sub-structs `LP.(.)`).

- **Added:** `VAR/LPmodel.m` — stores `LP.eqnames` (the resolved $N\times1$ cell of per-outcome sub-struct names), mirroring `VAR.eqnames`; `'eqnames'` added to the `reserved` list so an `LPopt.mnem` entry cannot collide with the field.

- **Added:** `Utils/datatreat.m` — optional `tscale` (scalar or per-variable, default 1) and `nlag` (default 1); `ttype` accepts a cell array or numeric vector.

- **Added:** `VAR/VARhdplot.m` — band mode: optional `INF, SUP` struct arguments trigger per-shock band plots (one figure per shock, one panel per variable). Stacked-area mode extended with `hd_detc` option: `hd_detc=1` (default) stacks all components including deterministics; `hd_detc=0` stacks shock contributions only with "Data (adj.)" reference line.

- **Added:** `VAR/VARvdplot.m` — band mode: optional `INF, SUP` arguments trigger per-shock band plots analogous to `VARhdplot` band mode.

- **Added:** `VAR/VARirplot.m` — optional inner-band arguments `INF2, SUP2` (`nsteps × nvar × nshocks`): when supplied, a second, narrower confidence band is overlaid on the outer `INF, SUP` band (two-band plot); omitted by default (single band). New signature `VARirplot(IR, VARopt, INF, SUP, INF2, SUP2)`.

- **Added:** `VAR/VARmodel.m` — `ident='sign+iv'` hybrid identification: IV stage pins column 1 of B; sign restrictions rotate the orthogonal complement. Replaces the prior two-step `VARmodel`+`SR` workflow.

- **Added:** `VAR/VARmodel.m` — `VAR.ident = VARopt.ident` stored in output struct.

- **Added:** `VAR/VARmodel.m` — equation-by-equation OLS results stored under variable-named sub-structs when `VARopt.mnem` supplies `nvar` valid, unique MATLAB identifiers (e.g. `VAR.dlngdp`, `VAR.i1yr`); otherwise falls back to `eq1,...,eqN`. Resolved names recorded in `VAR.eqnames`.

- **Added:** `VAR/VARvdplot.m`, `VAR/VARhdplot.m` — error raised when `ident='iv'` and area plot is requested; message directs user to band plots or `VARopt.pick`.

- **Added:** `VAR/LPmodel.m` — `ENDO` may now be a matrix (`nobs × N`): loops `lp_single` over columns; top-level `.IR/.INF/.SUP` are `H × N`; per-outcome detail nests under `.eq1…eqN` (or named from `LPopt.mnem` when valid unique identifiers). Single-column output is byte-identical to before. NaN guard errors if any `ENDO` column contains NaN. `N=1` path unchanged.

- **Added:** `VAR/LPmodel.m` — IV mode stores additional diagnostics: `Fstat_fs`, `rsqr_fs`, `resid`, `y`, `D_hat`. Joint Wald test H0: b_1=...=b_H=0 now runs for both OLS and IV (previously IV only).

- **Added:** `Primer/VARToolbox_Primer.m` — sections 10 (identification with exogenous variable), 11 (LP-OLS, LP-IV, 25 bps normalization, LP-OLS vs LP-IV comparison figure), 12.0 (self-contained sign-restriction setup), and 13 (VARirplot showcase: point estimates, single/two-band plots, shock selection via `pick`, color/line/marker options, horizon axis options, figure layout options).

---

### Code — Removed

- **Removed:** `VAR/VARir.m` — functionality absorbed into `VARmodel`. IRFs now in `VAR.IRfp` (Fry–Pagan draw) and `VAR.IRbar/IRinf/IRsup` (bootstrap mean/bands when `inference=1`).

- **Removed:** `VAR/VARirband.m` — same; bands are now output fields of `VARmodel`.

- **Removed:** `VAR/VARvd.m` — functionality absorbed into `VARmodel`; results in `VAR.VDfp` and `VAR.VDbar/VDinf/VDsup`.

- **Removed:** `VAR/VARvdband.m` — same.

- **Removed:** `VAR/VARhd.m` — functionality absorbed into `VARmodel`; results in `VAR.HDfp` and `VAR.HDbar/HDinf/HDsup`.

- **Removed:** `VAR/VARhdband.m` — same.

- **Removed:** `Utils/columns.m` — byte-for-byte duplicate of `cols.m` with zero callers in the active codebase.

- **Removed:** `Utils/getqr.m` — redundant; only caller was `SignRestrictions.m` with `getqr(randn(n))`, which is identical to `OrthNorm(n)`. Replaced with direct `OrthNorm(...)` call in `SignRestrictions.m`.

- **Removed:** 18 orphaned functions from `Auxiliary/` (zero callers in the active codebase): `fdis_prb.m`, `nancumsum.m`, `nanmax.m`, `nanmean.m`, `nanmedian.m`, `nanmin.m`, `nanmovavg.m`, `nansem.m`, `nanstd.m`, `nansum.m`, `nanvar.m`, `roundn.m`, `seqa.m`, `winsor.m`, `ws2struct.m`, `clearex.m`, `m2tex.m`, `hatchfill2.m`. The `Auxiliary/` folder is retained for the actively-used helpers that remain (`adf.m`, `lag.m`, `mprint.m`, `ols.m`, `ptrend.m`, `tdis_prb.m`, `tdis_inv.m`, `tdiff.m`, `trimr.m`, `beta_inv.m`, `beta_pdf.m`, `ztcrit.m`, `rgb.m`, `SupTitle.m`).

- **Removed:** `Obsolete/` — folder deleted; 5 superseded functions removed: `LPmakex.m`, `SRhdplot.m`, `SRirplot.m`, `SRvdplot.m`, `XoX.m`. The `SR*plot` helpers are superseded by the band modes of `VARhdplot`/`VARirplot`/`VARvdplot`; `LPmakex` by `VARmakelags`/`VARmakexy`; `XoX` had no callers.

- **Removed:** `det=3` / `const==3` (quadratic trend) support from all estimation, simulation, and plotting functions. `const` is now capped at 2. Removed: `HD.trend2` output field from `compute_HD`; `VARmodel.HDall.trend2` and `SR.HDall.trend2` bootstrap storage; `Trend^2` legend entry from `VARhdplot`.

- **Removed:** redundant `Num2NaN` calls from `Primer/VARToolbox_Primer.m`, `Replic/JT2025/GO_JT2025.m`, `Replic/SW2001/GO_SW2001.m`, `Replic/ADRR2018/GO_ADRR2018.m`, `Replic/BQ1989/GO_BQ1989.m`, and `Replic/Uhlig2005/GO_Uhlig2005.m`. `Num2NaN` only replaces the NaN-encoding sentinel `123456789`; all six datasets verified to contain 0 sentinels, and `readcell`/`cellfun(@double,...)` already returns NaN for empty cells. Output bit-identical. The call is **retained (with a "Do not remove" comment)** in `Replic/GK2015/GO_GK2015.m` and `Exercise/Exercise_Solution.m`, where `GK2015_Data.xlsx` encodes 126 missing `ff4_tc` observations as the sentinel.

---

### Code — Bug fixes (critical)

- **Fixed:** `VAR/VARmodel.m` — critical df bug: `tdis_prb(tstat, nobse - ncoeff)` → `tdis_prb(OLSout.tstat, nobse - ntotcoeff)` in equation-by-equation OLS loop. `ncoeff` counted only VAR lags; `ntotcoeff` is the correct residual df (includes deterministics, exoshock, and exogenous regressors). Overstated significance in any model with const, trend, or exogenous terms.

- **Fixed:** `VAR/SignRestrictions.m` — `whereToStart` was computed as `1+dy-ds`, assuming the first `dy-ds` columns are pre-determined. For `ident='sign+iv'` only column 1 (the IV column) is pre-determined, causing a spurious `'Biv and SIGN must have compatible sizes'` crash for any VAR with `dy-ds > 1`. Fixed: `whereToStart = 1 + size(Biv, 2)`.

- **Fixed:** `VAR/SignRestrictions.m` — for `ident='sign+iv'`, the rotation basis was built from `sigma_b` (IV-subsample VCV) while `compute_VD` normalises by the full-sample `sigma`. FEVD rows did not sum to 1. Fixed by using `sigma = VAR.sigma` in all branches and adding explicit `q = q/norm(q)` normalisation before the Gram-Schmidt loop.

- **Fixed:** `VAR/OLSmodel.m` — `tdis_prb` called unconditionally on `OLS.tstat`. When `sige = NaN` (degenerate case: `nobs == nvar`) or `sige = 0` (zero-variance scores), `tstat = NaN` and R2020a+ `betainc` raises "X must be in [0,1]" rather than returning NaN silently. Added finite-check guard: `tprob` set to NaN when any tstat is non-finite. Symptom: crash in `LPmodel` at last LP horizon or when IV first stage is degenerate.

- **Fixed:** `VAR/VARlag.m` — EXOG matrix was passed as the `VARopt` argument (4th position). `VARmodel` errored immediately trying to access `VARopt.ident` on a numeric matrix. Corrected argument order.

- **Fixed:** `VAR/VARhdplot.m` — stacked-area mode used wrong slice dimension: `HD.shock(:,:,ii)` (all variables for shock `ii`) instead of correct `(time, shock_j, variable_i)` convention. Every stacked-area historical decomposition plotted the wrong variable and showed a "Data" line that did not match actual data. Fixed slice and reference line.

- **Fixed:** `VAR/compute_HD.m` — `HDexo_big` was not reset between `for ii=1:nvar_ex` iterations. Iteration `ii=2` started with `ii=1` values, contaminating `HDexo(:,:,2)` and beyond. Added `HDexo_big(:) = 0` at loop start.

- **Fixed:** `VAR/compute_HD.m` — when `VAR.ncoeff_es > 0` (exoshock active), the column offset read from the exoshock block of `F` instead of the EXOG block. Corrected from `nvar*nlag + const + ii` to `nvar*nlag + const + VAR.ncoeff_es + ii`.

- **Fixed:** `VAR/OLSmodel.m` — for `const=2`, regressor matrix corrected. Toolbox-wide convention: `const=1` constant only; `const=2` constant + linear trend. Guards updated throughout.

- **Fixed:** `VAR/recover_B.m` — `ident='exog'` previously returned a rank-deficient `B = [δ·σ_z, 0, …, 0]`. `compute_HD` backed out structural shocks via `eps = B\u`, a degenerate solve when `B` is singular. Fix: the identified impact column is now completed to a full-rank `B` via the same Cholesky–QR step used for `iv`. Factored into local `complete_B(b1, sigma, nvar)`, called by both `iv` and `exog` branches. The `iv` result is byte-identical; both externally-identified schemes now handled identically.

- **Fixed:** `Utils/CommonSample.m` — trailing-NaN counter loop had no `break` after finding the first non-NaN from the end. Interior NaNs were miscounted as trailing. Added `else; break` in both `dim=1` and `dim=2` branches.

- **Fixed:** `Utils/datatreat.m` — log guards used `< 0`, leaving zeros unprotected; `log(0) = -Inf` propagated silently. Changed to `<= 0`; updated warning message.

- **Fixed:** `Stats/PairCorrUnbalanced.m` — denominator `n` for log-difference correlations was taken from the level-correlation NaN pattern. In unbalanced panels the two patterns differ. Now computes separate `n_lev` and `n_dif` denominators.

- **Fixed:** `Stats/SummStats.m` — `max`/`min` propagated NaN, contradicting the stated "NaN values are ignored throughout" behavior. Changed to `max(DATA, [], 'omitnan')` and `min(DATA, [], 'omitnan')`.

- **Fixed:** `Figure/PlotStatesShaded.m` — `nargin < 3` guard should have been `nargin < 4`. When called with exactly 3 arguments the `else` branch ran and accessed undefined `color`.

- **Fixed:** `Stats/PairCorr.m` — no guard before `log()` on input data; zeros or negatives silently produced `-Inf`. Added zero/negative check with warning and NaN fallback, matching `PairCorrUnbalanced.m`.

- **Fixed:** `Stats/MovAvgCent.m` and `Stats/MovCorrCent.m` — when `nobs == 2*window` the rolling loop was empty, producing all-NaN output with no error. Added `if nobs < 2*window+1; error(...)` guard.

- **Fixed:** `VAR/LPmodel.m` — constant silently dropped from the regression when `CONTROLS` was empty. Now deterministic component always built explicitly and prepended. `ntotcoeff` missing `const` in the `nvarCTRL==0` branch; unified as `1 + size(controls, 2)`.

- **Fixed:** `Primer/VARToolbox_Primer.m` — critical: section 13 standalone block applied a log-level (code 1) instead of a log-difference (code 3) transform to GDP, producing a non-stationary log-level series mislabeled as GDP growth; the VAR was misspecified and its IRFs economically meaningless. Fixed to the log-difference transform.

- **Fixed:** `Primer/VARToolbox_Primer.m` — section 13.1 called `VARhdplot(VAR_sr.HD, VARopt)` instead of `VARirplot(VAR_sr.IR, VARopt)`. Fixed.

- **Fixed:** `Primer/VARToolbox_Primer.m` — removed `'cpi'` from the `tnames` transform list in Section 2; the series does not exist in `Primer_Data.xlsx` (which has only `gdp` and `i1yr`), causing a struct field error on every run.

---

### Code — Other fixes and improvements

**VAR/**
- **Fixed:** `VAR/VARprint.m` — added label block for exoshock regressors when `ident='exog'`; removed always-true dead-code guard `if exist('vnames_ex','var')`. Replaced 5 `eval` calls with dynamic field notation; simplified redundant `cell2mat`+`num2str` on already-string cells. Now reads per-equation sub-structs via `VAR.eqnames`; falls back to `eq1,...,eqN` when `VAR.eqnames` is absent.
- **Fixed:** `VAR/VARmodel.m` — replaced `eval(['VAR.' aux '...'])` pattern (11 calls) with dynamic field notation across the equation-by-equation OLS loop. `VAR.HDall` in non-sign bootstrap path now stored as complete struct; sign-restriction block now copies `SRout.HDall` and computes `VAR.HDbar/HDinf/HDsup`; empty placeholder fields `VAR.B`, `VAR.IR`, `VAR.VD`, `VAR.HD` (initialized before branching) removed via `rmfield` at end of sign block; early guard against unrecognised `ident` values; spurious `[]` placeholder in recursive bootstrap call corrected. Replaced four separate identification subsections with a single `if/else` dispatch block. Ex-post zeroing of unidentified shocks now applies to both `iv` and `exog`: columns 2:n of stored `VAR.B`, `VAR.IR`, `VAR.VD` and `HD.shock(:,2:n)` set to zero.
- **Fixed:** `VAR/VARoption.m` — corrected the stale `mnem` comment; it now reads "Falls back to eq1,...,eqN if empty or invalid," matching the actual fallback in `VARmodel.m` (the complementary `vnames`→`mnem` and `snames`→`vnames` fallbacks were checked and are correct).
- **Fixed:** `VAR/VARirplot.m` — stale header example corrected to use `VARoption`/`VARmodel`/`VARirplot` correctly.
- **Fixed:** `VAR/VARvdplot.m` — stacked-area suptitle now always uses `'a'` as panel letter; previously used `Alphabet(ii)` at loop exit. Legend now uses captured axes handle from last panel rather than re-calling `subplot` (which created a new empty axes after `TitlePad` resize, orphaning plot handles).
- **Fixed:** `VAR/VARhdplot.m` — legend uses captured axes handle from last panel (same fix as `VARvdplot`). Both `DatesPlot` calls: requested x-axis tick count reduced from 8 to 5 (default); replaced hardcoded count with `VARopt.datenticks` (guarded by `isfield`/`~isempty`; falls back to 5 for legacy structs). Symptom of old value: HD year labels rendered slanted (~30°) because 8 four-digit labels no longer fit horizontally at FontSize 12.
- **Fixed:** `VAR/compute_VD.m` — moved total MSE computation out of the outer shock loop; MSE does not depend on shock index `ii` and was being recomputed `nvar` times identically.
- **Fixed:** `VAR/VARdrawpost.m`, `VAR/SR.m`, `VAR/VARhdplot.m`, `VAR/compute_IR.m`, `VAR/SignRestrictions.m`, `VAR/compute_HD.m` — header examples used `[VAR, VARopt] = VARmodel(...)` or `[VAR, ~] = VARmodel(...)`; fixed to `VAR = VARmodel(...)`.
- **Fixed:** `VAR/SR.m` — dead counter `narr_sign_pass` (initialized to 0, incremented but never read) removed.
- **Fixed:** `VAR/recover_B.m` — removed `'sign'` from error message listing valid `ident` values.
- **Fixed:** `VAR/L.m` — header description of `nlag` sign convention was backwards; corrected to "positive = lead; negative = lag".
- **Fixed:** `VAR/VARmakelags.m` and `VAR/VARmakexy.m` — block comments had the lag order reversed; corrected to match actual construction.
- **Fixed:** `VAR/SignRestrictions.m` — removed 5 commented-out `disp` calls and 1 commented-out `error` call from the `counter > sr_rot` block. Detection of hybrid mode now checks `VARopt.ident == 'sign+iv'` instead of `isempty(VAR.Biv)`.
- **Fixed:** `VAR/LPmodel.m` — internal deterministic variable `det` renamed to `detc` to avoid shadowing MATLAB built-in `det`; loop index `i` renamed to `ii` to avoid shadowing imaginary unit. Symptom: masked determinant function in scope.
- **Changed:** `VAR/VARirplot.m`, `VAR/VARvdplot.m`, `VAR/VARhdplot.m`, `VAR/VARprint.m`, `VAR/LPirplot.m` — display labels now read `vnames` first and fall back to `mnem` when `vnames` is empty, so a single field always yields usable plot/table labels; `snames` default inherits the resolved (fallback-aware) `vnames`. Field names for sub-structs read `mnem` exclusively (`vnames` is never used for field names).
- **Changed:** `VAR/SR.m` — `if VARopt.sr_mod == 1` → `if VARopt.inference == 1`; `SRout.B/IR/VD/HD` → `SRout.Bfp/IRfp/VDfp/HDfp`; `HDmed/HDinf/HDsup` now computed as full structs inside SR.m and propagated to VARmodel. Completed OUTPUT section listing all `SRout` fields; added comment for 0-indexed draw field naming.
- **Changed:** `VAR/SR.m` — narrative-restriction `.period` (in `R.narr_sign`/`R.narr_dom`) is now indexed against the input data passed to `VARmodel`, so the integer and date-string forms are consistent: an integer is the input-data row, a date string is matched against `VARopt.dates`, and both refer to the same observation. `resolve_period` subtracts `nlag` from the numeric input (previously it used the integer directly as a residual-sample index, leaving it offset from the date-string form by `nlag`) and rejects periods inside the lag window with a new `SR:periodTooEarly` error. Verified: a string period and the equivalent integer row yield bit-identical `Bmed`/`IRmed`/acceptance. No existing script affected — all current callers (Primer, ADRR2018 replication) use date strings.
- **Changed:** `VAR/VARoption.m` — marked `datesnum`, `datestxt`, `datestype` as deprecated; added `VARopt.dates = []`; removed inline `set(groot,...)` calls (Primer sets groot defaults explicitly); updated `inference` comment to document unified semantics across all identification schemes; `inference` default changed from `0` to `1`.
- **Changed:** `VAR/VARmodel.m` — updated header comments on `inference` flag to reflect unified semantics; `compute_VD` and `compute_HD` now run for all point-identified schemes including `iv` (removed `~strcmp(VARopt.ident,'iv')` guard); `IRmed/VDmed/HDmed` renamed to `IRbar/VDbar/HDbar` (bootstrap mean); `HDbar/HDinf/HDsup` now full structs; `IRbar/VDbar` recomputed as mean rather than median.
- **Changed:** `VAR/LPoption.m` — removed inline `set(groot,...)` calls; `LPopt.IV` and `nlag_iv` documentation now describe `.IV` as the external instrument.
- **Changed:** `VAR/VARirplot.m`, `VAR/VARvdplot.m`, `VAR/VARhdplot.m` — stale function-name references in headers updated from `VARir`/`VARvd`/`VARhd` to `VARmodel`. Font sizes bumped +1: titles 13→14, axis/tick labels 11→12, legends 10→11.
- **Changed:** `VAR/LPirplot.m` — font sizes bumped +1: titles 13→14, axis/tick labels 11→12, legends 10→11.
- **Changed:** `VAR/recover_B.m` — IV identification block now completes B to a full invertible matrix via Cholesky-QR; factored into shared `complete_B` local function used by both `iv` and `exog` branches. `exog` branch now returns full-rank B (previously rank-deficient). IV result byte-identical.
- **Changed:** `VAR/LPmodel.m` — sample trimming now uses `lag_trim = max(nlag, nlag_ex)` uniformly; `EXOG` now supports lagged entry via `nlag_ex > 0`; renamed `det`→`detc` and `i`→`ii` (built-in shadowing fix above).
- **Changed:** `VAR/VARmakexy.m` — removed `elseif const==3` block; `else` now raises `error`.
- **Changed:** `VAR/OLSmodel.m` — removed `elseif const==3` block; added `if const > 2; error(...)` guard before det construction.
- **Changed:** `VAR/build_LAGplus.m` — removed `elseif const==3` branch; error message updated to report valid range [0,2].
- **Changed:** `VAR/compute_HD.m` — removed section 6 (quadratic trend contribution), `HDtrend2` variable, its contribution in `HDendo`, and `HD.trend2` output field.
- **Changed:** All 27 `.m` files in `VAR/` — version tag updated to "4.0".

**Figure/**
- **Fixed:** `Figure/AreaPlot.m` and `Figure/BarPlot.m` — hold state saved before drawing and restored on return; `hold on` no longer left the axes in hold-on state after return.
- **Fixed:** `Figure/LegPlot.m` — `axpos(4) = 1 - 1.1*legpos(4)` replaced with `axpos(4) = axpos(4) - 1.1*legpos(4)`; original replaced axes height with an absolute value.
- **Fixed:** `Figure/PlotStatesShaded.m` — unconditional `hold off` replaced with save-and-restore of caller's hold state.
- **Changed:** `Figure/PlotStatesShaded.m` — axes font bumped +1 (11→12) to match the toolbox figure convention.
- **Fixed:** `Figure/PlotSwathe.m` — `'openGL'` (mixed case) corrected to `'opengl'`; mixed case not recognized on all MATLAB versions.
- **Fixed:** `Figure/DatesPlot.m` — monthly section: `0.0833` approximation replaced with exact `1/12`; `fo_diff` now uses `round(12*(fo-fo_year))` to avoid floating-point misparse.
- **Fixed:** `Figure/FigFont.m` — dead-code guard `~exist('fsize','var')` replaced with `nargin < 1`.
- **Fixed:** `Figure/NumTotFigures.m` — removed dead `clear p q` call.
- **Fixed:** `Figure/Date2Cell.m` — output strings now use lowercase separators (`'1992q2'`) matching `DatesCreate.m`; removed `format long g` global side effect.
- **Fixed:** `Figure/Date2Num.m` — removed `format long` global side effect.
- **Fixed:** `Figure/FigSize.m` — `exist('xdim','var')` / `exist('ydim','var')` replaced with `nargin >= 1` / `nargin >= 2`.
- **Fixed:** `Figure/cmap.m` — entry 3 had wrong RGB labelled "BoEGreen"; corrected.
- **Changed:** `Figure/SetAxesDual.m` — appended `TitlePad(get(ax,'Title'),2)` as a final "Title spacing" step, called last so it survives `yyaxis` ruler switches earlier in the function (which reset the title to its default position). All toolbox panels styled by `SetAxesDual` now share uniform title spacing.
- **Changed:** `Figure/LegPlot.m` — added `'Box', 'off'` to legend `set()` call to match `LegSubplot.m`.
- **Removed:** `Figure/PlotLineOption.m` — deleted dead fields `opt.interpr`, `opt.bins`, `opt.SupTitle` (never read by `PlotLine.m`).
- **Changed:** `Figure/AreaPlot.m` — set `FaceAlpha = 0.2` on all area series.
- **Changed:** `Figure/pantone.m` — BoE colors reordered for maximum perceptual contrast: BoEblue, BoEred, BoEgreen, BoEpurple, BoEorange, BoEacqua, BoEpink, BoEgold, BoEnavy, BoEpeach, BoEyellow, BoEstone.
- **Changed:** All 23 `.m` files in `Figure/` — version tag updated to "4.0".

**Stats/**
- **Fixed:** `Stats/PairCorrUnbalanced.m` — off-diagonal constant pairs changed from `0` to `NaN` to match `CorrUnbalanced.m` and avoid biasing the pairwise average.
- **Changed:** All 15 `.m` files in `Stats/` — version tag updated to "4.0"; section names converted to ALL CAPS.

**Utils/**
- **Fixed:** `Utils/NaN2Num.m` and `Utils/Num2NaN.m` — element-wise loops replaced with vectorized logical indexing.
- **Fixed:** `Utils/roundnum2cell.m` — format string pre-computed outside loop; redundant `round()` before `sprintf` removed.
- **Changed:** All 11 `.m` files in `Utils/` — version tag updated to "4.0".

**Replic/**
- **Fixed:** `Replic/SW2001/GO_SW2001.m` — `VARopt.snames` was in wrong order relative to Cholesky ordering; corrected. Section 6 print labels, bootstrap-method comment, and VD index comment corrected.
- **Fixed:** `Replic/GK2015/GO_GK2015.m` — NOTES block said "200 draws"; corrected to match `VARopt.ndraws = 500`.
- **Fixed:** `Replic/ADRR2018/GO_ADRR2018.m` — header and NOTES block said "Figure 8"; script replicates Figure 6; corrected throughout. Replaced `VARopt.sr_mod = 1` with `VARopt.inference = 1`; set `VARopt.inference = 1` explicitly.
- **Fixed:** `Replic/Uhlig2005/GO_Uhlig2005.m` — `store` array used in loop without pre-allocation; added `store = zeros(Xnvar, 2)` before loop. Set `VARopt.inference = 1` explicitly.
- **Fixed:** `Replic/BQ1989/GO_BQ1989.m` — "GDP" → "GNP" in all comment lines and string labels; Blanchard and Quah (1989) use US GNP.
- **Fixed:** `Replic/Uhlig2005/GO_Uhlig2005.m` — "Real GDP" → "Industrial production" in comment lines; Uhlig (2005) uses industrial production as the first variable.
- **Fixed:** `Replic/JT2025/GO_JT2025.m` — Sections 2–3 figure titles rendered `\textbf{...}` literally because a no-op `LPoption;` stood where the other replication scripts set the LaTeX interpreter defaults; replaced with the standard three `set(groot,...)` lines.
- **Changed:** `Replic/{BQ1989,ADRR2018,GK2015,SW2001,Uhlig2005}/GO_*.m` — set `VARopt.mnem` to the variable mnemonics before estimation so VAR sub-structs are named (e.g. ADRR/Uhlig: `y,pi,comm,res,nbres,ff`; GK: `gs1,logcpi,logip,ebp`; SW: `infl,unemp,ff`; BQ: `y,u`). JT2025 sub-struct naming unchanged (single-outcome LPs).
- **Changed:** All six `Replic/*/GO_*.m` scripts — `xlsread` → `readcell`; single-output `VARmodel` API; `VARopt.inference=1`; removed `VARir`/`VARirband`; added `rng(42, 'twister')`; added `VARopt.firstdate` and `VARopt.frequency`; standardized `FigSize` to `FigSize(24, 6*nrows)`; font sizes bumped +1 (titles 13→14, labels 11→12); deterministic argument `det` → `detc`. Data-load header rows now read `vnames` (full display names) and `mnem` (mnemonics), with `DATA` keyed by `mnem`.
- **Changed:** `Replic/JT2025/GO_JT2025.m` — LP-IV call updated to new TREAT/LPopt.IV convention: `LPopt_IV.IV = RRCGShock_IV` (instrument), `LP_IV = LPmodel(urate_IV, ffr_IV, CTRL_IV, 6, 1, LPopt_IV)` (FFR treatment as `TREAT`). Verified end-to-end: completes without error; LP-IV IRF unchanged.
- **Changed:** `Replic/SW2001/GO_SW2001.m` — data plot: `FigSize(24,6)` / `subplot(1,3)` → `FigSize(12,12)` / `subplot(2,2)`.
- **Changed:** `Replic/BQ1989/GO_BQ1989.m` — data plot: `FigSize(24,6)` → `FigSize(12,6)`.
- **Changed:** `Replic/Uhlig2005/GO_Uhlig2005.m` — data plot and rotation plots: `FigSize(24,12)` / `subplot(2,3)` → `FigSize(12,18)` / `subplot(3,2)`.
- **Changed:** `Replic/ADRR2018/GO_ADRR2018.m` — data plot: `FigSize(24,12)` / `subplot(2,3)` → `FigSize(12,18)` / `subplot(3,2)`.
- **Changed:** `Replic/GK2015/GO_GK2015.m` — data plot: `FigSize(24,12)` / `subplot(2,3)` → `FigSize(12,18)` / `subplot(3,2)`.
- **Changed:** All seven `.m` files in `Replic/` — version tag updated to "4.0".

**Primer/**
- **Fixed:** `Primer/VARToolbox_Primer.m` — hardcoded absolute `addpath` path replaced with `fileparts(fileparts(mfilename('fullpath')))`.
- **Fixed:** `Primer/VARToolbox_Primer.m` — corrected four section comments that incorrectly labelled `VAR_infer.IRmed`, `VDmed`, `HDmed` as "Fry-Pagan"; they are the element-wise median, not the Fry–Pagan draw. Added caveat to VD section comment that shares need not sum to 100%.
- **Fixed:** `Primer/VARToolbox_Primer.m` — `SaveFigure('graphics/signFP')` renamed to `SaveFigure('graphics/signMed')` in section 6.3. Figure shows `IRmed` (element-wise median), not the Fry–Pagan draw (`IRfp`).
- **Removed:** `Primer/VARToolbox_Primer.m` — dead `rmpath` call for a path never added by this script.
- **Changed:** `Primer/VARToolbox_Primer.m` — `xlsread` → `readcell` throughout; `bfeps` updated for tex interpreter; explicit `set(groot,...)` calls for Helvetica font and LaTeX interpreter added at section 0; updated to new `LPmodel` signature; deterministic argument `det` → `detc`; sets `VARopt.inference = 0` explicitly at §3 (persists through §9) and `VARopt_exog.inference = 0` at §10, preserving point-estimate exposition; §11 onward enables `inference = 1` as before.
- **Changed:** `Primer/VARToolbox_Primer.m` (§2) — replaced the manual transform loop with the single call `DATA = datatreat(DATA,tnames,ttreat,tscale)`; the log-differenced GDP series is now stored as `dlngdp` (was `dgdp`), with all downstream references renamed (`Xmnem`, `VAR_redform.dlngdp`, `LP.dlngdp`).
- **Changed:** `Primer/VARToolbox_Primer.m` (§3.1–3.2) — moved the `CommonSample` call and date-vector trimming to the end of the data-construction block so `X` is balanced ($123\times2$) before it is plotted; renamed the raw spreadsheet count to `nobs_raw` and the post-`CommonSample` working count to `nobs` (was `nobs_cs`); the artificial IV draw `noise = randn(nobs_raw,1)` keeps its 124-element length, so trimmed results are unchanged.
- **Changed:** `Primer/VARToolbox_Primer.m` — renamed the data-load headers to `vnames` (full display names) / `mnem` (mnemonics); set `VARopt.mnem`/`LPopt.mnem` to mnemonics and `.vnames` to display labels.
- **Changed:** `Primer/VARToolbox_Primer.m` (Sec. 12) — LP-IV call updated to new TREAT/LPopt.IV convention: `LPopt_IV.IV = mps` (instrument), `LP_IV = LPmodel(X, X(:,2), X, nlags, detc, LPopt_IV)` (treatment as `TREAT`); §12.1–§12.3 replaced per-variable LP estimation loops with single matrix calls; `LPopt.mnem = {'dlngdp','i1yr'}` so per-variable sub-structs are named `LP.dlngdp`, `LP.i1yr`.
- **Changed:** `Primer/VARToolbox_Primer.m` — font sizes bumped +1 (titles 13→14, labels 11→12). Red series now use diamond markers (`'Marker','d'`): lines for sign-vs-no-sign, median-target overlay, LP vs LP-IV, and LP vs VAR exog. Blue series keep circle markers.

**Exercise/**
- **Rewritten:** `Exercise/Exercise_Solution.m` — fully updated to v4.0 API: `xlsread` → `readcell`; single-output `VARmodel` throughout; removed `VARir`/`VARirband`; IV via `VARopt.IV`; sign restrictions via `VARopt.ident='sign'` and `VARopt.R`; added portable `addpath`, `rng(42)`, and `cd(fileparts(...))`; sets `VARopt.mnem` before each estimation for named sub-structs; data-load headers use `vnames`/`mnem`. Font sizes bumped +1 (title 13→14, axes 11→12).
- **Fixed:** `Exercise/Exercise_Solution.m` — Cholesky and IV plots/comparison referenced `VARchol.IRmed`/`VARiv.IRmed`, but bootstrap/IV `VARmodel` output exposes the central estimate as `IRbar` (only sign restrictions produce `IRmed`). Changed to `IRbar`; the sign-restriction plot keeps `IRmed`.

**Repository / build:**
- **Changed:** `.gitignore` — added `!*.tex` to the tracked-file-types whitelist so the four LaTeX sources (`VAR_Handbook.tex`, `VAR_Primer_Slides.tex`, `VAR_Replic_Slides.tex`, `Exercise/Exercise.tex`) are version-controlled; previously only `.m`, `.pdf`, `.xlsx` were whitelisted.

**All files:**
- **Changed:** All 83 `.m` files in `Utils/`, `Stats/`, `Figure/`, `Replic/`, and `VAR/` — full re-comment pass: sections use `%%`, subsections use single `%`; self-contained inline `EXAMPLES`; `Updated:` date set uniformly; separator borders standardised to 71 characters; double blank lines compressed to single; missing block comments added above all uncommented code blocks.

---

### Manual (`VAR_Handbook.tex`, `VAR_Primer_Slides.tex`, `VAR_Replic_Slides.tex`)

> The handbook (`VAR_Handbook.tex`), both slide decks (`VAR_Primer_Slides.tex`, `VAR_Replic_Slides.tex`), and the bibliography (`BIBLIO.bib`) are **new deliverables in v4.0**: v3.1 shipped no manual. The entries below document the content and authoring decisions of these new documents rather than edits to a pre-existing v3.1 manual.

**Handbook (`VAR_Handbook.tex`)**
- **Added:** `VAR_Handbook.tex` — new v4.0 handbook pairing the theory with its toolbox implementation across the full SVAR pipeline. Covers reduced-form and structural VAR basics, OLS estimation and lag selection, seven identification schemes (short-run, long-run, sign, narrative sign, external instruments, combined sign-IV, exogenous variables), bootstrap and Bayesian inference, structural dynamic analysis (IRFs, FEVDs, historical decompositions), and local projections; an appendix presents the six empirical replications.

**Primer Slides (`VAR_Primer_Slides.tex`)**
- **Added:** `VAR_Primer_Slides.tex` — new v4.0 primer slide deck. Section structure realigned to match handbook §2–§7: (S)VAR basics → Estimation → Identification → Inference → Dynamic Analysis → Local projections.

**Replication Slides (`VAR_Replic_Slides.tex`)**
- **Added:** `VAR_Replic_Slides.tex` — new standalone replication slides deck. Six applications, all using v4.0 API: Stock and Watson (2001), Blanchard and Quah (1989), Uhlig (2005), Antolín-Díaz and Rubio-Ramírez (2018), Gertler and Karadi (2015), Jordà and Taylor (2025). Each application includes data slides, code slides, and figure slides. 
