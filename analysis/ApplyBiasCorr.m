% Apply a bias field determined by FAST/other means to dynamic angio data
%
% out = ApplyBiasCorr(Ims, Bias)

function out = ApplyBiasCorr(Ims, Bias)

  s = size(Ims);
  out = Ims ./ repmat(Bias,[1 1 s(3:end)]);
