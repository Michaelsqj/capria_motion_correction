function [Es] = precal_E_sens(ktraj, senses)
    % ktraj: p.NCols, p.Nsegs, p.NPhases, p.Nshots, 3
    % sens: sx, sy, sz, p.NCoils, p.Nshots
    im_size = size(senses, 1:3);
    NCoils = size(senses, 4);
    NPhases = size(ktraj, 3);
    Nshots= size(ktraj, 4);
    assert(size(ktraj, 4) == size(senses, 5));

    ktraj = reshape(ktraj, [], NPhases, Nshots, 3);
    tic
    kt = squeeze(ktraj(:,:,1,:));
    E  = xfm_NUFFT([im_size, NPhases], senses(:,:,:,:,1), [], kt, 'wi', 1)
    Es = repmat(E, [Nshots, 1]);
    for ii = 1:Nshots
        tic
        
        kt = squeeze(ktraj(:,:,ii,:));
        Es(ii) = xfm_NUFFT([im_size, NPhases], senses(:,:,:,:,ii), [], kt, 'wi', 1);
        t1 = toc; fprintf('shot %d: %f s\n', ii, t1);
    end
    t=toc; fprintf('precal_E_sens: %f s\n', t);
end