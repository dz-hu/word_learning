function thisname = find_params_name( thisp, param_range, param_range_name )
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明

A = find(thisp <= param_range);
thisname = param_range_name{A(1)};

end

