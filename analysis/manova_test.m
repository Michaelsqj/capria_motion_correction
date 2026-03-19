function [tbl]=manova_test(r1, r2)

    % Example data: Replace these with your actual data
    % data is a 3D array where dimensions are subjects x methods x time points
    [n, t] = size(r1);
    y = zeros(n, 2, t);
    y(:, 1, :) = atanh(r1);
    y(:, 2, :) = atanh(r2);
    
    % Define group labels for an anova test using meshgrid
    % [Method,SubjNo,Time] = meshgrid(1:size(y,2),1:size(y,1),1:size(y,3));
    [SubjNo, Method, Time] = ndgrid(1:size(y,1), 1:size(y,2), 1:size(y,3));
    
    % Run the multi-way anova
    [pAnova,tbl,stats] = anovan(y(:),{SubjNo(:),Method(:),Time(:)},'model','interaction','varnames',{'Subj','Method','Time'});
        
    % Post-hoc paired t-test of method only
    % z1 = z(:,1,jj,:); z2 = z(:,2,jj,:);
    z1 = atanh(r1); z2=atanh(r2);
    [h,pTtest]=ttest2(z1(:),z2(:));    
    
    % Look at timepoints individually:
    for kk = 1:t
        [h,pTtestFrame(kk)]=ttest2(z1(:,kk),z2(:,kk));        
    end    

    % Show results
    % disp(['Results for ' Modalities{1} ':'])
    disp(['pAnova = ' num2str(pAnova(:)')])
    disp(['pTtest = ' num2str(pTtest)])
    disp(['pTtestFrame = ' num2str(pTtestFrame)])
end