function hotelling_test(r1, r2)
    % r1, r2 are both [n x p], n samples with p variables

    diff = r1 - r2;
    mean_diff = mean(diff);
    cov_diff = cov(diff);

    [n, p] = size(r1);
    T2 = n * (mean_diff / cov_diff * mean_diff');

    % Step 6: Calculate the F-statistic
    F = (n - p) / (p * (n - 1)) * T2;

    % Step 7: Calculate the p-value
    p_value = 1 - fcdf(F, p, n - p);

    % Display results
    fprintf('Hotellings T-squared statistic: %.4f\n', T2);
    fprintf('F-statistic: %.4f\n', F);
    fprintf('P-value: %.4f\n', p_value);

    % Interpretation
    if p_value < 0.05
        disp('The difference in correlation coefficients is statistically significant.');
    else
        disp('The difference in correlation coefficients is not statistically significant.');
    end
end