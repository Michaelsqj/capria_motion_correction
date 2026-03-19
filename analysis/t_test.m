function t_test(r1, r2)
    % r1, r2  [n x p]
    r1_mean = mean(r1, 1);
    r2_mean = mean(r2, 1);

    % Step 1: Fisher r-to-z transformation
    z_set1 = atanh(r1_mean);
    z_set2 = atanh(r2_mean);

    % Step 2: Compute the differences
    z_diff = z_set2 - z_set1;

    % Step 3: Calculate the mean and standard deviation of the differences
    mean_diff = mean(z_diff);
    std_diff = std(z_diff);  % Standard deviation

    % Step 4: Perform a paired t-test
    [n, ~] = size(z_diff);  % Number of observations
    t_statistic = mean_diff / (std_diff / sqrt(n));
    p_value = 2 * (1 - tcdf(abs(t_statistic), n - 1));  % Two-tailed t-test

    % Display results
    fprintf('T-statistic: %.4f\n', t_statistic);
    fprintf('P-value: %.4f\n', p_value);

    % Interpretation
    if p_value < 0.05
        disp('The improvement in correlation coefficients is statistically significant.');
    else
        disp('The improvement in correlation coefficients is not statistically significant.');
    end

end