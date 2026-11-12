clear; clc;
%% Task 1 Orbit parameters and environment

% For gravity gradient and magnetic torque check:
% a = a of geostationary orbit
% initial omega = [0 0 n]' where n = angular velocity of the geostationary
% orbit
% i = 0
% All the components of the gravity gradient and of the gravity gradient should be null

i = deg2rad(0); %inclination
a = 42164e3; % [m]
n = sqrt(mu_E/a^3);
Tf = 2*pi*sqrt(a^3/mu_E); %orbit period [s]
omega = [0; 0; n]; %[rad/s]
flag = 1; % Activates magnetic torque and gravity gradient, disactivates SRP

r_sun = 1.496 * 10^11; % [m]
mu_E = 3.986 * 10^14; % [m^3/s^2]
theta0 = deg2rad(100);
e = 0;
T = 365.25 * 24 * 3600; % [s] Sun year
n_s = 2*pi/T; % for sun
epsilon = deg2rad(23.45); % [rad]
Mt = 5.97 * 10^24; % [kg]
G = 6.67 * 10^-11; % [m^3/(kg*s^2)]

%% Task 2 and 3 Gravity gradient and SRP 
Ix = 22.53 * 10^-2;
Iy = 26.71 * 10^-2;
Iz = 33.03 * 10^-2;
I_depl = diag([  Ix,   Iy,   Iz]); % [Kg*m^2]
I_inv  = diag([1/Ix, 1/Iy, 1/Iz]);
omega_E = 2 * pi / 86400; 
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
r_CM = [0; 0; 0]; % [m]

%% Task 4: Earth Magnetic field
g10 = -29404.8 * 1e-9; % [T]
g11 = -1450.9 * 1e-9;  
h11 = 4652.5 * 1e-9;   
H0 = sqrt(g10^2 + g11^2 + h11^2);
R_E = 6371e3; %Earth radius [m]
tilt_mag = deg2rad(11.5);
j_B = [0.01 0.01 0.01]; %Residual satellite dipole

%% Run simulink for magnetic torque and gravity gradient and plot

Tf_sim = Tf/8;
out = sim('disturbances_test', 'Solver', 'ode5', 'FixedStep', '0.1', 'StopTime', 'Tf_sim');

t     = out.t;
M_mag = out.M_mag_L;
M_gg  = out.M_gg;

figure('Name', 'Magnetic torque check')
plot(t,M_mag)
grid on
legend('x','y','z')
xlabel('t [s]')
ylabel('torque')

figure('Name', 'Gravity gradient check')
plot(t,M_gg)
grid on
legend('x','y','z')
xlabel('t [s]')
ylabel('torque')

%% Check SRP

% For solar radiation pressure check:
% a = a of generic orbit
% initial omega = [0 0 0]'
% i = 0

a = 8000e3; % [m]
n = sqrt(mu_E/a^3);
Tf = 2*pi*sqrt(a^3/mu_E); %orbit period [s]

omega = [0; 0; 0]; %[rad/s]

flag = 0; % Activates SRP

t = out.t;
M_srp = out.M_srp;

%% Run simulink for SRP and plot

out = sim('disturbances_test', 'Solver', 'ode4', 'FixedStep', '1e-2', 'StopTime', 'Tf');

figure('Name', 'SRP check')
plot(t,M_srp)
grid on
legend('x','y','z')
xlabel('t [s]')
ylabel('torque')