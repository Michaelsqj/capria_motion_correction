function h = tight_subplot(m, n, p, gap, marg_h, marg_w)
% tight_subplot creates subplot axes with adjustable gaps and margins
% Usage: h = tight_subplot(m, n, p, gap, marg_h, marg_w)
%
% Parameters:
%   m: number of rows
%   n: number of columns
%   p: panel number (optional, default: 1)
%   gap: gap between subplots [gap_h gap_w] in normalized units (0...1)
%   marg_h: margins in height [top bottom] in normalized units (0...1)
%   marg_w: margins in width [left right] in normalized units (0...1)
%
% Returns:
%   h: array of subplot axes handles

if nargin < 3; p = 1; end
if nargin < 4 || isempty(gap); gap = 0.01; end
if nargin < 5 || isempty(marg_h); marg_h = 0.05; end
if nargin < 6 || isempty(marg_w); marg_w = 0.05; end

if numel(gap) == 1
    gap = [gap gap];
end
if numel(marg_w) == 1
    marg_w = [marg_w marg_w];
end
if numel(marg_h) == 1
    marg_h = [marg_h marg_h];
end

% Calculate axes positions
axh = (1 - sum(marg_h) - (m-1)*gap(1)) / m;
axw = (1 - sum(marg_w) - (n-1)*gap(2)) / n;

py = 1 - marg_h(1) - axh;
h = zeros(m*n, 1);
ii = 0;
for i = 1:m
    px = marg_w(1);
    for j = 1:n
        ii = ii + 1;
        if ii < p; continue; end
        h(ii) = axes('Position', [px py axw axh]);
        px = px + axw + gap(2);
    end
    py = py - axh - gap(1);
end
end