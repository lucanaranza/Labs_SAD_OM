clear; clc; close all;
% Group 39 - SAD Disturbances Validation script - revised 12/11/2026% 

%% 1) GRAVITY GRADIENT + MAGNETIC TORQUE
% For gravity gradient and magnetic torque check:
% a = a of geostationary orbit
% initial omega = [0 0 n]' where n = angular velocity of the geostationary
% orbit
% i = 0
% All the components of the gravity gradient and of the gravity gradient should be null

flag = 1;                    %[bool] Activates magnetic torque and gravity gradient, disactivates SRP

% 1) Input Parameters: Keplerian elements 
a = 8000E3;                 %[m] Semimajor Axis
e = 0;                       %[] Eccentricity
i = deg2rad(0);              %[rad] inclination
RAAN = deg2rad(0);           %[rad] Right Ascension of Ascending Node
AOP = deg2rad(0);            %[rad] Argument of Periapsis

% 2) Constant Parameters: 
G = 6.67E-11;               %[m^3/(kg*s^2)] Gravitational Constant
r_sun = 1.496E11;             %[m] Distance SUN-EARTH 1AU
M_e = 5.97E24;              %[kg]
mu_E = G*M_e;               %[m^3/s^2] Reduced Mass = G * Earth's Mass
T_e = 23*60*60 + 56*60 + 4; %[s] Earth Sidereal Period
T_s = 365.25 * 24 * 3600;   %[s] Earth around the Sun Sidereal Period
Tf = 2*pi*sqrt(a^3/mu_E);   %[s] orbital period 
n = sqrt(mu_E/a^3);         %[rad/s] Mean Motion of satellite

T = 365.25 * 24 * 3600; % [s] Sun year
n_s = 2*pi/T; % for sun
epsilon = deg2rad(23.45); % [rad]
Mt = 5.97 * 10^24; % [kg]


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
Panel1  = [+1; 0; 0];
Panel2  = [+1; 0; 0];
Panel3  = [-1; 0; 0];
Panel4  = [-1; 0; 0];
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
rF8  = [0; -0.273; 0];
rF9  = [0; +0.273; 0];
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

%% Validation gravity gradient

omega = [0; 0; n];
j_B = [0 0 0];
theta0 = deg2rad(0);
flag_GG = 1;
flag_SRP = 0;

out = sim('disturbances_test', 'Solver', 'ode5', 'FixedStep', '0.1', 'StopTime', 'Tf');
t     = out.t;
M_gg  = out.M_gg;

figure('Name', 'Gravity gradient check')
plot(t,M_gg)
grid on
legend('x','y','z')
xlabel('t [s]')
ylabel('torque')

%% Validation magnetic torque

omega = [0; 0; n];
j_B = [0 0 0.01];
theta0 = deg2rad(0);
tilt_mag = deg2rad(0);
flag_GG = 0;
flag_SRP = 0;

out = sim('disturbances_test', 'Solver', 'ode5', 'FixedStep', '0.1', 'StopTime', 'Tf');
t      = out.t;
M_mag  = out.M_mag;

figure('Name', 'Magnetic torque check')
plot(t,M_mag)
grid on
legend('x','y','z')
xlabel('t [s]')
ylabel('torque')

%% Validation SRP

omega = [0; 0; 0];
j_B = [0 0 0];
theta0 = deg2rad(0);
tilt_mag = deg2rad(0);
flag_GG = 0;
flag_SRP = 1;
r_CM = [0.05; 0; 0]; % [m]

out = sim('disturbances_test', 'Solver', 'ode5', 'FixedStep', '0.1', 'StopTime', 'Tf');
t = out.t;
M_srp = out.M_srp;

figure('Name', 'SRP check')
plot(t,M_srp)
grid on
legend('x','y','z')
xlabel('t [s]')
ylabel('torque')