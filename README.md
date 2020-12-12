# VAR-Toolbox
Ambrogio Cesa-Bianchi's VAR Toolbox

The VAR Toolbox is a collection of Matlab routines to perform vector autoregressive (VAR) analysis. The latest version is available in the v3dot0 folder.

Estimation is performed with ordinary least squares (OLS). The VAR Toolbox allows for identification of structural shocks with zero short-run restrictions; zero long-run restrictions; sign restrictions; external instruments (proxy SVAR); and a combination of external instruments and sign restrictions. Impulse Response Functions (IR), Forecast Error Variance Decomposition (VD), and Historical Decompositions (HD) are computed according to the chosen identification. Error bands are obtained with bootstrapping. 

The codes are grouped in six categories (and respective folders):

- VAR: the codes for VAR estimation, identification, computation of the impulse response functions, FEVD, HD.

- Stats: codes for the calculation of summary statistics, moving correlations, pairwise correlations, etc.

- Utils: codes that allow the smooth functioning if the Toolbox.

- Auxiliary: codes that I borrowed from other public sources. Each m-file has a reference to the original source.

- Figure: codes for plotting high quality figures

- ExportFig: this is a toolbox developed by Yair Altman (https://github.com/altmany/export_fig) for exporting high quality figures. To enable this option, the Toolbox requires Ghostscript installed on your computer (freely available at www.ghostscript.com).

