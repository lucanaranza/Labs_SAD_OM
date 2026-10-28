clc
clear
close all

solve = false;

Ix = 0.07;      % Inertia Moments kg*m^2
Iy = 0.055;
Iz = 0.025;
disp("Variables loaded into Simulink");

phi0   = -0.194229122510122;
theta0 = -0.101873263409205;
psi0   = 0.069047529516180;

% Initial Conditions chosen arbitrarily % Dynamics -> Kinematics -> Euler % Angles -> DCMs % Solve non linear system DCM*H_B = H_I desired
out = sim("Euler_Angles.slx");
disp("Simulation Ran...");

% Initial body angular momentum (row vector)
HB = (out.h_B.Data);          % Get data from out simulink
HB0 = HB(1,:)';              % Initial angular momentum vector 
HB0_unit = HB0 / norm(HB0); % Normalize

% Desired inertial pointing vector (choose any nonzero vector)
point_vec = out.pointing_vector.Data(1,:);    % Pointing vector in INERTIAL FRAME 
pI_unit = point_vec' / norm(point_vec);        % Normalize the vector

if solve == true
    % Let's solve the non linear system with fsolve
    x0 = [0; 0; 0];                                          % Initial guess [phi; theta; psi]
    options = optimoptions('fsolve', 'Display', 'iter');     % Display convergence between iterations
    x = fsolve(@(x) roots3D(x(1), x(2), x(3), HB0_unit, pI_unit), x0, options);
    phi0   = x(1);
    theta0 = x(2);
    psi0   = x(3);

    % Verify
    A0 = DCM312(phi0, theta0, psi0);
    HI0 = A0' * HB0;
    disp("Initial inertial angular momentum:");
    disp(HI0);
    disp("Normalized direction:");
    disp(HI0 / norm(HI0));
    disp("Desired normalized direction:");
    disp(pI_unit);
    disp("Pointing error (deg):");
    error_deg = acosd(dot(HI0/norm(HI0), pI_unit));
    disp(error_deg);
end