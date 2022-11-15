# VAR-Toolbox
Ambrogio Cesa-Bianchi's VAR Toolbox.

## Descprition 

The VAR Toolbox is a collection of Matlab routines to perform vector autoregressive (VAR) analysis. The latest version is available in the v3dot0 folder.

Estimation is performed with ordinary least squares (OLS). The VAR Toolbox allows for identification of structural shocks with zero short-run restrictions; zero long-run restrictions; sign restrictions; external instruments (proxy SVAR); and a combination of external instruments and sign restrictions. Impulse Response Functions (IR), Forecast Error Variance Decomposition (VD), and Historical Decompositions (HD) are computed according to the chosen identification. Error bands are obtained with bootstrapping. 

The codes are grouped in six categories (and respective folders):

- VAR: the codes for VAR estimation, identification, computation of the impulse response functions, FEVD, HD.

- Stats: codes for the calculation of summary statistics, moving correlations, pairwise correlations, etc.

- Utils: codes that allow the smooth functioning if the Toolbox.

- Auxiliary: codes that I borrowed from other public sources. Each m-file has a reference to the original source.

- Figure: codes for plotting high quality figures

- ExportFig: this is a toolbox developed by Yair Altman (https://github.com/altmany/export_fig) for exporting high quality figures. To enable this option, the Toolbox requires Ghostscript installed on your computer (freely available at www.ghostscript.com).

## Installation 
No installation is required. Simply clone the folder from Github and add the folder (with subfolders) to your Matlab path. This can be easily done as follows. If you download the toolbox to `/User/VAR-Toolbox/`, you can simply add the following two lines of code at the beginning and end of your script

```
addpath(genpath(’/User/VAR-Toolbox/v3dot0/’))
...
rmpath(genpath(’/User/VAR-Toolbox/v3dot0’)) 
```

To save figures in high quality format, you need to download an install Ghostscript (freely available at www.ghostscript.com). The first time you’ll be saving a figure using the Toolbox, you’ll be asked to locate Ghostscript on your local drive.

## Manual
A manual will be available soon. In the meanwhile, you can information on how to use the VAR Toolbox in the [VAR Primer](https://github.com/ambropo/VAR-Toolbox/blob/main/VAR_Primer_Slides.pdf "VAR Primer"), a slide deck describing the basics of VARs and how to estimate them using the VARToolbox.

## License
The theme is licensed under a GNU General Public License v3.0
