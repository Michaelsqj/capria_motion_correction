function [x_out] = mtimes_sens(Es, x, isadj)
    if isadj
        % x: p.NCols, p.Nsegs, p.NPhases, p.Nshots, p.NCoils
        NPhases=size(x,3);
        Nshots=size(x,4);
        NCoils=size(x,5);
        E = Es(1);
        x_out = zeros([E.Nd, E.Nt]);
        x = rehsape(x, [], NPhases, Nshots, NCoils);
        for ii=1:Nshots
            x_out = x_out + E'*squeeze(x(:,:,ii,:));
        end
    end
end