function H = hatchfill2(A,varargin)
% HATCHFILL2 Hatching and speckling of patch objects
%   HATCHFILL2(A) fills the patch(es) with handle(s) A. A can be a vector
%   of handles or a single handle. If A is a vector, then all objects of A
%   should be part of the same group for predictable results. The hatch
%   consists of black lines angled at 45 degrees spaced 5 pixels apart,
%   with no color filling between the lines.
%
%   A can be handles of patch or hggroup containing patch objects for
%   Pre-R2014b release. For HG2 releases, 'bar' and 'contour' objects are
%   also supported.
%
%   Hatching line object is actively formatted. If A, axes, or figure size
%   is modified, the hatching line object will be updated accordingly to
%   maintain the specified style.
%
%   HATCHFILL2(A,STYL) applies STYL pattern with default paramters. STYL
%   options are:
%      'single'     single lines (the default)
%      'cross'      double-crossed hatch
%      'speckle'    speckling inside the patch boundary
%      'outspeckle' speckling outside the boundary
%      'fill'       no hatching
%
%   HATCHFILL2(A,STYL,Option1Name,Option1Value,...) to customize the
%   hatching pattern
%
%       Name       Description
%      --------------------------------------------------------------------
%      HatchStyle       Hatching pattern (same effect as STYL argument)
%      HatchAngle       Angle of hatch lines in degrees (45)
%      HatchSpacing     Spacing of hatch lines (5)
%      HatchOffset      Offset hatch lines in pixels (0)
%      HatchColor       Color of the hatch lines, 'auto' sets it to the
%                       EdgeColor of A
%      HatchLineStyle   Hatch line style
%      HatchLineWidth   Hatch line width
%      SpeckleWidth         Width of speckling region in pixels (7)
%      SpeckleDensity       Density of speckle points (1)
%      SpeckleMarkerStyle   Speckle marker style
%      SpeckleFillColor     Speckle fill color
%      HatchVisible     [{'auto'}|'on'|'off'] sets visibility of the hatch
%                       lines. If 'auto', Visibile option is synced to
%                       underlying patch object
%      ContourStyle     [{'nonconvex'}|'convex'] sets how hatching is drawn
%                       for an underlying contour object. If the contour is
%                       known to be convex, using 'convex' style yields in
%                       a smaller set of line objects and faster response
%                       when figure is resized. Incorrect rendering results
%                       if 'convex' option is used for non-convex contour.
%                       This option does not affect pre-R2015a releases.
%
%   In addition, name/value pairs of any properties of A can be specified
%
%   H = HATCHFILL2(...) returns handles to the line objects comprising the
%   hatch/speckle.
%
%   Examples:
%       Gray region with hatching:
%       hh = hatchfill2(a,'cross','HatchAngle',45,'HatchSpacing',5,'FaceColor',[0.5 0.5 0.5]);
%
%       Speckled region:
%       hatchfill2(a,'speckle','HatchAngle',7,'HatchSpacing',1);

