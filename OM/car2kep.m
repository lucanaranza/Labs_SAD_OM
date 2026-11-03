function [a, e, i, OM, om, th] = car2kep(rr, vv, mu)
% Transformation from cartesian coordinates to keplerian
%
% [a, e, i, OM, om, th] = car2kep(rr, vv, mu)
% -------------------------------------------------------------------------
% Input arguments:
% rr    [3x1]   position vector         [km]
% vv    [3x1]   velocity vector         [km/s]
% mu    [1x1]   gravitational parameter [km^3/s^2]
% -------------------------------------------------------------------------
% Output arguments:
% a     [1x1]   semi-major axis         [km]
% e     [1x1]   eccentricity            [-]
% i     [1x1]   inclination             [rad]
% OM    [1x1]   RAAN                    [rad]
% om    [1x1]   pericenter anomaly      [rad]
% th    [1x1]   true anomaly            [rad]
% -------------------------------------------------------------------------

    kk  = [0; 0; 1];
    tol = 1e-6;        % tolerance used for circular orbit check
    
    r  = norm(rr);
    v  = norm(vv);
    
    a  = (2/r - v^2/mu)^(-1);
    
    hh = cross(rr, vv);
    h  = norm(hh);
    
    ee = (1/mu) .* cross(vv, hh) - rr./r;
    e  = norm(ee);
    
    i  = acos(hh(3) / h);
    
    if (sin(i) < tol)   % sin(i) deals both i=0 & i=pi cases
        OM = 0;
        NN = [1; 0; 0];
    else
        NN = (cross(kk, hh)) ./ norm(cross(kk, hh));
        if NN(2) >= 0
            OM = acos(NN(1));
        else
            OM = 2*pi - acos(NN(1));
        end
    end
    
    if (e < tol)     % circular orbit
        om = 0;
    
        % for a circular orbit NN = ee and so NN x rr > 0 for theta = 0-pi
        % we avoid using v_r because it is identically zero for e = 0
        if dot(cross(NN, rr), hh) >= 0
            th = real(acos(dot(rr, NN) / r));
        else
            th = 2*pi - real(acos(dot(rr, NN)) / r);
        end
    else            % elliptical orbit
        if dot(cross(NN, ee), hh) >= 0
            om = acos(dot(NN, ee) / e);
        else
            om = 2*pi - acos(dot(NN, ee) / e);
        end
        v_r = dot(vv, rr) / r;      % relative velocity
        if v_r >= 0
            th = real(acos(dot(rr, ee)/(r*e)));
        else
            th = 2*pi - real(acos(dot(rr, ee)/(r*e)));
        end
    end
    
    OM = mod(OM, 2*pi);
    om = mod(om, 2*pi);
    th = mod(th, 2*pi);
end