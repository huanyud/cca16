function [node, rwd, BGT] = read_ChaoGolden_dataset(fileName)

fileID = fopen(fileName, 'r');

% Read number of nodes
numOfNodes = textscan(fileID, 'n %d');
numOfNodes = numOfNodes{1};

% Read number of UAVs
numOfUAV = textscan(fileID, 'm %d');
numOfUAV = numOfUAV{1};

% Read budget (BGT)
BGT = textscan(fileID, 'tmax %f');
BGT = BGT{1};

% Read both node positions and rewards
nodeAndRwd = textscan(fileID, '%f %f %f');
nodeAndRwd = cell2mat(nodeAndRwd);

% Extract node
node = nodeAndRwd(:, 1:2);

% Extract reward
rwd = nodeAndRwd(:, 3);

% Close file
fclose(fileID);