% Calls a system command after first echoing it and printing the result to
% the screen and also printing any resulting messages
function tosystem(cmd)

% Echo the command (so wildcards etc. are replaced) then display the result
[~,cmd_msg] = system(['echo ' cmd]);
disp(cmd_msg);

% Run the command
%[~,msg] = system(cmd,'-echo'); % NB. This works on mac but not 
%[~,msg] = system(cmd);  

% Display any output/error messages
%disp(msg);

% Run using an alternative call which forces output to be displayed
builtin('system',cmd);