% Copyright 2015-2016 Takeshi Ikuma
% History:
% rev. 6 : (07-17-2016)
%   * Fixed contours object hatching behavior, introduced in rev.5
%   * Added ContourStyle option to enable fast drawing if contour is convex
% rev. 5 : (05-12-2016)
%   * Fixed Contour with NaN data point disappearnace issue
%   * Improved contours object support
% rev. 4 : (11-18-2015)
%   * Worked around the issue with HG2 contours with Fill='off'.
%   * Removed nagging warning "UseHG2 will be removed..." in R2015b
% rev. 3 : (10-29-2015)
%   * Added support for HG2 AREA
%   * Fixed for HatchColor 'auto' error when HG2 EdgeColor is 'flat'
%   * Fixed listener creation error
% rev. 2 : (10-24-2015)
%   * Added New option: HatchVisible, SpeckleDensity, SpeckleWidth
%     (SpeckleDensity and SpeckleWidtha are separated from HatchSpacing and
%     HatchAngle, respectively)
% rev. 1 : (10-20-2015)
%   * Fixed HG2 contour data extraction bug (was using wrong hidden data)
%   * Fixed HG2 contour color extraction bug
%   * A few cosmetic changes here and there
% rev. - : (10-19-2015) original release
%   * This work is based on Neil Tandon's hatchfill submission 
%     (http://www.mathworks.com/matlabcentral/fileexchange/30733)
%     and borrowed code therein from R. Pawlowicz, K. Pankratov, and
%     Iram Weinstein.

narginchk(1,inf);
[A,opts,props] = parse_input(A,varargin);

if verLessThan('matlab','8.4')
   H = zeros(size(A));
else
   H = repmat(matlab.graphics.GraphicsPlaceholder,size(A));
end

drawnow % make sure the base objects are already drawn

for n = 1:numel(A)
   H(n) = newhatch(A(n),opts,props);
   
   % if legend of A(n) is shown, add hatching to it as well
%       leg = handle(legend(ancestor(A,'axes')));
%       hsrc = [leg.EntryContainer.Children.Object];
%       hlc = leg.EntryContainer.Children(find(hsrc==A(n),1));
%       if ~isempty(hlc)
%          hlc = hlc.Children(1); % LegendIcon object
%          get(hlc.Children(1))
%       end
end

if nargout==0
   clear H
end

end

function H = newhatch(A,opts,props)

% 0. retrieve pixel-data conversion parameters
% 1. retrieve face & vertex matrices from A
% 2. convert vertex matrix from data to pixels units
% 3. get xdata & ydata of hatching lines for each face
% 4. concatenate lines sandwitching nan's in between
% 5. convert xdata & ydata back to data units
% 6. plot the hatching line

% Modify the base object property if given
if ~isempty(props)
   pvalold = sethgprops(A,props);
end

try
   % save the current patch object data
   hgdatachanged(A);
   
   % 0-5: form hatch line data
   [X,Y,proplist] = getlinedata(A,opts);
   
   % 6. plot the hatching line
   [color,cprop] = gethgcolor(A);
   if ~strcmp(opts.HatchColor,'auto')
      color = opts.HatchColor;
   end
   vislisena = strcmp(opts.HatchVisible,'auto');
   if vislisena
      vis = A.Visible;
   else
      vis = opts.HatchVisible;
   end
   commonprops = {'Color',color,'Parent',A.Parent,'DisplayName',A.DisplayName,'Visible',vis};
   if isempty(regexp(opts.HatchStyle,'speckle$','once'))
      H = line(X,Y,commonprops{:},'LineStyle',opts.HatchLineStyle','LineWidth',opts.HatchLineWidth);
   else
      H = line(X,Y,commonprops{:},'LineStyle','none','Marker',opts.SpeckleMarkerStyle,...
         'MarkerSize',opts.SpeckleSize,'MarkerFaceColor',opts.HatchColor,'Parent',A.Parent,'DisplayName',A.DisplayName);
   end
   
   if isempty(H)
      error('Unable to obtain hatching data from the specified object A.');
   end
   
   % 7. Move H so that it is place right above A in parent's uistack
   p = handle(A.Parent);
   Hcs = handle(p.Children);
   [~,idx] = ismember(A,Hcs); % always idx(1)>idx(2) as H was just created
   p.Children = p.Children([2:idx-1 1 idx:end]);
   
   % save the config data & set up the object listeners
   setappdata(A,'HatchFill2Opts',opts);
   setappdata(A,'HatchFill2Obj',handle(H));
   setappdata(H,'HatchFill2Patch',A);
   
   % create a function to be called when a legend is inserted 
   % (for flexlegend?)
   
   setappdata(A,'LegendEntryFormatFcn',@(h)hatchfill2(h,opts));
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Create listeners for active formatting
   
   addlistener(H,'ObjectBeingDestroyed',@hatchcleanup);

   if verLessThan('matlab','8.4')
      lis = addlistener(A,'ObjectParentChanged',@reparent);
   else
      lis = addlistener(A,'Reparent',@reparent);
   end
   lis(2) = addlistener(A,'ObjectBeingDestroyed',@cleanup);
   lis(3) = addlistener(A,'Clipping','PostSet',@syncProperty);
   lis(4) = addlistener(A,'HitTest','PostSet',@syncProperty);
   lis(5) = addlistener(A,'Interruptible','PostSet',@syncProperty);
   lis(6) = addlistener(A,'BusyAction','PostSet',@syncProperty);
   lis(7) = addlistener(A,'UIContextMenu','PostSet',@syncProperty);
   
   % properties requiring rehatching the patch
   for n = 1:size(proplist,1)
      for m = 1:size(proplist{n,2},1)
         lis(end+1) = addlistener(proplist{n,1},proplist{n,2}{m,:},@rehatch); %#ok
      end
   end
   setappdata(A,'HatchFill2Listeners',lis);

   % properties to be synced
   lis = addlistener(A,'Visible','PostSet',@syncProperty);
   setappdata(A,'HatchFill2PostSetVisible',lis);
   if ~vislisena
      try
         lis.Enabled = false;
      catch
         set(lis,'Enabled','off');
      end
   end
   
   lis = addlistener(cprop{1},cprop{2},'PostSet',@recolor);
   setappdata(A,'HatchFill2PostSetColor',lis);
   if ~strcmp(opts.HatchColor,'auto')
      try
         lis(end).Enabled = false;
      catch
         set(lis(end),'Enabled','off');
      end
   end
   
   % set up the axes listeners
   axessetup(A);
   
catch ME
   % something went wrong, restore the base object properties
   if ~isempty(props)
      for pname = fieldnames(pvalold)'
         name = pname{1};
         val = pvalold.(name);
         if iscell(val)
            pvalold.(name){1}.(name) = pvalold.(name){2};
         else
            A.(name) = pvalold.(name);
         end
      end
   end
   ME.rethrow();
end

end

%%%%%%%%%% EVENT CALLBACK FUNCTIONS %%%%%%%%%%%%

function recolor(hp,evt)

try % for HG1 callback
   hp = evt.AffectedObject;
catch
end

% get the main patch object (loops if hggroup or HG2 objects)
while ~isappdata(hp,'HatchFill2Obj')
   hp = handle(hp.Parent);
end
H = getappdata(hp,'HatchFill2Obj');

% sync the color
H.Color = gethgcolor(hp);

end

function rehatch(hp,evt)

if ~ishghandle(hp) % for HG1 callback
   hp = evt.AffectedObject;
end

try
   axchanged = ishghandle(evt.Source,'axes');
catch
   axchanged = ishghandle(evt.Source,'axes');
end

% get the main patch object (loops if hggroup or HG2 objects)
while ~isappdata(hp,'HatchFill2Obj')
   hp = handle(hp.Parent);
end
% if no change since last time, don't do anything
if axchanged || hgdatachanged(hp)
   % get the hatch line object handle & hatching options
   H = getappdata(hp,'HatchFill2Obj');
   opts = getappdata(hp,'HatchFill2Opts');
   
   % recompute hatch line data
   [X,Y] = getlinedata(hp,opts);
   
   % update the hatching line data 
   if ~isempty(X) || hgdatachanged(hp) % undesirable workaround
      set(H,'XData',X,'YData',Y);
   end
end

end

function syncProperty(~,evt)
   % sync Visible property to the patch object
   hp = handle(evt.AffectedObject); % patch object
   hh = getappdata(hp,'HatchFill2Obj');
   hh.(evt.Source.Name) = hp.(evt.Source.Name);
end

function reparent(hp,evt)
%reparent event listener callback

try % HG2
   pnew = evt.NewValue;
   pold = evt.OldValue;
catch % HG1
   pnew = handle(evt.NewParent);
   pold = handle(evt.OldParent);
end
axnew = handle(ancestor(pnew,'axes'));
axold = handle(ancestor(pold,'axes'));

% if truely moved, move the hatch line object over as well
if ~(isempty(pnew) || isempty(pold) || pnew==pold)
   H = getappdata(hp,'HatchFill2Obj');
   H.Parent = pnew;

   % make sure to move the hatch line object right above the patch object
   Hcs = handle(pnew.Children);
   [~,idx] = ismember(hp,Hcs); % always idx(1)>idx(2) as H was just moved
   pnew.Children = pnew.Children([2:idx-1 1 idx:end]);
end
 
% if still on the same axes, nothing to do
if ~(isempty(axnew) || isempty(axold) || axnew==axold)
   
   % remove the association to the old axes
   axescleanup(axold,hp);
   % associate with the new axes
   axessetup(axnew,hp);
end

end
function cleanup(hp,~)
%when patch object (hp) is deleted

hatchcleanup(getappdata(hp,'HatchFill2Obj'))

if isappdata(hp,'HatchFill2Obj')
   delete(getappdata(hp,'HatchFill2Obj'));
   rmappdata(hp,'HatchFill2Obj');
end

end

function hatchcleanup(hh,~)
%when hatch line object (hh) is deleted

if isappdata(hh,'HatchFill2Patch')
   
   %   remove listeners listening to the patch object
   hp = getappdata(hh,'HatchFill2Patch');
   
   if isappdata(hp,'HatchFill2Listeners')
      delete(getappdata(hp,'HatchFill2Listeners'));
      rmappdata(hp,'HatchFill2Listeners');
   end
   if isappdata(hp,'HatchFill2PostSetVisible')
      delete(getappdata(hp,'HatchFill2PostSetVisible'));
      rmappdata(hp,'HatchFill2PostSetVisible');
   end
   if isappdata(hp,'HatchFill2PostSetColor')
      delete(getappdata(hp,'HatchFill2PostSetColor'));
      rmappdata(hp,'HatchFill2PostSetColor');
   end
   
   % remove the patch object from axes lookout
   axescleanup(handle(ancestor(hp,'axes')),hp);
end

end

function axesresize(ax,evt)
% listener callback for the axes containing lateximage objects

try % for HG1 callback
   ax = evt.AffectedObject;
   if ~axesresized(ax)
      return;
   end
catch
end

hs = getappdata(ax,'HatchFill2Handles');
for h = hs % for each latex image object, rescale
   rehatch(h,evt);
end

end

function axesredraw(ax,evt)
% listener callback for the axes containing lateximage objects

try % for HG1 callback
   ax = evt.AffectedObject;
catch
end

if axeschanged(ax)
   hs = getappdata(ax,'HatchFill2Handles');
   for h = hs % for each latex image object, rescale
      rehatch(h,evt);
   end
end

end

function axescleanup(ax,h)
% called when h is deleted or moved to another parent

% update its lateximage handles
hs = setdiff(getappdata(ax,'HatchFill2Handles'),h);
setappdata(ax,'HatchFill2Handles',hs);

if isempty(hs) % delete all listeners
   % remove from figure's axes list
   framecleanup(handle(ax.Parent),ax);
   
   % delete all axes listeners
   lis = getappdata(ax,'HatchFill2OnSizeChanged');
   if ~isempty(lis)
      delete(lis);
      rmappdata(ax,'HatchFill2OnSizeChanged');
   end
   lis = getappdata(ax,'HatchFill2OnMarkedClean');
   if ~isempty(lis)
      delete(lis);
      rmappdata(ax,'HatchFill2OnMarkedClean');
   end
   
   if isappdata(ax,'HatchFill2AxesPosition')
      rmappdata(ax,'HatchFill2AxesPosition');
   end
   if isappdata(ax,'HatchFill2AxesStates')
      rmappdata(ax,'HatchFill2AxesStates');
   end
   
   % delete misc appdata
   if isappdata(ax,'TIPrintMode')
      rmappdata(ax,'TIPrintMode');
   end
   
end
end

function frameredraw(fig,evt)
% in HG1, if figure/frame has been resized, pass the command down

try
   fig = evt.AffectedObject;
catch
end

hs = getappdata(fig,'HatchFill2Axes');
for n = 1:numel(hs)
   if ishghandle(hs(n),'axes')
      axesresize(hs(n),evt)
   else
      frameredraw(hs(n));
   end
end
end

function framecleanup(fig,ax)
% called when h is deleted or moved to another parent

% update its lateximage handles
hs = setdiff(getappdata(fig,'HatchFill2Axes'),ax);
setappdata(fig,'HatchFill2Axes',hs);

if isempty(hs) % delete all listeners

   % delete the Position listeners
   lis = getappdata(fig,'HatchFill2FigureSize');
   if ~isempty(lis)
      delete(lis);
      rmappdata(fig,'HatchFill2FigureSize');
   end
   
   % remove from figure's axes list
   p = fig.Parent;
   if p>0
      framecleanup(handle(p),fig);
   end
end
end

%%%%%%%%%% SUBFUNCTIONS %%%%%%%%%%%%

function axessetup(h)

ax = handle(ancestor(h,'axes'));

hs = getappdata(ax,'HatchFill2Handles');
if isempty(hs) % first time
   % create appdata
   setappdata(ax,'HatchFill2Handles',h);
   
   % store current position in pixels
   u = ax.Units;
   ax.Units = 'pixels';
   pos = ax.Position;
   ax.Units = u;
   setappdata(ax,'HatchFill2AxesPosition',pos);

   % store current state
   pnames = {...
      'XLim','XDir','XScale',...
      'YLim','YDir','YScale',...
      'ZLim','ZDir','ZScale',...
      'DataAspectRatio','PlotBoxAspectRatio'};
   states = [pnames;get(ax,pnames)];
   setappdata(ax,'HatchFill2AxesStates',states);
   
   % set up new listeners
   if verLessThan('matlab','8.4')
      setappdata(ax,'HatchFill2OnSizeChanged',[...
         addlistener(ax,'Position','PostSet',@axesredraw)...
         addlistener(ax,'Parent','PostSet',@axesredraw)]);
      
      for n = 1:numel(pnames)
         lis(n) = addlistener(ax,pnames{n},'PostSet',@axesredraw); %#ok
      end
      setappdata(ax,'HatchFill2OnMarkedClean',lis);
      
      % also need to monitor figure's Position
      framesetup(handle(ax.Parent),ax);
   else
      setappdata(ax,'HatchFill2OnSizeChanged',addlistener(ax,'SizeChanged',@axesresize));
      setappdata(ax,'HatchFill2OnMarkedClean',addlistener(ax,'MarkedClean',@axesresize));
   end
else % already exists
   % add the new object to the appdata
   setappdata(ax,'HatchFill2Handles',[hs h]);
end
end

function framesetup(fig,ax)
% only for HG1

hs = getappdata(fig,'HatchFill2Axes');
if isempty(hs)
   % create appdata
   setappdata(fig,'HatchFill2Axes',ax);
   
   % set up new listeners
   setappdata(fig,'HatchFill2FigureSize',...
      addlistener(fig,'Position','PostSet',@frameredraw));
   
   % recurse until it is figure
   p = fig.Parent;
   if p~=0 % not root
      framesetup(handle(p),fig);
   end
else % already exists
   % add the new object to the appdata
   setappdata(fig,'HatchFill2Axes',[hs ax]);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getlinedata(A,opts)

ax = handle(ancestor(A,'axes'));

varargout = cell(1,nargout);

% 0. retrieve pixel-data conversion parameters
[x2px,y2px,islog,xlim,ylim] = data2pxratio(ax);

% 1. retrieve face & vertex matrices from A
[V,F,varargout{3:end}] = gethgdata(A,opts.ContourStyle);

if ~isempty(V) % if patch shown
   % 2. convert vertex matrix from data to pixels units
   [V(:,1),V(:,2)] = data2px(ax,V(:,1),V(:,2),x2px,y2px,islog,xlim,ylim);
   
   % 3. get xdata & ydata of hatching lines for each face
   N = size(F,1);
   XYc = cell(2,N);
   for n = 1:N
      f = F(n,:);
      %%% just-in-case %%%
      f(isnan(f)) = [];
      v = V(f,1:2)';
      v(:,any(isnan(v)|isinf(v))) = []; % remove nan or inf samples
      %%% /just-in-case %%%
      if any(strcmp(opts.HatchStyle,{'speckle','outsidespeckle'}))
         XYc{1,n} = hatch_xy(v,opts.HatchStyle,opts.SpeckleWidth,opts.SpeckleDensity,opts.HatchOffset);
      else
         XYc{1,n} = hatch_xy(v,opts.HatchStyle,opts.HatchAngle,opts.HatchSpacing,opts.HatchOffset);
      end
   end
   
   % 4. concatenate hatch lines across faces sandwitching nan's in between
   [XYc{2,:}] = deal(nan(2,1));
   XY = cat(2,XYc{:});
   
   % 5. convert xdata & ydata back to data units
   [varargout{1:2}] = px2data(ax,XY(1,:),XY(2,:),x2px,y2px,islog,xlim,ylim);
end

end

function tf = axesresized(ax)
% returns true if any of the axes' Position property (in pixels) is changed
% only called by HG1 listeners

lis = getappdata(ax,'HatchFill2OnSizeChanged');
set(lis,'Enabled','off');
u = ax.Units;
ax.Units = 'pixels';
newpos = ax.Position;
ax.Units = u;
set(lis,'Enabled','on');

oldpos = getappdata(ax,'HatchFill2AxesPosition');
tf = newpos(3)~=oldpos(3) || newpos(4)~=oldpos(4);
if tf
   getappdata(ax,'HatchFill2AxesPosition',newpos);
end

end

function tf = axeschanged(ax)
% returns true if any of the following axes' property has changed: XYZLim,
% XYZScale, XYZLim, DataAspectRatio, PlotBoxAspectRatio, Position (in
% pixels)

oldstates = getappdata(ax,'HatchFill2AxesStates');
newstates = get(ax,oldstates(1,:));

tf = ~isequal(oldstates(2,:),newstates);
if tf
   oldstates(2,:) = newstates;
   setappdata(ax,'HatchFill2AxesStates',oldstates);
end

end

function tf = issupported(hbase)
% check if all of the given base objects are supported

supported_objtypes = {'patch','hggroup','bar','contour','area'};

if isempty(hbase)
   tf = false;
else
   tf = ishghandle(hbase,supported_objtypes{1});
   for n = 2:numel(supported_objtypes)
      tf(:) = tf | ishghandle(hbase,supported_objtypes{n});
   end
   tf = all(tf);
end

end

function varargout = gethgcolor(A)

varargout = cell(1,nargout);

if ishghandle(A,'hggroup')
   % get all supported child objects
   hs = handle(A.Children);
   hs(~issupported(hs)) = [];
   
   % grab the color of the first object
   for n = 1:numel(hs)
      [varargout{:}] = gethgcolor(hs(n));
      if ~isempty(varargout{1})
         break;
      end
   end
else
   if ishghandle(A,'patch') || ishghandle(A,'Bar') || ishghandle(A,'area') %HG2
      pname = 'EdgeColor';
   elseif ishghandle(A,'contour') % HG2
      pname = 'LineColor';
   end
   varargout{1} = A.(pname);
   if strcmp(varargout{1},'flat')
      try
         varargout{1} = double(A.Edge.ColorData(1:3)')/255;
      catch
         warning('Unknown patch edge color found');
         varargout{1} = 'k';
      end
   end
   if nargout>1
      varargout{2} = {A pname};
   end
end
end

function tf = hgdatachanged(A)

data = getappdata(A,'HatchFill2Data');
tf = isempty(data);

if ishghandle(A,'hggroup')
   % get all supported child objects
   hs = handle(A.Children);
   hs(~issupported(hs)) = [];
   
   % grab the color of the first object
   for n = 1:numel(hs)
      tf = tf || hgdatachanged(hs(n));
   end
else
   if ishghandle(A,'patch')
      pnames = {'Vertices','Faces'};
   elseif ishghandle(A,'bar') % HG2
      pnames = {'BarWidth','BaseValue','Horizontal','XData','YData'};
   elseif ishghandle(A,'contour') % HG2
      pnames = {'XData','YData','ZData','LevelList','LevelStep'};
   elseif ishghandle(A,'area') % HG2
      pnames = {'XData','YData','BaseValue'};
   elseif ishghandle(A,'histogram') %HG2
   end

   % if running for the first time, initialize the appdata
   if tf
      data = cell(1,numel(pnames));
   end
   
   % check for any change
   for n = 1:numel(pnames)
      if ~isequal(A.(pnames{n}),data{n});
         tf = true;
         data{n} = A.(pnames{n});
      end
   end
   
   % if something changed, updated the appdata
   if tf
      setappdata(A,'HatchFill2Data',data);
   end
end

end

function [V,F,listner_cfg] = gethgdata(A,cstyle)

if ishghandle(A,'patch')
   V = A.Vertices;
   F = A.Faces;
   
   % return addlister input arguments (minus the callback)
   if nargout>2
      listner_cfg = {A {'Vertices' 'PostSet';'Faces' 'PostSet'}};
   end
elseif ishghandle(A,'bar') || ishghandle(A,'area') % HG2
   if isempty(A.Face)
      F = [];
      V = [];
   else
      % A.Face is a hidden property holding underlying Quadrilateral object
      V = A.Face.VertexData';
      I = double(A.Face.StripData);
      N = numel(I)-1; % # of faces
      m = diff(I);
      M = max(m);
      F = nan(N,M);
      for n = 1:N
         idx = I(n):(I(n+1)-1);
         if mod(numel(idx),2) % odd
            error('Unaccounted Quadrilateral face: odd number of vertices');
            %idx(:) = idx([1:2:end end-1:-2:2]);
         else % even
            idx(:) = idx([1:2:end-1 end:-2:2]);
         end
         F(n,1:numel(idx)) = idx;
      end
   end
   % return addlister input arguments (minus the callback)
   if nargout>2
      listner_cfg = {A {'MarkedClean'}};
   end
elseif ishghandle(A,'contour') % HG2
   % return addlister input arguments (minus the callback)
   if nargout>2
      listner_cfg = {A {'MarkedClean'}};
   end

   if strcmp(A.Fill,'off')
      A.Fill = 'on';
%       drawnow;
      refreshdata(A)
      C = onCleanup(@()set(A,'Fill','off'));
   end
   
   % Retrieve data from hidden FacePrims property (a TriangleStrip object)
   if ~isempty(A.ContourMatrix) && (strcmp(cstyle,'convex') || isempty(A.FacePrims))
      % CODE FOR THIS SECTION IS BORROWED FROM CONTOURCS (#28447)
      
      data = A.ContourMatrix;
      
      % Count number of contour segments found (K)
      K = 0;
      n0 = 1;
      maxV = 0;
      while n0<=size(data,2)
         K = K + 1;
         Nv = data(2,n0);
         maxV = max(maxV,Nv);
         n0 = n0 + Nv + 1;
      end
      
      % create F & V output matrices
      V = zeros(K*maxV,2);
      F = nan(K,maxV);
      % fill the output struct
      n0 = 1;
      for k = 1:K
         idx = (n0+1):(n0+data(2,n0));
         V(idx,:) = data(:,idx)';
         F(k,1:data(2,n0)) = idx;
         n0 = idx(end) + 1; % next starting index
      end
   elseif ~isempty(A.FacePrims)
      V = A.FacePrims.VertexData';
      I = double(A.FacePrims.StripData);
      
      % hack job here: in log scale, V is normalized to the axes
      % no idea how to pick this up from A itself...
      ax = ancestor(A,'axes');
      inlog = strcmp({ax.XScale ax.YScale},'log');
      if any(inlog)
         xlim = ax.XLim; ylim = ax.YLim;
         if inlog(1)
            xlim(:) = log10(xlim);
         end
         V(:,1) = V(:,1)*diff(xlim);
         if strcmp(ax.XDir,'normal')
            V(:,1) = V(:,1) + xlim(1);
         else
            V(:,1) = xlim(2) - V(:,1);
         end
         if inlog(1)
            V(:,1) = 10.^V(:,1);
         end
         
         if inlog(2)
            ylim(:) = log10(ylim);
         end
         V(:,2) = V(:,2)*diff(ylim);
         if strcmp(ax.YDir,'normal')
            V(:,2) = V(:,2) + ylim(1);
         else
            V(:,2) = ylim(2) - V(:,2);
         end
         if inlog(2)
            V(:,2) = 10.^V(:,2);
         end
      end
      
      N = numel(I)-1; % # of faces
      m = diff(I);
      M = max(m);
      F = nan(N,M);
      for n = 1:N
         idx = I(n):(I(n+1)-1);
         if mod(numel(idx),2) % odd
            idx(:) = idx([1:2:end end-1:-2:2]);
         else % even
            idx(:) = idx([1:2:end-1 end:-2:2]);
         end
         F(n,1:numel(idx)) = idx;
      end
   else
      F = [];
      V = [];
      warning('Failed to find the data of the Contour object A.');
   end
elseif ishghandle(A,'histogram') %HG2
else%if ishghandle(A,'hggroup')
   % get all supported child objects
   hs = handle(A.Children);
   hs(~issupported(hs)) = [];

   % return addlister input arguments (minus the callback)
   if nargout>2
      listner_cfg = cell(0,2);
   end
   
   if isempty(hs)
      V = [];
      F = [];
   else
      N = numel(hs);
      Vc = cell(1,N);
      Fc = cell(1,N);
      Ktotal = 0; % total number of vertices
      for n = 1:N
         [Vc{n},Fc{n},lcfg] = gethgdata(hs(n),cstyle);
         % V: kx3, k vertices, each row:[x y z]
         % F: mxn, m faces, up to n vertices each
         % lcfg: ix2 cell specifying which object properties to listen to
         
         Fc{n} = Fc{n} + Ktotal;
         Ktotal = Ktotal + size(Vc{n},1);
         
         if nargout>2
            listner_cfg((end+1):(end+size(lcfg,1)),:) = lcfg;
         end
         
      end
      
      % vertex matrix has all the same number of columns
      V = cat(1,Vc{:});
      
      % face matrix has variable number of columns
      Ncols = cellfun(@(F)size(F,2),Fc);
      if ~isscalar(unique(Ncols)) % expand in columns of each first if needed
         Nmax = max(Ncols);
         for n = 1:N
            Fc{n}(:,end+1:Nmax) = nan; % pad with NaNs
         end
      end
      F = cat(1,Fc{:}); % then concatenate
   end
end
end

function pvalold = sethgprops(A,props)
% grab the common property names of the base objects

pnames = fieldnames(props);
if ishghandle(A,'hggroup')
   gpnames = fieldnames(set(A));
   [tf,idx] = ismember(gpnames,pnames);
   idx(~tf) = [];
   for i = idx'
      pvalold.(pnames{i}) = A.(pnames{i});
      A.(pnames{i}) = props.(pnames{i});
   end
   props = rmfield(props,pnames(idx));

   h = handle(A.Children);
   for n = 1:numel(h)
      pvalold1 = sethgprops(h(n),props);
      ponames = fieldnames(pvalold1);
      for k = 1:numel(ponames)
         pvalold.(ponames{k}) = {h(n) pvalold1.(ponames{k})};
      end
   end
else
   for n = 1:numel(pnames)
      pvalold.(pnames{n}) = A.(pnames{n});
      A.(pnames{n}) = props.(pnames{n});
   end
end

end

function xydatai = hatch_xy(xydata,styl,angle,step,offset)
%
% M_HATCH Draws hatched or speckled interiors to a patch
%
%    M_HATCH(LON,LAT,STYL,ANGLE,STEP,...line parameters);
%
% INPUTS:
%     X,Y - vectors of points.
%     STYL - style of fill
%     ANGLE,STEP - parameters for style
%
%     E.g.
%
%      'single',45,5  - single cross-hatch, 45 degrees,  5 points apart
%      'cross',40,6   - double cross-hatch at 40 and 90+40, 6 points apart
%      'speckle',7,1  - speckled (inside) boundary of width 7 points, density 1
%                               (density >0, .1 dense 1 OK, 5 sparse)
%      'outspeckle',7,1 - speckled (outside) boundary of width 7 points, density 1
%                               (density >0, .1 dense 1 OK, 5 sparse)
%
%
%      H=M_HATCH(...) returns handles to hatches/speckles.
%
%      [XI,YI,X,Y]=MHATCH(...) does not draw lines - instead it returns
%      vectors XI,YI of the hatch/speckle info, and X,Y of the original
%      outline modified so the first point==last point (if necessary).
%
%     Note that inside and outside speckling are done quite differently
%     and 'outside' speckling on large coastlines can be very slow.

%
% Hatch Algorithm originally by K. Pankratov, with a bit stolen from
% Iram Weinsteins 'fancification'. Speckle modifications by R. Pawlowicz.
%
% R Pawlowicz 15/Dec/2005

I = zeros(1,size(xydata,2));

% face vertices are not always closed
if any(xydata(:,1)~=xydata(:,end))
   xydata(:,end+1) = xydata(:,1);
   I(end+1) = I(1);
end

if any(strcmp(styl,{'speckle','outspeckle'}))
   angle = angle*(1-I);
end;

switch styl
   case 'single',
      xydatai = drawhatch(xydata,angle,step,0,offset);
   case 'cross',
      xydatai = [...
         drawhatch(xydata,angle,step,0,offset) ...
         drawhatch(xydata,angle+90,step,0,offset)];
   case 'speckle',
      xydatai = [...
         drawhatch(xydata,45,   step,angle,offset) ...
         drawhatch(xydata,45+90,step,angle,offset)];
   case 'outspeckle',
      xydatai = [...
         drawhatch(xydata,45,   step,-angle,offset) ...
         drawhatch(xydata,45+90,step,-angle,offset)];
      inside = logical(inpolygon(xydatai(1,:),xydatai(2,:),x,y)); % logical needed for v6!
      xydatai(:,inside) = [];
   otherwise
      xydatai = zeros(2,0);
end

end

%%%

function xydatai = drawhatch(xydata,angle,step,speckle,offset)
% xydata is given as 2xN matrix, x on the first row, y on the second

% Idea here appears to be to rotate everthing so lines will be
% horizontal, and scaled so we go in integer steps in 'y' with
% 'points' being the units in x.
% Center it for "good behavior".

% rotate first about (0,0)
ca = cosd(angle); sa = sind(angle);
u = [ca sa]*xydata;              % Rotation
v = [-sa ca]*xydata;

% translate to the grid point nearest to the centroid
u0 = round(mean(u)/step)*step; v0 = round(mean(v)/step)*step;
x = (u-u0); y = (v-v0)/step+offset;    % plus scaling and offsetting

% Compute the coordinates of the hatch line ...............
yi = ceil(y);
yd = [diff(yi) 0]; % when diff~=0 we are crossing an integer
fnd = find(yd);    % indices of crossings
dm = max(abs(yd)); % max possible #of integers between points

% This is going to be pretty space-inefficient if the line segments
% going in have very different lengths. We have one column per line
% interval and one row per hatch line within that interval.
%
A = cumsum( repmat(sign(yd(fnd)),dm,1), 1);

% Here we interpolate points along all the line segments at the
% correct intervals.
fnd1 = find(abs(A)<=abs( repmat(yd(fnd),dm,1) ));
A  = A+repmat(yi(fnd),dm,1)-(A>0);
xy = (x(fnd+1)-x(fnd))./(y(fnd+1)-y(fnd));
xi = repmat(x(fnd),dm,1)+(A-repmat(y(fnd),dm,1) ).*repmat(xy,dm,1);
yi = A(fnd1);
xi = xi(fnd1);

% Sorting points of the hatch line ........................
%%yi0 = min(yi); yi1 = max(yi);
% Sort them in raster order (i.e. by x, then by y)
% Add '2' to make sure we don't have problems going from a max(xi)
% to a min(xi) on the next line (yi incremented by one)
xi0 = min(xi); xi1 = max(xi);
ci = 2*yi*(xi1-xi0)+xi;
[~,num] = sort(ci);
xi = xi(num); yi = yi(num);

% if this happens an error has occurred somewhere (we have an odd
% # of points), and the "fix" is not correct, but for speckling anyway
% it really doesn't make a difference.
if rem(length(xi),2)==1,
   disp('mhatch warning');
   xi = [xi; xi(end)];
   yi = [yi; yi(end)];
end

% Organize to pairs and separate by  NaN's ................
li = length(xi);
xi = reshape(xi,2,li/2);
yi = reshape(yi,2,li/2);

% The speckly part - instead of taking the line we make a point some
% random distance in.
if length(speckle)>1 || speckle(1)~=0,
   
   if length(speckle)>1,
      % Now we get the speckle parameter for each line.
      
      % First, carry over the speckle parameter for the segment
      %   yd=[0 speckle(1:end-1)];
      yd = speckle(1:end);
      A=repmat(yd(fnd),dm,1);
      speckle=A(fnd1);
      
      % Now give it the same preconditioning as for xi/yi
      speckle=speckle(num);
      if rem(length(speckle),2)==1,
         speckle = [speckle; speckle(end)];
      end
      speckle=reshape(speckle,2,li/2);
      
   else
      speckle=[speckle;speckle];
   end;
   
   % Thin out the points in narrow parts.
   % This keeps everything when abs(dxi)>2*speckle, and then makes
   % it increasingly sparse for smaller intervals.
   dxi=diff(xi);
   nottoosmall=sum(speckle,1)~=0 & rand(1,li/2)<abs(dxi)./(max(sum(speckle,1),eps));
   xi=xi(:,nottoosmall);
   yi=yi(:,nottoosmall);
   dxi=dxi(nottoosmall);
   if size(speckle,2)>1, speckle=speckle(:,nottoosmall); end;
   % Now randomly scatter points (if there any left)
   li=length(dxi);
   if any(li),
      xi(1,:)=xi(1,:)+sign(dxi).*(1-rand(1,li).^0.5).*min(speckle(1,:),abs(dxi) );
      xi(2,:)=xi(2,:)-sign(dxi).*(1-rand(1,li).^0.5).*min(speckle(2,:),abs(dxi) );
      % Remove the 'zero' speckles
      if size(speckle,2)>1,
         xi=xi(speckle~=0);
         yi=yi(speckle~=0);
      end;
   end;
else
   xi = [xi; ones(1,li/2)*nan];  % Separate the line segments
   yi = [yi; ones(1,li/2)*nan];
end;

% Transform back to the original coordinate system
xydatai = [ca -sa;sa ca]*[xi(:)'+u0;(yi(:)'-offset)*step+v0];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [h,opts,props] = parse_input(h,argin)
% parse & validate input arguments

patchtypes = {'single','cross','speckle','outspeckle','fill','none'};

% get base object handle
if ~issupported(h)
   error('Unsupported graphics handle type.');
end
h = handle(h);

% get common property names
pnames = getcommonprops(h);

% if style argument is given, convert it to HatchStyle option pair
stylearg = {};
if ~isempty(argin) && ischar(argin{1})
   try
      ptypes = validatestring(argin{1},patchtypes);
      stylearg = {'HatchStyle' ptypes};
      argin(1) = [];
   catch
      % STYL not given, continue on
   end
end

% create inputParser for options
p = inputParser;
p.addParameter('HatchStyle','single',@ischar);
p.addParameter('HatchAngle',45,@(v)validateattributes(v,{'numeric'},{'scalar','finite'}));
p.addParameter('HatchSpacing',5,@(v)validateattributes(v,{'numeric'},{'scalar','positive','finite'}));
p.addParameter('HatchOffset',0,@(v)validateattributes(v,{'numeric'},{'scalar','nonnegative','<',1}));
p.addParameter('HatchColor','auto',@validatecolor);
p.addParameter('HatchLineStyle','-',@ischar);
p.addParameter('HatchLineWidth',0.5,@(v)validateattributes(v,{'numeric'},{'scalar','positive','finite'}));
p.addParameter('SpeckleWidth',7,@(v)validateattributes(v,{'numeric'},{'scalar','finite'}));
p.addParameter('SpeckleDensity',1,@(v)validateattributes(v,{'numeric'},{'scalar','positive','finite'}));
p.addParameter('SpeckleMarkerStyle','.',@ischar);
p.addParameter('SpeckleSize',2,@(v)validateattributes(v,{'numeric'},{'scalar','positive','finite'}));
p.addParameter('SpeckleFillColor','auto',@validatecolor);
p.addParameter('HatchVisible','auto',@ischar);
p.addParameter('ContourStyle','nonconvex');

for n = 1:numel(pnames)
   p.addParameter(pnames{n},[]);
end
p.parse(stylearg{:},argin{:});

rnames = fieldnames(p.Results);
isopt = ~cellfun(@isempty,regexp(rnames,'^(Hatch|Speckle)','once')) | strcmp(rnames,'ContourStyle');
props = struct([]);
for n = 1:numel(rnames)
   if isopt(n)
      opts.(rnames{n}) = p.Results.(rnames{n});
   elseif ~isempty(p.Results.(rnames{n}))
      props(1).(rnames{n}) = p.Results.(rnames{n});
   end
end

opts.HatchStyle = validatestring(opts.HatchStyle,patchtypes);
if strcmpi(opts.HatchStyle,'none') % For backwards compatability:
   opts.HatchStyle = 'fill';
end
opts.HatchLineStyle = validatestring(opts.HatchLineStyle,{'-','--',':','-.'},'hatchfill2','HatchLineStyle');
opts.SpeckleMarkerStyle = validatestring(opts.SpeckleMarkerStyle,{'+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram'},'hatchfill2','SpeckleMarkerStyle');
opts.HatchVisible = validatestring(opts.HatchVisible,{'auto','on','off'},'hatchfill2','HatchVisible');
opts.ContourStyle = validatestring(opts.ContourStyle,{'convex','nonconvex'});
end

function pnames = getcommonprops(h)
% grab the common property names of the base objects

V = set(h(1));
pnames = fieldnames(V);
if ishghandle(h(1),'hggroup')
   pnames = union(pnames,getcommonprops(get(h(1),'Children')));
end
for n = 2:numel(h)
   V = set(h(n));
   pnames1 = fieldnames(V);
   if ishghandle(h(n),'hggroup')
      pnames1 = union(pnames1,getcommonprops(get(h(n),'Children')));
   end
   pnames = intersect(pnames,pnames1);
end

end

function validatecolor(val)

try
   validateattributes(val,{'double','single'},{'numel',3,'>=',0,'<=',1});
catch
   validatestring(val,{'auto','y','yellow','m','magenta','c','cyan','r','red',...
      'g','green','b','blue','w','white','k','black'});
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% axes unit conversion functions

function [x,y] = data2px(ax,x,y,x2px,y2px,islog,xlim,ylim)

% log to linear space
if islog(1)
   x = log10(x);
end
if islog(2)
   y = log10(y);
end

% add offsets
if strcmp(ax.XDir,'normal')
   x = x - xlim(1);
else
   x = xlim(2) - x;
end
if strcmp(ax.YDir,'normal')
   y = y - ylim(1);
else
   y = ylim(2) - y;
end

% pixel origin is (0,0)
x = x/x2px;
y = y/y2px;
end

function [x,y] = px2data(ax,x,y,x2px,y2px,islog,xlim,ylim)

% pixel origin is (0,0)
x = x*x2px;
y = y*y2px;

% add offsets
if strcmp(ax.XDir,'normal')
   x = x + xlim(1);
else
   x = xlim(2) - x;
end
if strcmp(ax.YDir,'normal')
   y = y + ylim(1);
else
   y = ylim(2) - y;
end

% log to linear space
if islog(1)
   x = 10.^(x);
end
if islog(2)
   y = 10.^(y);
end
end

function [x2px,y2px,islog,xlim,ylim] = data2pxratio(ax)
%DATA2PXRATIO   Get pixel to axis data unit conversion factors
%   [AxPos0,X2Px,Y2Px,XLim,YLim] = DATA2PXRATIO(AX) computes the location
%   of the lower left hand corner of the axis in pixels with respect to the
%   lower left hand corner of the figure, ratio of unit x-coordinate length
%   to number of pixels, X2Px, ratio fo the unit y-coodinate length to
%   number of pixels, Y2Px, and the axes position of AX. In addition, the
%   limits of x and y axes are returned in XLim and YLim.

islog = strcmp({ax.XScale ax.YScale},'log'); % needs updating

% get the axes position in pixels
units_bak = ax.Units;  % save the original Units mode
ax.Units = 'pixels';
axloc_px = ax.Position;
ax.Units = units_bak;    % reset to the original Units mode

darIsManual  = strcmp(ax.DataAspectRatioMode,'manual');
pbarIsManual = strcmp(ax.PlotBoxAspectRatioMode,'manual');
xlim = ax.XLim; if islog(1), xlim(:) = log10(xlim); end
ylim = ax.YLim; if islog(2), ylim(:) = log10(ylim); end
dx = diff(xlim);
dy = diff(ylim);

if darIsManual || pbarIsManual
   axisRatio = axloc_px(3)/axloc_px(4);
   
   if darIsManual
      dar = ax.DataAspectRatio;
      limDarRatio = (dx/dar(1))/(dy/dar(2));
      if limDarRatio > axisRatio
         ht = axloc_px(3)/limDarRatio;
         axloc_px(4) = ht;
      else
         wd = axloc_px(4) * limDarRatio;
         axloc_px(3) = wd;
      end
   else%if pbarIsManual
      pbar = ax.PlotBoxAspectRatio;
      pbarRatio = pbar(1)/pbar(2);
      if pbarRatio > axisRatio
         ht = axloc_px(3)/pbarRatio;
         axloc_px(4) = ht;
      else
         wd = axloc_px(4) * pbarRatio;
         axloc_px(3) = wd;
      end
   end
end

% convert to data unit
x2px = dx/axloc_px(3);
y2px = dy/axloc_px(4);

end
