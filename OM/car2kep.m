function [a, e, i, OM, om, th] = car2kep(rr, vv, mu)
% Transformation from cartesian coordinates to keplerian
%
% [a, e, i, Om, om, th] = car2par(rr, vv, mu)
% -------------------------------------------------------------------------
% Input arguments:
% rr    [3x1]   position vector         [km]
% vv    [3x1]   velocity vector         [km/s]
% mu    [1x1]   gravitational parameter [km^3/s^2]
% -------------------------------------------------------------------------
% Output arguments:
% a     [1x1]   semi-major axis         [km]
% e     [1x1]   eccentricity            [-]
% i     [1x1]   inclination [0, 180]    [rad]
% OM    [1x1]   RAAN                    [rad]
% om    [1x1]   pericenter anomaly      [rad]
% th    [1x1]   true anomaly            [rad]
% -------------------------------------------------------------------------
    
    r  = norm(rr);
    v  = norm(vv);
    
    a  = (2/r - v^2/mu)^(-1);
    
    hh = cross(rr, vv);
    h  = norm(hh);
    
    ee = (1/mu) .* cross(vv, hh) - rr./r;
    e  = norm(ee);
    
    i  = acos(hh(3) / h);

    toll = 1e-10;   % tolerance for singularity
    
    if abs(sin(i)) < toll        
        OM = 0;
        NN = [1; 0; 0];
    else
        NN = nn / norm(nn);
        OM = atan2(NN(2), NN(1));
    end    
    
    if abs(e) < toll     % circular orbit
        om = 0;
        th = atan2(dot(cross(NN, rr), hh/h), dot(NN, rr));
    else                 % elliptical orbit
        om = atan2(dot(cross(NN, ee), hh/h), dot(NN, ee));
        th = atan2(dot(cross(ee, rr), hh/h), dot(ee, rr));
    end

    OM = mod(OM, 2*pi);
    om = mod(om, 2*pi);
    th = mod(th, 2*pi);
end