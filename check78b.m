addpath(genpath('/Users/jambro/GDrive/VAR-Toolbox'));
rng(21,'twister');
T=180; mps=randn(T,1); E=zeros(T,3); e=randn(T,3);
for t=2:T, E(t,:)=0.5*E(t-1,:)+e(t,:)+mps(t)*[1 -0.5 0.3]; end
nl=2;
Vo=VARoption; Vo.ident='sign'; Vo.inference=1; Vo.ndraws=200; Vo.R=[1 1 1;-1 1 1;1 -1 1];
Vo.sr_draw=200000; Vo.mult=1e6;
V=VARmodel(E,nl,1,Vo);

% correct reconstruction: for variable v, total shock contribution = sum over dim 2 of HD.shock(:,:,v)
rec = @(H) arrayfun(@(v) 1, 1:3);  % placeholder
recon = zeros(size(V.HDfp.endo));
for v=1:3
    recon(:,v) = V.HDfp.init(:,v)+V.HDfp.const(:,v)+V.HDfp.trend(:,v)+sum(V.HDfp.shock(:,:,v),2);
end
fprintf('SANITY  HDfp: max|components - endo| = %.3g  (should be ~0)\n', ...
    max(abs(recon(nl+1:end,:)-V.HDfp.endo(nl+1:end,:)),[],'all'));

reconM = zeros(size(V.HDmed.endo));
for v=1:3
    reconM(:,v) = V.HDmed.init(:,v)+V.HDmed.const(:,v)+V.HDmed.trend(:,v)+sum(V.HDmed.shock(:,:,v),2);
end
d = max(abs(reconM(nl+1:end,:)-V.HDmed.endo(nl+1:end,:)),[],'all');
fprintf('ISSUE 8 HDmed: max|components - endo| = %.4f   (data s.d. = %.3f)\n', d, mean(std(V.Y)));
fprintf('ISSUE 8 cross-draw sd of non-shock components (mean over t, var1):\n');
fprintf('   init  = %.4f\n', mean(std(V.HDall.init(nl+1:end,1,:),0,3)));
fprintf('   const = %.4f\n', mean(std(V.HDall.const(nl+1:end,1,:),0,3)));
fprintf('   endo  = %.4f   (all nonzero => they DO vary under inference=1)\n', mean(std(V.HDall.endo(nl+1:end,1,:),0,3)));
disp('DONE');
