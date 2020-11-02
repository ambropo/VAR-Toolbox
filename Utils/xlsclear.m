function xlsclear(filename,sheet)
% =======================================================================
% Clears the content of a spreadsheet
% =======================================================================
% xlsclear(filename,sheet)
% -----------------------------------------------------------------------
% INPUT
%   - filename: name of the excel file, eg File.xlsx (char)
%   - sheet: name of the worksheet to clear (char)
% -----------------------------------------------------------------------
% OUTPUT
%   - out: [r*c x 1] matrix
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

% Name of the excel file
filename = [pwd '\' filename];

% Retrieve sheet names 
[~, sheetNames] = xlsfinfo(filename);

% Open Excel as a COM Automation server
Excel = actxserver('Excel.Application');

% Open Excel workbook
Workbook = Excel.Workbooks.Open(filename);

% Clear the content of the sheets
for ii=1:length(sheet)
    index = strcmp(sheet(ii),sheetNames);
    cellfun(@(x) Excel.ActiveWorkBook.Sheets.Item(x).Cells.Clear, sheetNames(index));
end

% Save/close/quit/delete
Workbook.Save;
Excel.Workbook.Close;
invoke(Excel, 'Quit');
delete(Excel)
