function out = TreatData(data,treat,vnames,dates,DatesOpt)
% =======================================================================
% Treat data.
% =======================================================================
% [nobs, dates] = CountDate(fo_year,lo_year,frequency,fo_period,lo_period)
% -----------------------------------------------------------------------
% INPUT
%	- data: structure where the the data is stored
%	- treat: vector (of length N) with type of treatment
%	- vnames: vector (of length N) with variable names
% -----------------------------------------------------------------------
% OUTPUT
%	- out: matrix of treated data
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

% Retrieve some parameters
nobs = DatesOpt.nobs;
fo_year = DatesOpt.fo_year;
lo_year = DatesOpt.lo_year;
frequency = DatesOpt.frequency;
fo_period = DatesOpt.fo_period;
lo_period = DatesOpt.lo_period;

% Get first
if strcmp(frequency,'y')
    aux = num2str(fo_year);
else
    aux = [num2str(fo_year) frequency num2str(fo_period)];
end
fo = find(strcmp(aux,dates));

% Get last
if strcmp(frequency,'y')
    aux = num2str(lo_year);
else
    aux = [num2str(lo_year) frequency num2str(lo_period)];
end
lo = find(strcmp(aux,dates));

% Initialize matrix 
nvar = length(vnames);
out = nan(nobs,nvar);

for ii=1:nvar
    % No treatment
    if treat(ii)==0
        out(:,ii) = data.(vnames{ii})(fo:lo);
    % Log
    elseif treat(ii)==1
        out(:,ii) = log(data.(vnames{ii})(fo:lo));
    % Log-diff
    elseif treat(ii)==2
        out(:,ii) = XoX(data.(vnames{ii})(fo:lo),1,'logdiff');
    % Diff
    elseif treat(ii)==3
        out(:,ii) = XoX(data.(vnames{ii})(fo:lo),1,'diff');
    end
end