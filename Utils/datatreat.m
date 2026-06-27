function DATA = datatreat(DATA,tnames,ttype,tscale,nlag)
% =======================================================================
% Apply transformations to selected time series stored in the structure
% DATA and write the results back as new fields, following a fixed naming
% convention. For each variable in TNAMES, the transformation in TTYPE is
% applied, the result is multiplied by the rescaling factor in TSCALE, and
% stored in DATA under a prefixed field name:
%
%   code  transformation      prefix   example (gdp)
%   ----  ------------------  -------  -------------
%    1    Log                 ln       lngdp
%    2    First difference    d        dgdp
%    3    Log difference      dln      dlngdp
%    4    Fractional change   g        ggdp
%
% Difference-based transforms (codes 2, 3, 4) use NLAG lags; the first
% NLAG observations of the output are NaN. The function stops with an
% error if a target field name already exists in DATA, to prevent silent
% overwriting.
% =======================================================================
% DATA = datatreat(DATA,tnames,ttype,tscale,nlag)
% -----------------------------------------------------------------------
% INPUT
%   - DATA:   structure whose fields are time series column vectors
%   - tnames: cell array of field names in DATA to transform, e.g.
%             {'gdp','i1yr'}
%   - ttype:  transformation codes, one per variable in TNAMES. Cell array
%             (e.g. {3,2}) or numeric vector (e.g. [3 2]):
%             1 = Log, 2 = First difference, 3 = Log difference,
%             4 = Fractional change
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - tscale: rescaling factors, scalar or one per variable [dflt = 1]
%   - nlag:   number of lags for difference-based transforms [dflt = 1]
% -----------------------------------------------------------------------
% OUTPUT
%   - DATA: input structure augmented with one new field per variable,
%           named <prefix><tnames{ii}> as in the table above
% -----------------------------------------------------------------------
% EXAMPLE
%   DATA.gdp  = cumsum(randn(50,1));
%   DATA.i1yr = cumsum(randn(50,1));
%   DATA = datatreat(DATA,{'gdp','i1yr'},{3,2},[100 1]);
%   % creates DATA.dlngdp (log-diff x100) and DATA.di1yr (first diff)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-06-14
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Require DATA, tnames, and ttype
if nargin < 3
    error('datatreat: DATA, tnames, and ttype are required inputs')
end

% DATA must be a structure of time series
if ~isstruct(DATA)
    error('datatreat: DATA must be a structure of time series')
end

% Normalize tnames and ttype to cell arrays and check matching lengths
if ischar(tnames), tnames = {tnames}; end
if isnumeric(ttype), ttype = num2cell(ttype); end
nv = numel(tnames);
if numel(ttype) ~= nv
    error('datatreat: tnames and ttype must have the same number of elements')
end

% Default rescaling factor: 1 for all. Accept scalar or one per variable
if ~exist('tscale','var') || isempty(tscale)
    tscale = ones(1,nv);
elseif isscalar(tscale)
    tscale = repmat(tscale,1,nv);
elseif numel(tscale) ~= nv
    error('datatreat: tscale must be a scalar or match the number of variables in tnames')
end

% Default lag order for difference-based transforms
if ~exist('nlag','var') || isempty(nlag)
    nlag = 1;
end

% Field-name prefix by transformation code (index = code)
prefix = {'ln','d','dln','g'};

%% 2. APPLY TRANSFORMATIONS
% -----------------------------------------------------------------------
for ii = 1:nv
    vname = tnames{ii};
    code  = ttype{ii};

    % Source variable must exist in DATA
    if ~isfield(DATA,vname)
        error('datatreat: variable ''%s'' not found in DATA',vname)
    end

    % Validate transformation code (0 = no treatment is no longer supported)
    if ~ismember(code,1:4)
        error(['datatreat: ttype for ''%s'' must be 1 (Log), 2 (Difference), ' ...
               '3 (Log difference), or 4 (Fractional change)'],vname)
    end

    % Build the target field name from the prefix convention
    oname = [prefix{code} vname];

    % Stop if the target field already exists, to avoid silent overwriting
    if isfield(DATA,oname)
        error(['datatreat: field ''%s'' already exists in DATA; ' ...
               'remove or rename it before re-running'],oname)
    end

    % Apply transformation, rescale, and store
    DATA.(oname) = tscale(ii) * transform(DATA.(vname),code,nlag);
end

end

%% LOCAL FUNCTION: elementwise transformation on a single series
% -----------------------------------------------------------------------
function out = transform(x,code,nlag)
% Apply one transformation to x. Leading nlag rows are NaN for
% difference-based transforms (codes 2, 3, 4).
[nobs,nvar] = size(x);
out = nan(nobs,nvar);

switch code
    % Log
    case 1
        if any(x(:)<=0), warning('datatreat: non-positive values set to NaN before taking logs'), end
        x(x<=0) = NaN;
        out = log(x);

    % First difference
    case 2
        out(nlag+1:end,:) = x(1+nlag:end,:) - x(1:end-nlag,:);

    % Log difference
    case 3
        if any(x(:)<=0), warning('datatreat: non-positive values set to NaN before taking logs'), end
        x(x<=0) = NaN;
        out(nlag+1:end,:) = log(x(1+nlag:end,:)) - log(x(1:end-nlag,:));

    % Fractional change
    case 4
        out(nlag+1:end,:) = x(1+nlag:end,:)./x(1:end-nlag,:) - 1;
end

end
