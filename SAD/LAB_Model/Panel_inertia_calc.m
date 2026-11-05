clear; clc;

%% Inputs [m, kg]. Body axes: x = long axis (nadir), y = panel axis, z = orbit normal
Lx = 0.3660; Ly = 0.2263; Lz = 0.2263;   % 12U bus
mBus  = 20;
wp    = 0.17;                            % panel width (along x)
sigma = 12;                              % panel areal density [kg/m^2]
nP    = 2;
lp    = 0.32;                            % chosen panel length (along y)

%% Max panel length that keeps Iz > Iy > Ix and 1+3Kr+KyKr > 4*sqrt(KyKr)
ok = @(l) stable(l, Lx, Ly, Lz, mBus, wp, sigma, nP);
lo = 1e-3; hi = 2;
assert(ok(lo), 'Bus alone is not stable');
for k = 1:60                             % bisection
    mid = (lo+hi)/2;
    if ok(mid), lo = mid; else, hi = mid; end
end
lpMax = lo;

%% Chosen configuration
[s, I, g] = stable(lp, Lx, Ly, Lz, mBus, wp, sigma, nP);
Ix = I(1,1); Iy = I(2,2); Iz = I(3,3);
mp = sigma*wp*lp;
A  = max([Ly*Lz, Lx*Lz, Lx*Ly + nP*wp*lp]);   % worst-case projected area

fprintf('Total mass: %.2f kg\n', mBus + nP*mp);
fprintf('Ix = %.4f  Iy = %.4f  Iz = %.4f kg*m^2\n', Ix, Iy, Iz);
fprintf('Stable: %d\n', s);
fprintf('Max panel length: %.3f m | chosen: %.3f m | remaining: %.3f m\n', lpMax, lp, lpMax-lp);
fprintf('Iy - Ix = %.4f kg*m^2 (instability at 0)\n', Iy-Ix);
fprintf('Iz - Iy = %.4f kg*m^2 (instability at 0)\n', Iz-Iy);
fprintf('1+3Kr+KyKr-4sqrt(KyKr) = %.4f (instability below 0)\n\n', g);

%% Orbit
mu = 3.986e14; Re = 6378e3; R = Re + 1300e3;
v  = sqrt(mu/R);

%% Worst-case disturbance torques
GG = 1.5*mu/R^3 * max(abs([Iz-Iy, Ix-Iz, Iy-Ix]));

B0   = 3.12e-5; Bmax = 2*B0*(Re/R)^3;    % dipole model, polar value
mRes = 0.1;                              % residual dipole [A*m^2]
MAG  = mRes*Bmax;

rho = 3e-13; Cd = 2.2; cpcm = 0.01;      % density, drag coeff, CP-CM offset
DRAG = 0.5*rho*v^2*Cd*A*cpcm;

P = 4.56e-6; q = 0.6;                    % SRP pressure, reflectivity
SRP = P*A*(1+q)*cpcm;

%% Ranking
names = {'GG','Magnetic','Drag','SRP'};
[Ts, idx] = sort([GG MAG DRAG SRP], 'descend');
for k = 1:4
    fprintf('%d. %-9s %.2e N*m\n', k, names{idx(k)}, Ts(k));
end

%% (keep at the END of the file)
function [s, I, g] = stable(l, Lx, Ly, Lz, mBus, wp, sigma, nP)
    m  = sigma*wp*l;
    d  = Ly/2 + l/2;
    Ib = mBus/12*diag([Ly^2+Lz^2, Lx^2+Lz^2, Lx^2+Ly^2]);
    Ip = m/12*diag([l^2, wp^2, wp^2+l^2]) + m*diag([d^2, 0, d^2]);
    I  = Ib + nP*Ip;
    Ix = I(1,1); Iy = I(2,2); Iz = I(3,3);
    Kr = (Iz-Ix)/Iy; Ky = (Iz-Iy)/Ix;
    g  = 1 + 3*Kr + Ky*Kr - 4*sqrt(max(Kr*Ky, 0));
    s  = Iz > Iy && Iy > Ix && g > 0;
end