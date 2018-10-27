function [tforms,centerImageIndex,outImg] = calculateTransform(imageData, overlapIndex,...
    orientation)
% calibration scheme for the camera 
% this function will calibrate series of images taken by the camera
% to produce a transform mapping and an overall output images 

% user input: 
% imageData: sets of images 
% overlapIndex: overlapped pixels between images 
% orientation: 1 for image overlap along x axis, 2 for image overlap
% along y axis
% user also need to identify points between section of image data for each 
% comparsion 
% once this calibration finish, the same transformation can be used for
% the same scanning pattern by the same camera 

numImage = numel(imageData.Files); 
% create comparsion section 
numTwoSec = numImage-2; 
comparData = cell(numTwoSec*2+2,1);
indexCompData = 2;

for i = 1: numImage
    currentImg = readimage(imageData,i);
    if orientation == 1
        % images overlap along x axis 
        if i == 1 
            comparData{1} = currentImg(:,end-overlapIndex:end);
        elseif  i == numImage
            comparData{indexCompData} = currentImg(:,1:overlapIndex);
        else 
            comparData{indexCompData } = currentImg(:,1:overlapIndex);
            comparData{indexCompData +1} = currentImg(:,end-overlapIndex:end);
            indexCompData = indexCompData +2;
        end 
    elseif orientation == 2 
        % images overlap along y axis 
        if i == 1
            comparData{1} = currentImg(end-overlapIndex:end,:);
        elseif i == numImage
            comparData{numImage} = currentImg(1:overlapIndex,:);
        else 
            comparData{indexCompData } = currentImg(1:overlapIndex,:);
            comparData{indexCompData +1} = currentImg(end-overlapIndex:end,:);
            indexCompData = indexCompData +2;
        end
    end 
end

indexCompData = 1;
tforms(numImage) = projective2d(eye(3));
% start initiate comparsion by asking user input for point pair 
for i = 2: numImage 
    fix = comparData{indexCompData}; 
    move = comparData{indexCompData+1}; 
    indexCompData = indexCompData+2; 
    [move_points,fix_points] = cpselect(move,fix,'Wait',true);  
    % select the fit option 'projective', 'affine', 'similarity', 
    % 'nonreflectivesimilarity','lwm', 'pwl', 'polynomial'
    tforms(i) = fitgeotrans(move_points,fix_points,'projective');
    tforms(i).T = tforms(i).T * tforms(i-1).T;
end 


%% Correct the transform in relative to the middle image
% correct the transform in relative to the middle image and for each
% comparsion 
imageSize = size(currentImg);% assume all image have the same size 
% give the spatial output limit of the transform 
for i = 1: numel(tforms)
    if orientation == 1
    [xlim(i,:),ylim(i,:)] = outputLimits(tforms(i),[1 imageSize(2)],...
        [1 imageSize(1)]); 
    else 
    [xlim(i,:),ylim(i,:)] = outputLimits(tforms(i),[1 imageSize(1)],...
        [1 imageSize(2)]); 
    end 
end 

midXlim = mean(xlim,2); 
[~,idx] = sort(midXlim); 
centerIndex = floor((numel(tforms)+1)/2); 
centerImageIndex = idx(centerIndex);

tformInv = invert(tforms(centerImageIndex)); 
for i = 1:numel(tforms)
    tforms(i).T = tforms(i).T * tformInv.T; 
end 
%% stitch images 

outImg = PanaromaStitch(imageData,overlapIndex,orientation,...
    tforms,centerImageIndex); 

end 