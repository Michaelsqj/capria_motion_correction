function par = parse_avscale(MAT_FILE, REF_FILE)
    %PARSE_AVSCALE Parse the avscale output file and return the 

    % Example command line avscale output, example stdouts :
    %
    % Rotation & Translation Matrix:
    % 0.999860 -0.007637 0.014861 0.394981 
    % 0.008053 0.999571 -0.028161 1.171794 
    % -0.014640 0.028277 0.999493 1.019311 
    % 0.000000 0.000000 0.000000 1.000000 

    % Rotation Angles (x,y,z) [rads] = -0.028168 -0.014862 -0.007638 

    % Translations (x,y,z) [mm] = 0.394981 1.171794 1.019311 

    % Scales (x,y,z) = 1.000000 1.000000 1.000000 

    % Skews (xy,xz,yz) = 0.000001 0.000001 0.000000 

    % Average scaling = 1.000000

    % Determinant = 1.000000
    % Left-Right orientation: preserved

    % Forward half transform =
    % 0.999965 -0.003871 0.007404 0.062516 
    % 0.003975 0.999893 -0.014097 1.336295 
    % -0.007349 0.014126 0.999873 -0.415979 
    % 0.000000 0.000000 0.000000 1.000000 

    % Backward half transform =
    % 0.999965 0.003975 -0.007349 -0.070882 
    % -0.003871 0.999893 0.014126 -1.330033 
    % 0.007404 -0.014097 0.999873 0.434301 
    % 0.000000 0.000000 0.000000 1.000000 

    [status,cmdout] = system(['avscale --allparams ', char(MAT_FILE), ' ', char(REF_FILE)])
    % Parse the output, extract Rotation Angles, Translations
    % example stdouts are as above
    [C, matches] = strsplit(cmdout, {'\n', '=', 'Rotation Angles (x,y,z) [rads]' , 'Translations (x,y,z) [mm]'}, ...
    'DelimiterType', 'RegularExpression', 'CollapseDelimiters', true);
    % C is a cell array of strings
    % matches is a cell array of strings
    [r,~]=strsplit(C{1,7},' ');
    rotation = [str2double(r{2}) str2double(r{3})  str2double(r{4})];
    [t,~]=strsplit(C{1,9},' ');
    translation = [str2double(t{2}) str2double(t{3}) str2double(t{4})];
    par = [rotation translation];
end