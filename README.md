# VAR-Toolbox
Ambrogio Cesa-Bianchi's VAR Toolbox

The VAR Toolbox is a collection of Matlab routines to perform VAR analysis. The VAR Toolbox allows for identification of structural shocks with zero short-run restrictions; zero long-run restrictions; sign restrictions; external instruments (proxy SVAR); and a combination of external instruments and sign restrictions. Impulse Response Functions (IR), Forecast Error Variance Decomposition (VD), and Historical Decompositions (HD) are computed according to the chosen identification. Error bands are obtained with bootstrapping. The VAR Toolbox makes use of few Matlab routines from the Econometrics Toolbox for Matlab by James P. LeSage (freely available at www.spatial-econometrics.com). It also includes a collection of Matlab routines that allows the user to save and export high quality images from Matlab (using the Export_fig function by Oliver Woodford, freely available at https://www.mathworks.com/matlabcentral/fileexchange/23629-export_fig). To enable this option, the Toolbox requires Ghostscript installed on your computer (freely available at www.ghostscript.com).

The VAR Toolbox is not meant to be efficient, but rather to be transparent and allow the user to understand the econometrics of VARs step by step. The codes are grouped in six categories (and respective folders):

- Auxiliary: codes that I borrowed from other public sources. Each m-file has a reference to the original source.

- ExportFig: this is a toolbox available at Oliver Woodford's website for exporting high quality figures.

- Figure: codes for plotting high quality figures

- Stats: codes for the calculation of summary statistics, moving correlations, pairwise correlations, etc.

- Utils: codes that allow the smooth functioning if the Toolbox.

- VAR: the codes for VAR estimation, identification, computation of the impulse response functions, FEVD, HD.
