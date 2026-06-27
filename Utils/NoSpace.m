function out = NoSpace(str)
% =======================================================================
% Removes spaces from a string
% =======================================================================
% out = NoSpace(str)
% -----------------------------------------------------------------------
% INPUT
%   - str: input string [char]
% -----------------------------------------------------------------------
% OUTPUT
%   - out: string with all space characters removed [char]
% -----------------------------------------------------------------------
% EXAMPLE
%   str = 'this is a string with spaces';
%   out = NoSpace(str);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. REMOVE SPACES
% -----------------------------------------------------------------------
% Logical indexing retains only non-space characters in their original order.
out = str(~isspace(str));
