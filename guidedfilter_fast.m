function q = guidedfilter_fast(I, p, r, eps)
%   GUIDEDFILTER   O(1) time implementation of guided filter.
%
%   - guidance image: I (should be a gray-scale/single channel image)
%   - filtering input image: p (should be a gray-scale/single channel image)
%   - local window radius: r
%   - regularization parameter: eps

if ~isa(I,'single')
    I = single(I);
end
if ~isa(p,'single')
    p = single(p);
end

mean_I = convBox(I, r);
mean_p = convBox(p, r);
mean_Ip = convBox(I.*p,r);
cov_Ip = mean_Ip - mean_I .* mean_p; % this is the covariance of (I, p) in each local patch.

mean_II = convBox(I.*I, r);
var_I = mean_II - mean_I .* mean_I;

a = cov_Ip ./ (var_I + eps); % Eqn. (5) in the paper;
b = mean_p - a .* mean_I; % Eqn. (6) in the paper;

mean_a = convBox(a, r);
mean_b = convBox(b, r);

q = mean_a .* I + mean_b; % Eqn. (8) in the paper;

end