function thisname = find_params_name( thisp, param_range, param_range_name )
%UNTITLED3 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��

A = find(thisp <= param_range);
thisname = param_range_name{A(1)};

end

