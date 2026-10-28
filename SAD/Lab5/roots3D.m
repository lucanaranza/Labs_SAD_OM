function F = roots3D(phi, theta, psi, HB0_unit, pI_unit)

    A = DCM312(phi, theta, psi);

    F = A * pI_unit - HB0_unit;
    F = F(:);

end