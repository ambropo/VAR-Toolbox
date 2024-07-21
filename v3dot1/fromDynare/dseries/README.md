[![pipeline status](https://git.dynare.org/Dynare/dseries/badges/master/pipeline.svg)](https://git.dynare.org/Dynare/dseries/commits/master)

This MATLAB/Octave toolbox comes with three classes:

 - `@dates` which is used to handle dates.
 - `@dseries` which is used to handle time series data.
 - `@x13` which provides an interface to X13-ARIMEA-SEATS.

The package is a dependence of
[Dynare](https=//git.dynare.org/Dynare/dynare), but can also be used
as a standalone package without Dynare. The package is
compatible with MATLAB 2008a and following versions, and (almost
compatible with) the latest Octave version.

## Installation

The toolbox can be installed by cloning the Git repository:

    ~$ git clone https://git.dynare.org/Dynare/dseries.git

or downloading a zip archive:

    ~$ wget https://git.dynare.org/Dynare/dseries/-/archive/master/dseries-master.zip
    ~$ unsip dseries-master.zip
    -$ mv dseries-master dseries

## Usage

Add the `dseries/src` folder to the MATLAB/Octave path, and run the following command (on MATLAB/Octave) prompt:

    >> initialize_dseries_class

which, depending on your system, will add the necessary subfolders to
the MATLAB/Octave path.

You are then ready to go. A full documentation is available in the Dynare
reference manual.

Note that [X13-ARIMA-SEATS](https://www.census.gov/srd/www/x13as/) is required
for accessing all the features of the toolbox. On Windows and macOS, an
X13-ARIMA-SEATS binary is included in standalone dseries packages and in Dynare
packages. On Debian and Ubuntu it is possible to install X13-ARIMA-SEATS with
`apt install x13as` (on Debian, you must have the non-free archive area listed
in package sources).

## Examples

### Instantiate a dseries object from an array

    >> A = randn(50, 3);
    >> d = dseries(A, dates('2000Q1'), {'A1', 'A2', 'A3'});

The first argument of the `dseries` constructor is an array of data,
observations and variables are respectively along the rows and
columns. The second argument is the initial period of the dataset. The
last argument is a cell array of row character arrays for the names of
the variables.

    >> d

    d is a dseries object:

           | A1       | A2        | A3
    2000Q1 | -1.0891  | -2.1384   | -0.29375
    2000Q2 | 0.032557 | -0.83959  | -0.84793
    2000Q3 | 0.55253  | 1.3546    | -1.1201
    2000Q4 | 1.1006   | -1.0722   | 2.526
    2001Q1 | 1.5442   | 0.96095   | 1.6555
    2001Q2 | 0.085931 | 0.12405   | 0.30754
    2001Q3 | -1.4916  | 1.4367    | -1.2571
    2001Q4 | -0.7423  | -1.9609   | -0.86547
    2002Q1 | -1.0616  | -0.1977   | -0.17653
    2002Q2 | 2.3505   | -1.2078   | 0.79142
           |          |           |
    2009Q4 | -1.7947  | 0.96423   | 0.62519
    2010Q1 | 0.84038  | 0.52006   | 0.18323
    2010Q2 | -0.88803 | -0.020028 | -1.0298
    2010Q3 | 0.10009  | -0.034771 | 0.94922
    2010Q4 | -0.54453 | -0.79816  | 0.30706
    2011Q1 | 0.30352  | 1.0187    | 0.13517
    2011Q2 | -0.60033 | -0.13322  | 0.51525
    2011Q3 | 0.48997  | -0.71453  | 0.26141
    2011Q4 | 0.73936  | 1.3514    | -0.94149
    2012Q1 | 1.7119   | -0.22477  | -0.16234
    2012Q2 | -0.19412 | -0.58903  | -0.14605

    >>

### Instantiate a dseries object from a file

It is possible to instantiate a `dseries` object from a `.csv`,
`.xls`, `.xlsx`, `.mat` or `m` file, see the Dynare reference manual
for a complete description of the constraints on the content of these
files.

    >> websave('US_CMR_data_t.csv', 'https://www.dynare.org/Datasets/US_CMR_data_t.csv');
    >> d = dseries('US_CMR_data_t.csv');
    >> d

    d is a dseries object:

           | gdp_rpc       | conso_rpc     | inves_rpc     | defgdp  |  ...  | networth_rpc | re        | slope      | creditspread
    1980Q1 | 47941413.1257 | NaN           | NaN           | 0.40801 |  ...  | 33.6814      | 0.15047   | -0.0306    | 0.014933
    1980Q2 | 46775570.3923 | NaN           | NaN           | 0.41772 |  ...  | 32.2721      | 0.12687   | -0.0221    | 0.028833
    1980Q3 | 46528261.9561 | NaN           | NaN           | 0.42705 |  ...  | 36.6499      | 0.098367  | 0.011167   | 0.022167
    1980Q4 | 47249592.2997 | NaN           | NaN           | 0.43818 |  ...  | 39.4069      | 0.15853   | -0.0343    | 0.022467
    1981Q1 | 48059176.868  | NaN           | NaN           | 0.44972 |  ...  | 37.9954      | 0.1657    | -0.0361    | 0.0229
    1981Q2 | 47531422.174  | NaN           | NaN           | 0.45863 |  ...  | 38.6262      | 0.1778    | -0.0403    | 0.0202
    1981Q3 | 47951509.5055 | NaN           | NaN           | 0.46726 |  ...  | 36.3246      | 0.17577   | -0.0273    | 0.016333
    1981Q4 | 47273009.6902 | NaN           | NaN           | 0.47534 |  ...  | 34.8693      | 0.13587   | 0.005      | 0.025933
    1982Q1 | 46501690.1111 | NaN           | NaN           | 0.48188 |  ...  | 32.0964      | 0.14227   | 0.00066667 | 0.027367
    1982Q2 | 46525455.3206 | NaN           | NaN           | 0.48814 |  ...  | 31.6967      | 0.14513   | -0.0058333 | 0.0285
           |               |               |               |         |  ...  |              |           |            |
    2016Q1 | 85297205.4011 | 51926452.5716 | 21892729.0934 | 1.0514  |  ...  | 420.7154     | 0.0016    | 0.0203     | 0.0323
    2016Q2 | 85407205.5913 | 52096454.9154 | 21824323.7487 | 1.0506  |  ...  | 398.7084     | 0.0036    | 0.0156     | 0.0339
    2016Q3 | 85796604.1157 | 52436447.9843 | 21874814.014  | 1.0578  |  ...  | 424.8703     | 0.0037333 | 0.0138     | 0.029167
    2016Q4 | 86101149.6919 | 52595613.0404 | 22010921.8985 | 1.0617  |  ...  | 444.622      | 0.0039667 | 0.011667   | 0.026967
    2017Q1 | 86376652.4732 | 52795431.0988 | 22399301.0801 | 1.0672  |  ...  | 450.8777     | 0.0045    | 0.0168     | 0.0251
    2017Q2 | 86982016.8089 | 53164725.076  | 22671020.5449 | 1.0728  |  ...  | 481.8778     | 0.007     | 0.017433   | 0.022167
    2017Q3 | 87605975.0339 | 53451779.0342 | 23033324.7981 | 1.0758  |  ...  | 496.3342     | 0.0095    | 0.013133   | 0.022367
    2017Q4 | 88111231.6601 | 53601437.7291 | 23477516.6946 | 1.081   |  ...  | 509.1968     | 0.011533  | 0.0109     | 0.020867
    2018Q1 | 88557263.9759 | 53960814.0875 | 23726936.444  | 1.0882  |  ...  | 536.4746     | 0.012033  | 0.011667   | 0.019
    2018Q2 | 88817646.3122 | 53931032.9449 | 23989494.0402 | 1.0937  |  ...  | 560.3093     | 0.014467  | 0.013133   | 0.0171
    2018Q3 | 89689102.8539 | 54343965.1391 | 24123408.6269 | 1.1027  |  ...  | 554.472      | 0.017367  | 0.011833   | 0.0186

    >>

### Create time series

Using an existing `dseries` object it is possible to create new time series:

    >> d.cy = d.conso_rpc/d.gdp_rpc

    d is a dseries object:

           | conso_rpc     | creditspread | cy      | defgdp  |  ...  | pinves_defl | re        | slope      | wage_rph
    1980Q1 | NaN           | 0.014933     | NaN     | 0.40801 |  ...  | 145.6631    | 0.15047   | -0.0306    | 65.0376
    1980Q2 | NaN           | 0.028833     | NaN     | 0.41772 |  ...  | 145.6095    | 0.12687   | -0.0221    | 65.1872
    1980Q3 | NaN           | 0.022167     | NaN     | 0.42705 |  ...  | 145.3811    | 0.098367  | 0.011167   | 65.3858
    1980Q4 | NaN           | 0.022467     | NaN     | 0.43818 |  ...  | 144.3745    | 0.15853   | -0.0343    | 65.5028
    1981Q1 | NaN           | 0.0229       | NaN     | 0.44972 |  ...  | 144.6055    | 0.1657    | -0.0361    | 65.4385
    1981Q2 | NaN           | 0.0202       | NaN     | 0.45863 |  ...  | 145.6512    | 0.1778    | -0.0403    | 65.3054
    1981Q3 | NaN           | 0.016333     | NaN     | 0.46726 |  ...  | 144.7545    | 0.17577   | -0.0273    | 65.5074
    1981Q4 | NaN           | 0.025933     | NaN     | 0.47534 |  ...  | 145.4748    | 0.13587   | 0.005      | 65.4142
    1982Q1 | NaN           | 0.027367     | NaN     | 0.48188 |  ...  | 144.924     | 0.14227   | 0.00066667 | 66.1617
    1982Q2 | NaN           | 0.0285       | NaN     | 0.48814 |  ...  | 144.4647    | 0.14513   | -0.0058333 | 65.8827
           |               |              |         |         |  ...  |             |           |            |
    2016Q1 | 51926452.5716 | 0.0323       | 0.60877 | 1.0514  |  ...  | 98.7988     | 0.0016    | 0.0203     | 102.4176
    2016Q2 | 52096454.9154 | 0.0339       | 0.60998 | 1.0506  |  ...  | 98.2923     | 0.0036    | 0.0156     | 102.5282
    2016Q3 | 52436447.9843 | 0.029167     | 0.61117 | 1.0578  |  ...  | 98.1811     | 0.0037333 | 0.0138     | 102.0061
    2016Q4 | 52595613.0404 | 0.026967     | 0.61086 | 1.0617  |  ...  | 98.0833     | 0.0039667 | 0.011667   | 102.1861
    2017Q1 | 52795431.0988 | 0.0251       | 0.61122 | 1.0672  |  ...  | 97.8223     | 0.0045    | 0.0168     | 102.8336
    2017Q2 | 53164725.076  | 0.022167     | 0.61122 | 1.0728  |  ...  | 97.6873     | 0.007     | 0.017433   | 103.4761
    2017Q3 | 53451779.0342 | 0.022367     | 0.61014 | 1.0758  |  ...  | 97.8137     | 0.0095    | 0.013133   | 103.5137
    2017Q4 | 53601437.7291 | 0.020867     | 0.60834 | 1.081   |  ...  | 97.4819     | 0.011533  | 0.0109     | 104.3091
    2018Q1 | 53960814.0875 | 0.019        | 0.60933 | 1.0882  |  ...  | 97.4234     | 0.012033  | 0.011667   | 104.1112
    2018Q2 | 53931032.9449 | 0.0171       | 0.60721 | 1.0937  |  ...  | 97.5643     | 0.014467  | 0.013133   | 104.5487
    2018Q3 | 54343965.1391 | 0.0186       | 0.60591 | 1.1027  |  ...  | 97.8751     | 0.017367  | 0.011833   | 103.7128

    >>

Recursive definitions for new time series are also possible. For
instance one can create a sample from an ARMA(1,1) stochastic process
as follows:

    >> e = dseries(randn(100, 1), '2000Q1', 'e', '\varepsilon');
    >> y = dseries(zeros(100, 1), '2000Q1', 'y');
    >> from 2000Q2 to 2024Q4 do  y(t)=.9*y(t-1)+e(t)-.4*e(t-1);
    >> y

    y is a dseries object:

           | y
    2000Q1 | 0
    2000Q2 | -0.95221
    2000Q3 | -0.6294
    2000Q4 | -1.8935
    2001Q1 | -1.1536
    2001Q2 | -1.5905
    2001Q3 | 0.97056
    2001Q4 | 1.1409
    2002Q1 | -1.9255
    2002Q2 | -0.29287
           |
    2022Q2 | -1.4683
    2022Q3 | -1.3758
    2022Q4 | -1.2218
    2023Q1 | -0.98145
    2023Q2 | -0.96542
    2023Q3 | -0.23203
    2023Q4 | -0.34404
    2024Q1 | 1.4606
    2024Q2 | 0.901
    2024Q3 | 2.4906
    2024Q4 | 0.79661

    >>

Any univariate nonlinear recursive model can be simulated with this approach.
