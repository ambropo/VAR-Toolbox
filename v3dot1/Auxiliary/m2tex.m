function out=m2tex(filein,fileout)
%mtex(m-file in,latex file out)
% Copyright 2006 Kevin Mader
%
%		Arguments::
% m-file is the m-file you wish to translate to latex
% latex file out if the name of the output file you would like to make
% if the second argument is omitted the program will create an output file
% with the same name as the input file but with extension .tex
%
% m2tex will operate in another mode where you give it out=m2tex('m
% stuff'); and it will convert the string containing lines in matlab to a
% string of tex commands for instant gratification
%
%		About::
% m2tex produces a latex file that can be included in a presentation or report
% using the \include{latex file out} function in latex.
% The program recognizes strings and major loop/if-else/switch functions
% The program will also properly indent your file in latex although tab support
% is not yet complete.
if nargin<2
    fileout=[filein(1:end-1) 'tex'];
end
fi=fopen(filein,'r');
if fi<0
    % the then its not a file so it must be a string
    stringMode=1;
    fi=filein;
    sDel=[0 find(fi==char(10)) length(fi)+1];
    sCount=1;
    out=[];
else
    stringMode=0;
    sCount=0;
    sDel=[];
    fo=fopen(fileout,'w');
end

iLevel=0;
while dataLeft(fi,stringMode,sCount<length(sDel))
    if stringMode
        cline=fi((sDel(sCount)+1):(sDel(sCount+1)-1));
        sCount=sCount+1;
    else
        cline=fgetl(fi);
    end
    
    outLine='\\hspace{1mm}'; % this does nothing but prevent errors from lines starting with \\[
    for r=1:iLevel
        outLine=[outLine '\\hspace{5mm} '];
    end
    brackOpen=0;
    isStr=0;
    d=find(cline==' ');
    if ~isempty(d)
        d=d-[1:length(d)];
        c=find(d==0);
        if ~isempty(c)
            cline=cline(c(end)+1:end);
        end

    end
    del=[0 find(cline==' ') length(cline)+1];
    for j=1:(length(del)-1)
        cword=cline((del(j)+1):(del(j+1)-1));
        if iscmd(cword) & (~isStr | ~brackOpen)
            outLine=[outLine '\\textcolor{matlabblue}{' cword '}'];
            if strcmp(cword,'end')
                iLevel=iLevel-1;
                outLine='\\hspace{1mm}';
                for r=1:iLevel
                    outLine=[outLine '\\hspace{5mm} '];
                end
                outLine=[outLine '\\textcolor{matlabblue}{' cword '}'];
            elseif strcmp(cword,'function')
                iLevel=0;
            elseif isfunnyindent(cword)
                iLevel=iLevel-1;
                outLine='\\hspace{1mm}';
                for r=1:iLevel
                    outLine=[outLine '\\hspace{5mm} '];
                end
                iLevel=iLevel+1;
                outLine=[outLine '\\textcolor{matlabblue}{' cword '}'];
            else
                iLevel=iLevel+1;
            end
        else
            for i=1:length(cword)
                postIt='';
                switch cword(i)
                    case '&'
                        outLine=[outLine '\\'];
                    case '{'
                        outLine=[outLine '\\'];
                    case '}'
                        outLine=[outLine '\\'];
                    case '_'
                        outLine=[outLine '\\'];
                    case '$'
                        outLine=[outLine '\\'];
                    case '^'
                        outLine=[outLine '\\texttt{\\'];
                        postIt='}';
                    case '%'
                        if brackOpen==0
                            outLine=[outLine '\\textcolor{matlabgreen}{\\%'];
                            brackOpen=1;
                        else
                            outLine=[outLine '}\\textcolor{matlabgreen}{\\%'];
                            brackOpen=1;
                        end
                    case ''''

                        if isStr==0
                            strTest=(brackOpen==0);
                            if strTest
                                if (i~=1)
                                    strTest=(cword(i-1)=='(') | (cword(i-1)=='=') | (cword(i-1)==',') | (cword(i-1)=='[') | (cword(i-1)=='{');
                                end
                            end

                            if strTest
                                outLine=[outLine '\\textcolor{matlabpurple}{'];
                                brackOpen=1;
                                isStr=1;
                            end
                        else
                            postIt='}';
                            brackOpen=0;
                            isStr=0;
                        end

                end
                switch cword(i)
                    case '>'
                        outLine=[outLine '$>$'];
                    case '<'
                        outLine=[outLine '$<$'];
                    case '\'
                        outLine=[outLine '$\\backslash$'];
                    otherwise
                        outLine=[outLine cword(i) postIt];
                end
            end
        end
        outLine=[outLine ' '];
    end
    if brackOpen
        outLine=[outLine '}'];
    end

    outLine=[outLine '\\\\ ' char(10)];
    if stringMode
        out=[out outLine];
    else
        fprintf(fo,outLine);
    end
end
if ~stringMode
fclose(fi);
fclose(fo);
end

function b=dataLeft(fi,stringMode,strDone)
if stringMode
    b=strDone;
else
    b=~feof(fi);
end

function b=isfunnyindent(word)
funnywords={'case','otherwise','elseif','else'};
b=0;
for k=1:length(funnywords)
    b=b | strcmp(word,funnywords{k});
end
function b=iscmd(word)
cmds={'for','end','while','if','function','else','elseif','switch','case','otherwise'};
b=0;
for k=1:length(cmds)
    b=b | strcmp(word,cmds{k});
end