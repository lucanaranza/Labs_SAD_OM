clear; clc; close all;
%% Task 1 Orbit parameters and environment
r_sun = 1.496 * 10^11; % [m]
mu_E = 3.986 * 10^14; % [m^3/s^2]
theta0 = deg2rad(0);
i = deg2rad(45); %inclination
e = 0.01;
T = 365.25 * 24 * 3600; % [s] Sun year
n_s = 2*pi/T; % for sun
epsilon = deg2rad(23.45); % [rad]
Mt = 5.97 * 10^24; % [kg]
G = 6.67 * 10^-11; % [m^3/(kg*s^2)]
a = 8000e3; % [m]
n = sqrt(mu_E/a^3);
Tf = 2*pi*sqrt(a^3/mu_E); %orbit period [s]

%% Task 2 and 3 Gravity gradient and SRP
Ix = 22 * 10^-2;
Iy = 25 * 10^-2;
Iz = 33 * 10^-2;
I_depl = diag([Ix, Iy, Iz]); % [Kg*m^2]
omega = [0; 0; 0]; %[rad/s]
A0 = eye(3);
c = 3 * 10^8; % [m/s]
Fe = 1358; % [W/m^2]
P = Fe/c;
L1  = [0; 0; +1];
L2  = [0; +1; 0];
L3  = [0; 0; -1];
L4  = [0; -1; 0];
B1  = [+1; 0; 0];
B2  = [-1; 0; 0];
Panel1  = [0; 0; +1];
Panel2  = [0; 0; +1];
Panel3  = [0; 0; -1];
Panel4  = [0; 0; -1];
rho_d = 0.1;   
rho_s_body = 0.5;   
rho_s_panel = 0.1;  
rF1  = [0; 0; +0.113]; %[m]
rF2  = [0; +0.113; 0];
rF3  = [0; 0; -0.113];
rF4  = [0; -0.113; 0];
rF5  = [+0.183; 0; 0];
rF6  = [-0.183; 0; 0];
rF7  = [0; +0.273; 0];
rF8  = [0; +0.273; 0];
rF9  = [0; -0.273; 0];
rF10 = [0; -0.273; 0];
A_body1_4 = 0;
A_body5_6 = 0;
A_panel = 0;
r_CM = [0; 0; 0]; % [m]

%% Task 4: Earth Magnetic field
g10 = -29404.8 * 1e-9; % [T]
g11 = -1450.9 * 1e-9;  
h11 = 4652.5 * 1e-9;   
H0 = sqrt(g10^2 + g11^2 + h11^2);
R_E = 6371e3; %Earth radius [m]
omega_E = 2 * pi / 86400; 
tilt_mag = deg2rad(11.5);
j_B = [0; 0; 0]; %Residual satellite dipole

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

Scale_factor = [500; -450; 300]; % Eroare scale factor in ppm

% In-Run Bias Stability (1.8 grade/ora)
Bias_static = [1.8; -1.8; 1.8] * (1/3600) * (pi/180);

%Misalignment errors in radians
g_xy =  0.05 * (pi/180); g_xz = -0.03 * (pi/180);
g_yx = -0.04 * (pi/180); g_yz =  0.06 * (pi/180);
g_zx =  0.02 * (pi/180); g_zy = -0.05 * (pi/180);

M_misalign = [1,  g_xy,  g_xz;
              g_yx,  1,  g_yz;
              g_zx,  g_zy, 1];
%% Star Tracker Init and Simulation

% Load catalog
T = readtable('star_map.xlsx');
S_all = [T.p_x, T.p_y, T.p_z]'; % 3 x 60

% Set dimensions for Simulink (Full Catalog)
S_catalog = S_all; 
N_stars = size(S_catalog, 2); % 60
S_T = S_catalog'; % 60 x 3

% Misalignment
alpha_rad = 0;
A_e = [ 1,          alpha_rad, -alpha_rad;
       -alpha_rad,  1,          alpha_rad;
        alpha_rad, -alpha_rad,  1 ];
S_tilde = A_e * S_catalog; % 3 x 60

% Set FOV
FoV_half_deg = 12.7; 
cos_FoV = cosd(FoV_half_deg);

% Boresight Alnilam (for plotting only, since Simulink uses the full 60)
boresight_vector = [0.10450511; 0.99430382; -0.02094247]; 
boresight_vector = boresight_vector / norm(boresight_vector); 

% Filter stars (for plotting only)
cos_angles = boresight_vector' * S_all;
angles_deg = acos(cos_angles) * (180/pi);
valid_idx = find(angles_deg <= FoV_half_deg);
S_visible = S_all(:, valid_idx); % 5 stars

