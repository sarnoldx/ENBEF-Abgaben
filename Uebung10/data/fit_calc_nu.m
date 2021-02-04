function nu = fit_calc_nu(B,k1,k2,k3)
    nu = k1*exp(k2*(sqrt(B(1)^2+B(2)^2+B(3)^2)))+k3;