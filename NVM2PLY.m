% ======================================================================== %
% Goal: transform .NVM to .PLY extension
% ======================================================================== %

clear
clc

%% configuration
% input NVM file name
NVMPool = 'LH1_for_vsfm/LH1.nvm';

% output PLY file name
outputPLYname = 'LH1_for_vsfm/LH1.ply';

fileID = fopen(NVMPool);
fgetl(fileID);  % read string "NVM_V3"
fgetl(fileID);  % read a blank space

% read and skip <List of cameras> section
GlobalCamCnt = str2double(fgetl(fileID));  % # camera pose
for i=1:GlobalCamCnt
    fgetl(fileID);
end
fgetl(fileID);  % read a blank space

% extract <List of points>
NbPts = str2double(fgetl(fileID)); % # points
infoPool = zeros(NbPts, 6);
for i=1:NbPts
    % <point> = <X Y Z> <R G B> <# measurements> <List of measurements>
    % <measurement> = <Image index> <0-based Feature index> <XY>

    % <X Y Z> <R G B> 
    infoPool(i, :) = fscanf(fileID, '%f %f %f %d %d %d', [6 1])';
    fgetl(fileID); % skip the rest information
end

% https://www.mathworks.com/help/vision/ref/pcshow.html#buslb5n-1-C
% specify the same color for all points or a different color for each point. 
% when you set C to single or double, the RGB values range between [0, 1]. 
% when you set C to `uint8`, the values range between [0, 255].
pc = pointCloud(infoPool(:,1:3), 'Color', uint8(infoPool(:,4:6)));
pcwrite(pc, outputPLYname);  
disp('.NVM to .PLY extension is finished.');
