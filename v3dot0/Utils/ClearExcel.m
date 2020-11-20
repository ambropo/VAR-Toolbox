function ClearExcel(filename,tabname)
% =======================================================================
% Clears content from a specified tab of an excel file
% =======================================================================
% INPUT
%   - filename: excel filename with extension
%   - tabname: tab name
% =======================================================================
% Ambrogio Cesa Bianchi, March 2016

Excel = actxserver('Excel.Application');
Workbook = Excel.Workbooks.Open([pwd '\' filename]);
Workbook.Worksheets.Item(tabname).Range('A:ZZ').ClearContents; 
Workbook.Save;
Excel.Workbook.Close;
invoke(Excel, 'Quit');
delete(Excel);