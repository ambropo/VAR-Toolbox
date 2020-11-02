function barHandle = BARX(g,varargin)
% BARX create a stacked bar graph with negative data values on the negative
% quadrant

if nargin > 1,
    ss_ = varargin{1};
else
    ss_ = 0;
end;

barHandle(1,:)=bar((g+ss_).*(g>0),'stacked'); hold on;
barHandle(2,:)=bar((g+ss_).*(g<0),'stacked');
