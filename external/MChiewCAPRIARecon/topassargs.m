function out = topassargs(opts,defaults,printdefaults,errorwithunknownopts,prefix)

if nargin < 3; printdefaults = false; end
if nargin < 4; errorwithunknownopts = true; end
if nargin < 5; prefix = ''; end

% Initialise the output with the defaults
out = defaults;

% If passed an empty input, just return the defaults, which have already
% been assigned
if isempty(opts)
    %opts = struct([]); 
    %clear opts
    disp('Using default values for all options')
    disp(out)
    return
end

% Assign the value in opts if present
params = fieldnames(defaults);
NoParamsAssigned = 0;
for ii = 1:length(params)
    
    % If the field is a struct, call the function recursively
    if isstruct(eval(['out.' params{ii}]))
        %disp(['Descending into struct option ' params{ii}])
        if ~isfield(opts, params{ii}) % If there is no field, pass an empty value
            eval(['opts.' params{ii} ' = [];'])
        end
        if isempty(prefix)
            nextprefix = [params{ii} '.'];
        else
            nextprefix = [prefix '.' params{ii} '.'];
        end
        eval(['out.' params{ii} ' = topassargs(opts.' params{ii} ', out.' params{ii} ',printdefaults,errorwithunknownopts,nextprefix);']);
    
    else % Not a struct option
        if isfield(opts, params{ii}) % If the option is present in the input, assign it
            eval(['out.' params{ii} ' = opts.' params{ii} ';'])
            NoParamsAssigned = NoParamsAssigned + 1;
        
        else % Need to pass in the default value
            
            defaultval = eval(['defaults.' params{ii}]);
            if (size(defaultval,1) > 1) || (length(defaultval)>50)
                str = 'Too big to display';
            else
                str = num2str(defaultval);
            end
            
            if printdefaults
                disp(['Using default value for parameter ' prefix params{ii} ': ' str]);
            end
        end
  end
end

% Check no options were provided that were not present in defaults
if errorwithunknownopts
    optfieldnames = fieldnames(opts);
%     if length(optfieldnames) ~= NoParamsAssigned
%         disp('Some options provided were not present in the defaults:')
%         for ii = 1:length(optfieldnames)
%             if ~isfield(defaults,optfieldnames{ii})
%                 disp(optfieldnames{ii})
%             end
%         end
%         error('Cannot assign options - exiting!')
%     end

    % Previous approach fails with struct options - redo here
    Idx = [];
    for ii = 1:length(optfieldnames)
        if ~isfield(defaults,optfieldnames{ii})
            Idx = [Idx ii];
        end
    end
    
    if ~isempty(Idx)
        disp('Some options provided were not present in the defaults:')
        for jj = 1:length(Idx)
            disp([prefix optfieldnames{jj}])
        end
        error('Cannot assign options - exiting!')
    end
end