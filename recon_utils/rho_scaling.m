function [rho_k] = rho_scaling(rho_0, r_k, s_k)
    % adaptive rho scaling for ADMM fowllowing Boyd et al. 2010
    % rho_0: initial rho
    % r_k: primal residual
    % s_k: dual residual
    % rho_k: updated rho

    if r_k > 10*s_k
        rho_k = 2*rho_0;
    elseif s_k > 10*r_k
        rho_k = rho_0/2;
    else
        rho_k = rho_0;
    end
end