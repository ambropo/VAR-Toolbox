# VAR Toolbox
Ambrogio Cesa-Bianchi's VAR Toolbox — version 4.0.

## Description

The VAR Toolbox is a collection of MATLAB routines for vector autoregressive (VAR) and local projection (LP) analysis. Estimation is performed with ordinary least squares (OLS). Structural shocks are identified with seven schemes:

1. Zero contemporaneous restrictions
2. Zero long-run restrictions
3. Sign restrictions
4. Narrative sign restrictions
5. External instruments — proxy SVAR
6. External instruments combined with sign restrictions
7. Exogenous variable identification

Impulse Response Functions (IR), Forecast Error Variance Decompositions (VD), and Historical Decompositions (HD) are computed for all identification schemes. Bootstrap error bands are available for all schemes except pure sign restrictions, which use a Bayesian approach.

Local projections (LP) are also supported, with OLS and IV estimation, Newey-West inference, and direct horizon-by-horizon IRFs.

## Documentation

- **Handbook** (`VAR_Handbook.pdf`): covers the theoretical foundations of VAR analysis — from OLS estimation and the identification problem to impulse responses, variance decompositions, and historical decompositions — alongside the MATLAB implementation at each step. Intended for PhD economists. Available in the [repository](https://github.com/ambropo/VAR-Toolbox).

- **Primer** (`Primer/VARToolbox_Primer.m`): a self-contained tutorial script that walks through every toolbox feature — estimation, all identification schemes, inference, and plotting — with a real dataset. Recommended starting point for new users.

- **Primer slides** (`VAR_Primer_Slides.pdf`): slide deck accompanying the Primer, summarizing the key results and figures. Available in the [repository](https://github.com/ambropo/VAR-Toolbox).

- **Replication slides** (`VAR_Replic_Slides.pdf`): slide deck covering all six replication exercises, with data, code, and figures for each application. Available in the [repository](https://github.com/ambropo/VAR-Toolbox).

## Folders

- **VAR**: core routines for VAR and LP estimation, all identification schemes, impulse responses, variance decompositions, historical decompositions, and bootstrap inference.

- **Figure**: routines for producing publication-quality figures, including panel IRF plots, stacked-area charts, date-formatted axes, and color palettes.

- **Stats**: routines for summary statistics, pairwise and cross-correlations (balanced and unbalanced panels), moving averages, moving correlations, and related transformations.

- **Utils**: utility routines for data handling, sample alignment, and table formatting.

- **Auxiliary**: third-party code from public sources. Each file cites the original source.

- **Primer**: tutorial script and accompanying dataset (see Documentation above).

- **Exercise**: a student exercise (`Exercise.pdf`) with full solution (`Exercise_Solution.m`).

- **Replic**: replication scripts for six papers in the VAR literature:
  - Stock and Watson (2001) — Cholesky identification
  - Blanchard and Quah (1989) — long-run zero restrictions
  - Uhlig (2005) — sign restrictions
  - Gertler and Karadi (2015) — external instruments
  - Antolín-Díaz and Rubio-Ramírez (2018) — narrative sign restrictions
  - Jordà and Taylor (2025) — local projections OLS and IV

## Installation

No installation is required. Clone the repository and add the toolbox folder (with subfolders) to your MATLAB path. If you download the toolbox to `/User/VAR-Toolbox/`, add the following two lines at the beginning and end of your script:

```matlab
addpath(genpath('/User/VAR-Toolbox/'))
...
rmpath(genpath('/User/VAR-Toolbox/'))
```

## License
Licensed under the GNU General Public License v3.0.
