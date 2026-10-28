clc
clear
close all

Ix = 0.04;
Iy = 0.06;
Iz = 0.08;
I_vec = [Ix; Iy; Iz];
I = diag(I_vec);
I_inv = inv(I);

G = 6.67E-11;
M_t = 5.97E24;
R_t = 6371.14;

h = 400;
R = R_t + h;


n = sqrt(G*M_t/R^3);
t = 0; %Let's evaluate at t=0s the matrix 

A_ln = [cos(n*t), sin(n*t), 0;
       -sin(n*t), cos(n*t), 0;
        0,       0,       1];

wx_0 = 0;
wy_0 = 0;
wz_0 = n;

w0 = [wx_0; wy_0; wz_0];

disp("Sent data to simulink");