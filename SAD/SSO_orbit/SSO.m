clc
clear
close all

% SSO Calculator 
clc; clear; close all;

%% Constants
Re = 6378.137e3;          % Earth radius [m]
mu = 3.986004418e14;      % Earth gravitational parameter [m^3/s]

%% Orbital parameters
h = 600e3;
a = Re + h;
e = 0;

i = deg2rad(97.78);
LTAN = 9; %orbit sso 9am to 21 pm

n = sqrt(mu/a^3);
T = 2*pi/n;

%% Sun geometry
d = 1:365;                % Day of year

delta = deg2rad(23.44) .* sin(2*pi*(d-80)/365.2422);

H = deg2rad(15*(LTAN-12));

%% Beta angle
sin_beta = sin(i).*cos(delta).*sin(H) + cos(i).*sin(delta);

beta = asin(sin_beta);

%% Eclipse calculation
beta_crit = asin(Re/a);

theta_e = acos(sqrt(1-(Re/a)^2)./cos(beta));

eclipse_time = zeros(size(d));

eclipse_condition = abs(beta) < beta_crit;

eclipse_time(eclipse_condition) = ...
    2*theta_e(eclipse_condition)/n;

%% Results
fprintf('Orbital period: %.2f min\n',T/60);
fprintf('Critical beta: %.2f deg\n',rad2deg(beta_crit));
fprintf('Maximum eclipse: %.2f min\n',max(eclipse_time)/60);
fprintf('Minimum eclipse: %.2f min\n',min(eclipse_time)/60);

%% Plots
figure;
plot(d,rad2deg(beta),'LineWidth',1.5);
grid on;
xlabel('Day of year');
ylabel('Beta angle [deg]');
title('Beta angle throughout the year');

figure;
plot(d,eclipse_time/60,'LineWidth',1.5);
grid on;
xlabel('Day of year');
ylabel('Eclipse duration [min]');
title('Eclipse duration throughout the year');