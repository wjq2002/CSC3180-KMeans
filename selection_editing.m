clc
clear

addpath image
img = im2double(imread('004.png'));
img1 = im2double(imread('004.png'));
img2 = im2double(imread('004.png'));
img3 = im2double(imread('004.png'));
img4 = im2double(imread('9d827.jpeg'));

[mask,pos,subimage]=part_selection(img);

out1= mpie(subimage,mask,'color');

img1(pos(2):pos(2)+pos(4),pos(1):pos(1)+pos(3),:)=out1;%�����滻

out2= mpie(subimage,mask,'none');

img2(pos(2):pos(2)+pos(4),pos(1):pos(1)+pos(3),:)=out2;%�����滻

out3= mpie(subimage,mask,'flatten');

img3(pos(2):pos(2)+pos(4),pos(1):pos(1)+pos(3),:)=out3;%�����滻

figure;imshow([img1 img2 img3]);

Img=img4;
%Ϊƴ�ӽ����߽�����
Img(1,:,:)=0.5*(Img(1,:,:)+Img(end,:,:));
Img(end,:,:)=Img(1,:,:);
Img(:,1,:)=0.5*(Img(:,1,:)+Img(:,end,:));
Img(:,end,:)=Img(:,1,:);

mask = zeros(size(Img,1),size(Img,2));
mask(2:end-1,2:end-1)=1;

out4 = mpie(Img, mask,'tiling',img4);
figure;imshow([img4 img4;img4 img4])
figure;imshow([out4 out4;out4 out4])


