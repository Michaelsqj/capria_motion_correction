function split_sens(sensname)
    cd ..
    include_path();
    cd subspace_utils
    sensname = char(sensname)
    load(sensname, 'sens');
    sens_real = real(sens);
    sens_imag = imag(sens);
    save_avw(sens_real, [sensname '_real'], 'd', [1 1 1 1]);
    save_avw(sens_imag, [sensname '_imag'], 'd', [1 1 1 1]);
    disp([sensname '_real'])
    disp([sensname '_imag'])
end