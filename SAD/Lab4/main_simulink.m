clc
clear
close all

Ix = 0.07;
Iy = 0.055;
Iz = 0.025;
I_vec = [Ix, Iy, Iz];

wx_0 = 0.45;
wy_0 = 0.52;
wz_0 = 0.55;
w0 = [wx_0; wy_0; wz_0];
q_0 = [0; 0; 0; 1];  % Initial quaternion (already normalized)

I = diag(I_vec);
I_inv = inv(I);

disp("Sent data to Simulink!");

