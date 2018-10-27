function outImg = PanaromaStitch(imageData,overlapIndex,orientation,...
    tforms,centerImageIndex)
%% Peform panaroma stitching 
% imageData: set of images 
% overlapIndex: number of pixels that overlapped between each image 
% orientation: image get stitch vertically or horizontally 
% tforms: transformation of sequential images 
%% preliminary 
numImg = numel(imageData); 
I = readimage(imageData,1);
imageSize = size(I); 
% Initial output image 
outImg = []; 
%% stitch images
if orientation ==1 
    for i = 1: numImg
        % start from first image
        I = readimage(imageData,i);
        fix_ref = imref2d(size(readimage(imageData,centerImageIndex)));
        imgCorr = imwarp(I,tforms(i),'OutputView',fix_ref);
        imgCorrCrop = imgCorr(:,1:overlapIndex,:); % may need to fix this 
        outImg = [outImg imgCorrCrop];
    end
else 
    for i = 1: numImg
        % start from first image
        I = readimage(imageData,i);
        fix_ref = imref2d(size(readimage(imageData,centerImageIndex)));
        imgCorr = imwarp(I,tforms(i),'OutputView',fix_ref);
        imgCorrCrop = imgCorr(1:overlapIndex,:,:); % may need to fix this 
        outImg = [outImg; imgCorrCrop];
    end

end
figure
imshow(outImg)
end 