% Optics & Noise (Sagitta 10" specification)
f = 0.05;
sigma_rad = (3 / 3600) * (pi / 180);
var_uv = (f * tan(sigma_rad))^2;

% Noise seeds
rng(42);
seed_u = randi(1000000, 1, N_stars);
seed_v = randi(1000000, 1, N_stars) + 1;

% Run Simulation
out = sim('DKE', 'Solver', 'ode4', 'FixedStep', '1e-2', 'StopTime', 'Tf');

% plots
% Inputs
A_real = out.A_real; 
A_est = out.A_est;   

% Base loop length STRICTLY on the physical dimension of the estimated matrix
N_samples = size(A_est, 3);

% Sanity check: prevent comparing continuous A_real with discrete A_est
if size(A_real, 3) ~= N_samples
    error('Critical mismatch: A_real has %d samples, and A_est has %d. Set "Sample time = 0.1" in both "To Workspace" blocks in Simulink.', size(A_real, 3), N_samples);
end

% Generate uniform time axis matching the number of elements
t = linspace(0, out.tout(end), N_samples)';

% Preallocate
error_pitch = zeros(N_samples, 1);
error_yaw = zeros(N_samples, 1);
error_roll = zeros(N_samples, 1);

% Calculate errors
for k = 1:N_samples
    A_r = A_real(:,:,k);
    A_e = A_est(:,:,k);
    
    % Error matrix
    A_err = A_e * A_r'; 
    
    % Extract angles
    error_roll(k)  = -A_err(2,3); 
    error_pitch(k) =  A_err(1,3); 
    error_yaw(k)   = -A_err(1,2); 
end

% Convert to arcsec
arcsec_conv = (180/pi) * 3600;
error_roll_arcsec = error_roll * arcsec_conv;
error_pitch_arcsec = error_pitch * arcsec_conv;
error_yaw_arcsec = error_yaw * arcsec_conv;

% Plot Attitude Errors
figure('Name', 'Attitude Errors [arcsec]', 'Position', [100, 100, 800, 600]);

subplot(3,1,1);
plot(t, error_roll_arcsec, 'b', 'LineWidth', 1);
grid on; ylabel('Roll ["]'); 
title('Boresight Error');

subplot(3,1,2);
plot(t, error_pitch_arcsec, 'r', 'LineWidth', 1);
grid on; ylabel('Pitch ["]'); 
title('Cross-Boresight 1');

subplot(3,1,3);
plot(t, error_yaw_arcsec, 'k', 'LineWidth', 1);
grid on; ylabel('Yaw ["]'); xlabel('Time [s]');
title('Cross-Boresight 2');

% Plot Star Catalog Distribution
figure('Name', 'Star Catalog - Global vs FOV', 'Position', [200, 200, 700, 600]);
hold on; grid on; axis equal;

% Plot the 55 stars outside the camera FOV
plot3(S_all(1,:), S_all(2,:), S_all(3,:), 'b.', 'MarkerSize', 10, 'DisplayName', 'Global Catalog (60 stars)');

% Plot the 5 stars focused by the camera
plot3(S_visible(1,:), S_visible(2,:), S_visible(3,:), 'r*', 'MarkerSize', 12, 'DisplayName', 'Visible Cluster in FOV (5 stars)');

% Plot sensor boresight direction
quiver3(0, 0, 0, boresight_vector(1), boresight_vector(2), boresight_vector(3), 1.2, 'k', 'LineWidth', 2, 'DisplayName', 'Optical Axis (Boresight)');

xlabel('X'); ylabel('Y'); zlabel('Z');
title('Star Distribution and Sensor Field of View');
legend('show', 'Location', 'best');
view(30, 20);
hold off;


%% Task 5: Run simulation and plots

%Data extraction
t = out.t;
M_srp = out.M_srp;
M_mag = out.M_mag;
M_gg  = out.M_gg;
r_N   = out.r_N; 

omega_out = out.omega_out;
omega_norm = vecnorm(omega_out,2,2);

figure;
hold on; grid on;
plot(t, omega_out(:,1), "Color", 'r');
plot(t, omega_out(:,2), "Color", 'g');
plot(t, omega_out(:,3), "Color", 'b');
plot(t, omega_norm, "Color", 'm');
xlabel('Time [s]');
ylabel('Angular velocity [rad/s]');
title('Angular velocity on each axis and norm');
legend('\omega_x', '\omega_y', '\omega_z', '||\omega||', 'Location', 'best');
hold off;

%Plot 1: Perturbation comparisons (logarithmic scale)
figure('Name', 'Disturbances comparison', 'Color', 'w');
semilogy(t, vecnorm(M_mag, 2, 2), 'r', 'LineWidth', 1.5); hold on;
semilogy(t, vecnorm(M_gg,  2, 2), 'b', 'LineWidth', 1.5);
semilogy(t, vecnorm(M_srp, 2, 2), 'g', 'LineWidth', 1.5);
grid on; xlabel('Time [s]'); ylabel('Torque Magnitude [Nm]');
legend('M_{mag}', 'M_{GG}', 'M_{SRP}', 'Location', 'best');
title('Perturbation torques magnitude');

%Plot 2: Earth 3D orbit
figure('Name', '3D Orbit & Direction', 'Color', 'w');
R_earth = 6371e3; % [m]
[X, Y, Z] = sphere(40);
surf(X*R_earth, Y*R_earth, Z*R_earth, 'FaceColor', [0.2 0.5 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.6);
hold on; axis equal; grid on; view(45, 30);
xlabel('X_N'); ylabel('Y_N'); zlabel('Z_N');

%Trajectory plot
plot3(r_N(:,1), r_N(:,2), r_N(:,3), 'k', 'LineWidth', 2);
%Start point (t=0)
plot3(r_N(1,1), r_N(1,2), r_N(1,3), 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 10);

%Velocity direction arrow
dir_vector = r_N(2,:) - r_N(1,:); %velocity vector at t0
dir_vector = (dir_vector / norm(dir_vector)) * R_earth * 0.5;
quiver3(r_N(1,1), r_N(1,2), r_N(1,3), ...
    dir_vector(1), dir_vector(2), dir_vector(3), ...
    'Color', 'r', 'LineWidth', 2.5, 'MaxHeadSize', 0.5);

%Sun vector at t=0
S_N_out = out.S_N_out;
S_vec = S_N_out(1, :); 

S_vec = S_vec / norm(S_vec);
L = R_earth * 2;
quiver3(0, 0, 0, S_vec(1)*L, S_vec(2)*L, S_vec(3)*L, ...
    'Color', 'y', 'LineWidth', 2);
text(S_vec(1)*L*1.1, S_vec(2)*L*1.1, S_vec(3)*L*1.1, 'SUN', 'Color', 'y');