function tourCost = get_tour_cost(node, tour)

tourCost = 0;
for ii = 1:length(tour)
    if ii == length(tour)
        tourCost = tourCost + get_edge_weight(node(tour(ii),:), node(tour(1),:));
    else
        tourCost = tourCost + get_edge_weight(node(tour(ii),:), node(tour(ii+1),:));
    end
end