function ReImg = PanaImgStit(img1,img2,tol)
% img1: first image  
% img2: second image 
% img1 in relative to img2
% overlap: tolerance of the overlapping area in pixel 
one = rgb2gray(img1);
two = rgb2gray(img2);

one = imresize(one, [1200 600]);two = imresize(two, [1200 600]);

% crop the over lapping region of two imaging 
one1 = one(:,end-tol:end); 
two1 = two(:,1:tol); 

% saving the patch of the second images 
patchSize = 10; 
numPatch = size(two1,2)/patchSize;
for i = 0: numPatch-1 
    for j = 1: patchSize 
        number(:,j) = two1(:,(i*patchSize)+j); 
    end
    two_patch{i+1} = number; 
end 

% perform correlation, comparing rows from the first image 

for i = 1: numel(two_patch)
    for j = 0:numPatch-1 
        for k = 1:patchSize 
            one_patch(:,k) = one1(:,(j*patchSize)+k); 
        end
        result(i,j+1) = corr2(one_patch, two_patch{i}); 
    end 
end 

% calculate the maximum correlation for patch of two and one 
[value index] = max(max(result));
[two_patchNum one_patchNum]=find(result ==value); 

index_one = size(one,2)-(numPatch-one_patchNum)*patchSize ;
index_two= (two_patchNum-1)*patchSize+1;

image1 = imresize(img1, [1200 600]);image2 = imresize(img2, [1200 600]);
length = size(image2,2)-index_two;
ReImg(:,:,:) = image1(:,1:index_one,:); 
ReImg(:,index_one+1:index_one+length+1,:) = image2(:,index_two:end,:);

        
end 