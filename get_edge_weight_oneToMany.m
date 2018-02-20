function result = get_edge_weight_oneToMany(nodeOne, nodeMultiple)

M = size(nodeMultiple,1);
result = zeros(M,1);
for ii = 1:M
    result(ii) = get_edge_weight(nodeOne, nodeMultiple(ii,:));
end
