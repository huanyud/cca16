function plot_tour(tour, node, rwd, BGT, figureBoundary) 
% Modified based on the original code by Jonas Lundgren <splinefit@gmail.com> 2012

% Plot TSP tour
x = node(tour,1);
x = [x;x(1)];
y = node(tour,2);
y = [y;y(1)];
plot(x,y,'r',x,y,'k.')
grid on; hold on

if nargin < 3
    figureBoundary = 100;
end
axis([0 figureBoundary 0 figureBoundary])

% Add title: total cost and reward of the tour
tourCost = 0;
for ii = 1:length(tour)
    if ii == length(tour)
        tourCost = tourCost + get_edge_weight(node(tour(ii),:), node(tour(1),:));
    else
        tourCost = tourCost + get_edge_weight(node(tour(ii),:), node(tour(ii+1),:));
    end
end
tourReward = sum(rwd(tour));
if size(node,2) == 3
    hasNodeCost = 1;
else
    hasNodeCost = 0;
end
str = sprintf('Reward: %g; Tour cost: %g; Budget: %g; hasNodeCost: %d', tourReward, tourCost, BGT, hasNodeCost);
title(str,'fonts',12)

% Plot all points
for k = 1:size(node, 1)
    str = sprintf(' %d', k);
    text(node(k,1), node(k,2), str);
    plot(node(k,1), node(k,2), 'k.');
end