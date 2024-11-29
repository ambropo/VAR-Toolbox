function clearex(varargin)
%% This function clear all workspace
% except for one or more selected variable
%
% File created on Feb 15th 2008
%
% Last modified: Feb 15th 2008
%
% Author: Arnaud Laurent
%
%   Inputs: name of variables to keep (e.g. 'a','b','c')
%   Note: It is possible to use wildcard (e.g. 'a*')

a = evalin('base','who');
var = cell(size(varargin));
for i=1:nargin
    var{i}=varargin{i};
end
assignin('base','ClEaRGsJioU',var);
var = evalin('base','who(ClEaRGsJioU{:})');
clearvar = a(~ismember(a,var));
assignin('base','ClEaRGsJioU',clearvar);
evalin('base','clear(ClEaRGsJioU{:},''ClEaRGsJioU'')')
