function include_path(inv)
    root_dir = fileparts(mfilename('fullpath'));
    external_dir = fullfile(root_dir, 'external');

    paths = {
        fullfile(external_dir, 'irt', 'nufft')
        fullfile(external_dir, 'irt', 'utilities')
        fullfile(external_dir, 'irt', 'systems')
        genpath(fullfile(external_dir, 'irt', 'mex'))
        fullfile(external_dir, 'minTimeGradient', 'mex-interface')
        fullfile(external_dir, 'encoding_transforms')
        fullfile(external_dir, 'fsl', 'etc', 'matlab')
        fullfile(external_dir, 'mapVBVD')
        fullfile(external_dir, 'matlab')
        genpath(root_dir)
    };

    legacy_path = fullfile(external_dir, 'MChiewCAPRIARecon');
    if exist(legacy_path, 'dir')
        rmpath(legacy_path);
    end

    for i = 1:numel(paths)
        p = paths{i};
        if isempty(p)
            continue;
        end

        if nargin < 1 || inv == 0
            addpath(p);
        else
            rmpath(p);
        end
    end
end
    % fullfile(fileparts(root_dir), 'spirit3d')...
    % genpath(fullfile(fileparts(root_dir), 'ESPIRiT'))...
