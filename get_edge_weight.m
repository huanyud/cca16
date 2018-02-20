function value = get_edge_weight(nodeA, nodeB)

if size(nodeA, 2) == 2
    value = sqrt((nodeA(1)-nodeB(1))^2 + (nodeA(2)-nodeB(2))^2);
else if size(nodeA, 2) == 3
        value = sqrt((nodeA(1)-nodeB(1))^2 + (nodeA(2)-nodeB(2))^2) +  (1/2) * (nodeA(3) + nodeB(3));
    end
end
