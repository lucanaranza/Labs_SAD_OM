clear; clc;
%% Task 1 Orbit parameters and environment
r_sun = 1.496 * 10^11; % [m]
mu_E = 3.986 * 10^14; % [m^3/s^2]
theta0 = deg2rad(100);
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
Ix = 22.53 * 10^-2;
Iy = 26.71 * 10^-2;
Iz = 33.03 * 10^-2;
I_depl = diag([  Ix,   Iy,   Iz]); % [Kg*m^2]
I_inv  = diag([1/Ix, 1/Iy, 1/Iz]);
omega = [0.02; 0.05; 0.08]; %[rad/s]
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
rho_s_body  = 0.5;   
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
A_body1_4 = 0.082716;
A_body5_6 = 0.051076;
A_panel = 0.0544;
r_CM = [0.015; 0.2; 0]; % [m]

%% Task 4: Earth Magnetic field
g10 = -29404.8 * 1e-9; % [T]
g11 = -1450.9 * 1e-9;  
h11 = 4652.5 * 1e-9;   
H0 = sqrt(g10^2 + g11^2 + h11^2);
R_E = 6371e3; %Earth radius [m]
omega_E = 2 * pi / 86400; 
tilt_mag = deg2rad(11.5);
j_B = [0.01; 0.05; 0.01]; %Residual satellite dipole

%% Task 5: Run simulation and plots
out = sim('DKE', 'Solver', 'ode4', 'FixedStep', '1e-2', 'StopTime', 'Tf');

%Data extraction
t     = out.t;
M_srp = out.M_srp;
M_mag = out.M_mag;
M_gg  = out.M_gg;
r_N   = out.r_N; 

%Plot 1: Perturbation comparisons (logarithmic scale)
figure('Name', 'Disturbances comparison', 'Color', 'w');
semilogy(t, vecnorm(M_mag, 2, 2), 'r', 'LineWidth', 1.5); hold on;
semilogy(t, vecnorm(M_gg,  2, 2), 'b', 'LineWidth', 1.5);
semilogy(t, vecnorm(M_srp, 2, 2), 'g', 'LineWidth', 1.5);
grid on; xlabel('Time [s]'); ylabel('Torque Magnitude [Nm]');
legend('M_{mag}', 'M_{GG}', 'M_{SRP}', 'Location', 'best');
title('Perturbation torques magnitude');

%% Plot 2: Earth 3D orbit
ecl_i = find(out.its_eclipse_time, 1, 'first');
ecl_f = find(out.its_eclipse_time, 1, 'last');

figure('Name', '3D Orbit', 'Color', 'w');
R_earth = 6371e3; % [m]
[X, Y, Z] = sphere(40);
surf(X*R_earth, Y*R_earth, Z*R_earth, 'FaceColor', [0.2 0.5 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.6);
hold on; plot3(r_N(:,1), r_N(:,2), r_N(:,3), 'k', 'LineWidth', 2);
axis equal; grid on; view(45, 30);
xlabel('X_N'); ylabel('Y_N'); zlabel('Z_N');
plot3(r_N(ecl_i:ecl_f, 1), r_N(ecl_i:ecl_f, 2), r_N(ecl_i:ecl_f, 3), 'r', 'LineWidth', 2)
title('Satellite Orbit 3D');

%Trajectory plot
% plot3(r_N(:,1), r_N(:,2), r_N(:,3), 'k', 'LineWidth', 2);
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