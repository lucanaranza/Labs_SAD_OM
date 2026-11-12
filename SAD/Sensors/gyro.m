%% Sensor parameters
Ts = 0.01; % time step 100Hz

%Tactic giroscope
bias_deg_hr = 1.8;  % [deg/hr]
arw_deg_sqrthr = 0.09; % [deg/sqrt(hr)]

% Rate random walk (RRW)
RRW = bias_deg_hr * (pi/180) / 3600; % [rad/s]

%Angle Random Walk (ARW) 
ARW = arw_deg_sqrthr * (pi/180) / 60; % [rad/sqrt(s)]

Pn_g = (ARW^2) / Ts; % Noise power
Pb_g = (RRW^2) / Ts; % Bias power

Scale_factor = [500; -450; 300]; % 10^-6 in simulink (parts per million)

% In-Run Bias Stability (1.8 grade/hour)
Bias_static = [1.8; -1.8; 1.8] * (1/3600) * (pi/180);

%Misalignment errors in radians
g_xy =  0.05 * (pi/180); g_xz = -0.03 * (pi/180);
g_yx = -0.04 * (pi/180); g_yz =  0.06 * (pi/180);
g_zx =  0.02 * (pi/180); g_zy = -0.05 * (pi/180);

M_misalign = [1,  g_xy,  g_xz;
    g_yx,  1,  g_yz;
    g_zx,  g_zy, 1];