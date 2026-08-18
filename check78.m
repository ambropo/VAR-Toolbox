addpath(genpath('/Users/jambro/GDrive/VAR-Toolbox'));
rng(21,'twister');
T=180; mps=randn(T,1); E=zeros(T,3); e=randn(T,3);
for t=2:T, E(t,:) = 0.5*E(t-1,:) + e(t,:) + mps(t)*[1 -0.5 0.3]; end

fprintf('--- Issue 8: do SR HD summaries reconstruct? (inference=1) ---\n');
Vo=VARoption; Vo.ident='sign'; Vo.inference=1; Vo.ndraws=200; Vo.R=[1 1 1;-1 1 1;1 -1 1];
Vo.sr_draw=200000; Vo.mult=1e6;
V=VARmodel(E,2,1,Vo);
f=@(s) V.HDmed.(s);
recon = f('init')+f('const')+f('trend')+sum(f('shock'),3);
err = max(abs(recon(3:end,:) - V.HDmed.endo(3:end,:)),[],'all');
fprintf('  max|sum of HDmed components - HDmed.endo| = %.4f   (sd of data = %.3f)\n', err, mean(std(V.Y)));
fprintf('  i.e. median shock components + copied non-shock do NOT sum to the copied endo\n');
% how much do non-shock components actually vary across draws?
sd_init = std(V.HDall.init(3:end,1,:),0,3);
fprintf('  cross-draw sd of HD.init (var1, mean over t) = %.4f  (0 => no variation)\n', mean(sd_init));

fprintf('\n--- New gap: exoshock component under the sign path ---\n');
Vo2=VARoption; Vo2.ident='sign'; Vo2.inference=0; Vo2.ndraws=20; Vo2.R=[1 1 1;-1 1 1;1 -1 1];
Vo2.exoshock=mps; Vo2.nlag_exoshock=0; Vo2.sr_draw=200000; Vo2.mult=1e6;
V2=VARmodel(E,2,1,Vo2);
fprintf('  HDfp has exoshock field: %d\n', isfield(V2.HDfp,'exoshock'));
fprintf('  HDmed has exoshock field: %d  <-- dropped\n', isfield(V2.HDmed,'exoshock'));
r2 = V2.HDmed.init+V2.HDmed.const+V2.HDmed.trend+sum(V2.HDmed.shock,3);
fprintf('  max|HDmed components - HDmed.endo| = %.4f\n', max(abs(r2(3:end,:)-V2.HDmed.endo(3:end,:)),[],'all'));
r3 = V2.HDfp.init+V2.HDfp.const+V2.HDfp.trend+V2.HDfp.exoshock+sum(V2.HDfp.shock,3);
fprintf('  max|HDfp components (incl exoshock) - HDfp.endo| = %.3g  (fp path is fine)\n', max(abs(r3(3:end,:)-V2.HDfp.endo(3:end,:)),[],'all'));
disp('DONE');
