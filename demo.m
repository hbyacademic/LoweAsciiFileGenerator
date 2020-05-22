% ======================================================================== %
% Goal: generate .sift (Lowe's ASCII format) 
%       of each image with ORB features for VisualSFM
%       
%       - Dir: directory to images
%       - pathToOutputSift: path to the output files (.sift)
% ======================================================================== %

clear
clc

imgDir = 'path/to/your/image/directory/';
pathToOutputSift = 'path/to/your/output/sift/file/';

S = dir(fullfile(imgDir,'*.jpg'));
for nbImg = 1:numel(S)
    
    % read images
    I = fullfile(imgDir, S(nbImg).name);
    I = imread(I);
    [~,~,nbOfColorChannels] = size(I);
    if(nbOfColorChannels == 3)
        I = rgb2gray(I);
    end
    
    % extract ORB features
    pts = detectORBFeatures(I);
    [features, valid_pts] = extractFeatures(I, pts);
    
    % output ORB descriptors
    outputName = extractBefore(S(nbImg).name, ".");
    fileID = fopen(strcat(pathToOutputSift,outputName,'.sift'),'w');
    fprintf(fileID, '%d 128\n', features.NumFeatures);
         
    for nbFeats = 1:features.NumFeatures
        % y x scale orientation (NOT x y scl ori)
        fprintf(fileID, ' %f %f %f %f\n', ...
            pts.Location(nbFeats,2), ...
            pts.Location(nbFeats,1), ...
            pts.Scale(nbFeats), ...
            pts.Orientation(nbFeats));
        
        % 128 Dimensional descriptor (d1,d2, ..., d128) with the norm of 512
        % that is the length of (d1,d2, ..., d128) = 1 
        % and then multiply each element di by 512 
        % as SIFT, you can refer to the output file named `tmp.key`
        % the output format is IMPORTANT!
        
        paddingZero = zeros(1, 128-32);
        
        % normalize to unit length
        ORBdescp = (double(features.Features(nbFeats,:)) ./ ...
        norm(double(features.Features(nbFeats,:))));
        descriptors = fix([ORBdescp, paddingZero] .* 512);
             
        for j = 1:128
             if mod(j,20) == 0 || j == 128
                fprintf(fileID, '%d\n', descriptors(j));
                
            else
                fprintf(fileID, '%d ', descriptors(j));
            end
        end
    end
    fclose(fileID);
    % disp(nbImg);
end