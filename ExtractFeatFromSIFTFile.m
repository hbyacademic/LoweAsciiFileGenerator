% ======================================================================== %
%             extract feature descriptors from .sift files
%       
%       - .nvm file should contain ONLY ONE model
%       - .sift stores ORB feature descriptors
%       - default image file entension used in .nvm is 'jpg'
%       - NVMfileName: NVM file name
%       - NVMImgDir: directory to images
%       - gridStep: grid step used in downsample (for speedup)
%       - OutputPath: path to output file
% ======================================================================== %

clear
clc

NVMfileName = 'path/to/your/NVM/file/xxx.nvm';
NVMImgDir = 'path/to/your/image/directory/';
gridStep = 10;
OutputPath = '';

% load N-view match file
fileID = fopen(NVMfileName,'r');

% NVM file format
% <# camera> <list of camera>
% <# 3D points> <list of points>
% <camera> = <filename> <focal length> <quaternion WXYZ> <camera center> <radial distortion> 0
% <point> = <XYZ> <RGB> <# measurement> <list of measurements>
% <measurement> = <image index> <feature index> <xy>
% note that image index and feature index are 0-based not 1-based!

fgetl(fileID); % read string "NVM_V3"
fgetl(fileID); % read a blank line
camCnt = str2double(fgetl(fileID)); % # camera
imgName = cell(camCnt,1);
for i = 1:camCnt
    fullName = fgetl(fileID); % getline
    tmpName = extractBefore(fullName, ".jpg"); % jpg file extension
    imgName{i} = tmpName;
end

fgetl(fileID); % read a blank line
ptCnt = str2double(fgetl(fileID)); % # 3D points
RawData = fscanf(fileID, '%f');
pinfo = zeros(ptCnt,2); % <image index> <feature index>
sp = 0;
for i = 1:ptCnt
    sp = sp+6+1; % x y z r g b #ORBfeatures
    % extract `the first` <image index> <feature index>
    % a 3d point typically contains more than one feature
    % here, we only consider the first one 
    pinfo(i,1) = RawData(sp+1);
    pinfo(i,2) = RawData(sp+2);

    % each "4" => <image index> <feature index> <x y>
    sp = sp+RawData(sp,1)*4;
end
fclose(fileID);

% extract feature descriptors from xxx.sfit
% 1+gridStep*N <= ptCnt
% N <= (ptCnt-1)/gridStep
% N = fix((ptCnt-1)/gridStep)
% # bwtween 1 and ptCnt = N+1
N = fix((ptCnt-1)/gridStep);
descp = zeros(N+1, 128);
idx = 1;
for i = 1:gridStep:ptCnt
    path = strcat(NVMImgDir,(imgName{pinfo(i,1)+1}),'.sift');
    fileID = fopen(path, 'r');
    SiftData = fscanf(fileID, '%f');
    
    % 2 => #features and 128
    % "+1" => from 0-based to 1-based
    % "-1" => points to the previous block (<x y scl ori> 128D)
    % 4+128 => <y x scl ori> and 128D 
    sp = 2+((pinfo(i,2)+1)-1)*(4+128);
    descp(idx, 1:32) = SiftData(sp+4+1:sp+4+32);
    fclose(fileID);
    idx = idx + 1;
    disp(i);
end
% save(strcat(OutputPath,'DescriptorG.mat'), 'descp');
