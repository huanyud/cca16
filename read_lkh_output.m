function tspTour = read_lkh_output(sel)

tspTour = zeros(1, length(sel));

fileID = fopen('lkhOutput.txt', 'r');

% Skip a few lines
linesToSkip = 6;
for ii = 1:linesToSkip
    fgetl(fileID);
end

% Read file starting from the tour section
for ii = 1: length(sel)
     str = fgetl(fileID);
     tspTour(ii) = str2num(str);
end
fclose(fileID);

tspTour = sel(tspTour);