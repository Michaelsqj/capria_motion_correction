function combine_sens_complex(sens_real,sens_imag,savepath)
    cd ..
    include_path();
    cd subspace_utils
    [img1,~,~,~,~] = read_avw(sens_real);
    [img2,~,~,~,~] = read_avw(sens_imag);
    sens = img1 + 1i*img2;
    save(savepath, 'sens');
%     delete(sens_real)
%     delete(sens_imag)
end