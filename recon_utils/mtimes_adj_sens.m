function [x_out] = mtimes_sens(Es, kd)
    % kd: p.NCols, p.Nsegs, p.NPhases, p.Nshots, p.NCoils
    NPhases=size(kd,3);
    Nshots=size(kd,4);
    NCoils=size(kd,5);
    E = Es(1);
    x_out = zeros([E.Nd, E.Nt]);
    kd = reshape(kd, [], NPhases, Nshots, NCoils);
    for ii=1:Nshots
        E = Es(ii);
        x_out = x_out + reshape(E'*squeeze(kd(:,:,ii,:)), [E.Nd, E.Nt]);
    end
end