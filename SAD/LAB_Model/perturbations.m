clc
clear
close all

%% Task 1 Orbit parameters and environment
% Orbital Parameters: 
h = 2000E3;                % 1) Altitude [m]
e = 0.02;                  % 2) Eccentricity []
i = deg2rad(45);           % 3) Inclination [rad]
RAAN = deg2rad(0);         % 4) Right ascension of ascending node [rad]
AOP = deg2rad(0);          % 5) Argument of periapsis [rad]
theta0 = deg2rad(0);       % 6) True Anomaly at t=0 [rad]

% Constants
G = 6.6743E-11;            %[m^3/(s^2*kg)] Universal Gravity Constant
r_sun = 1.496E8;           %[m] astronomic unit = distance SUN-EARTH
Mt = 5.97E24;              %[kg] Earth's mass
mu_E = 398600E9;           %[m^3/s^2] G*ME 
r_earth = 6371E3;          %[m] Earth's radius
epsilon = deg2rad(23.45);  %[rad] earth axis inclination
c = 3E8;                   %[m/s] Light Speed in vacuum
Fe = 1358;                 %[W/m^2] Jsun = avg power at 1AU

% Calculations
a = r_earth + h;           %[semi major axis of the orbit]

T = 365.25 * 24 * 3600;    %[s] Sun year period
Tf = 2*pi*sqrt(a^3/mu_E);  %[s]  Orbit's period

n = sqrt(mu_E/a^3);        %[rad/s] mean motion of the earth
n_s = 2*pi/T;              %[rad/s] mean motion of the sun

%% Task 2 and 3 Gravity gradient and SRP
Jx = 100.9 * 10^-2;                          % XX Component inertia matrix                   
Jy = 25.1 * 10^-2;                           % YY component inertia matrix
Jz = 91.6 * 10^-2;                           % ZZ component inertia matrix
J_depl = diag([100.9 , 25.1, 91.6] * 10^-2); % Diagonal Inertia Matrix with solar arrays deployed [Kg*m^2]
J_inv = inv(J_depl);                         % Inverse of the Inertia Matrix 
A0 = eye(3);                                 % Initial DCM A0 = I
omega = [0.02, 0.05, 0.08];                  % Initial angular velocity [rad/s]
P = Fe/c;                                    % Solar radiation pressure norm [Pa]
NB1  = [+1; 0; 0];
NB2  = [0; +1; 0];
NB3  = [-1; 0; 0];
NB4  = [0; -1; 0];
NB5  = [0; 0; +1];
NB6  = [0; 0; -1];
Panel1  = [+1; 0; 0];
Panel2  = [-1; 0; 0];
Panel3  = [+1; 0; 0];
Panel4  = [-1; 0; 0];
rho_d = 0.1;   
rho_s_body  = 0.5;   
rho_s_panel = 0.1;   
rF1  = [+0.10; 0; 0]; % [m]
rF2  = [0; +0.10; 0];
rF3  = [-0.10; 0; 0];
rF4  = [0; -0.10; 0];
rF5  = [0; 0; +0.15];
rF6  = [0; 0; -0.15];
rF7  = [0; +0.45; 0];
rF8  = [0; +0.45; 0];
rF9  = [0; -0.45; 0];
rF10 = [0; -0.45; 0];
A_body1_4 = 6*10^-2;
A_body5_6 = 4*10^-2;
A_panel = 12*10^-2;
r_CM = [0.02; -0.01; 0.015];

%% Task 4: Earth Magnetic field
g10 = -29404.8E-9; % [T]
g11 = -1450.9E-9;  
h11 = 4652.5E-9;   
H0 = sqrt(g10^2 + g11^2 + h11^2); 
omega_E = 2 * pi / 86400; 
tilt_mag = deg2rad(11.5);          % Magnetic axis of the earth tilt wrt rotation axis [rad]
j_B = [0.01; 0.05; 0.01];          % Residual satellite dipole [Am^2]

%% Task 5: Run simulation and plots
out = sim('Pert', 'Solver', 'ode4', 'FixedStep', '1e-2', 'StopTime', 'Tf');

%Data extraction
t = out.t;
M_srp = squeeze(out.M_srp)'; if size(M_srp, 2) ~= 3, M_srp = M_srp'; end
M_mag = squeeze(out.M_mag)'; if size(M_mag, 2) ~= 3, M_mag = M_mag'; end
M_gg  = squeeze(out.M_gg)';  if size(M_gg,  2) ~= 3, M_gg  = M_gg';  end
r_N   = squeeze(out.r_N)';   if size(r_N,   2) ~= 3, r_N   = r_N';   end

%Plot 1: Perturbation comparisons (logarithmic scale)
figure('Name', 'Task 5: Disturbances Comparison', 'Color', 'w');
semilogy(t, vecnorm(M_mag, 2, 2), 'r', 'LineWidth', 1.5); hold on;
semilogy(t, vecnorm(M_gg,  2, 2), 'b', 'LineWidth', 1.5);
semilogy(t, vecnorm(M_srp, 2, 2), 'g', 'LineWidth', 1.5);
grid on; xlabel('Time [s]'); ylabel('Torque Magnitude [Nm]');
legend('M_{mag}', 'M_{GG}', 'M_{SRP}', 'Location', 'best');
title('Perturbation Torques Magnitude');

%Plot 2: Earth 3D orbit
figure('Name', '3D Orbit', 'Color', 'w');
R_earth = 6371e3;
[X, Y, Z] = sphere(40);
surf(X*R_earth, Y*R_earth, Z*R_earth, 'FaceColor', [0.2 0.5 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.6);
hold on; plot3(r_N(:,1), r_N(:,2), r_N(:,3), 'k', 'LineWidth', 2);
axis equal; grid on; view(45, 30);
xlabel('X_N'); ylabel('Y_N'); zlabel('Z_N');
title('Satellite Orbit 3D');

% Magnetic poles (11.5 deg)
tilt = deg2rad(11.5);
L_axis = R_earth * 1.3;
x_mag_N =  L_axis * sin(tilt);
z_mag_N =  L_axis * cos(tilt);
x_mag_S = -L_axis * sin(tilt);
z_mag_S = -L_axis * cos(tilt);
plot3([x_mag_N x_mag_S], [0 0], [z_mag_N z_mag_S], 'm--', 'LineWidth', 1.5);
text(x_mag_N, 0, z_mag_N, ' Magnetic North Pole (11.5^\circ)', 'FontSize', 9, 'FontWeight', 'bold', 'Color', 'm');
text(x_mag_S, 0, z_mag_S, ' Magnetic South Pole', 'FontSize', 9, 'FontWeight', 'bold', 'Color', 'm');