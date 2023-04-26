clc
clear

addpath image
simage=im2double(imread('b5ceb93f2fce522cda157c74a0484cc3.jpeg'));
bimage=im2double(imread('Œ¢–≈Õº∆¨_20210929092246.jpg'));
[mask,pos,subsimage]=Cut(simage,bimage);
subbimage=imcrop(bimage,pos);
out=Pie(subbimage,subsimage,mask,1);
bimage(pos(2):pos(2)+pos(4),pos(1):pos(1)+pos(3),:)=out;
figure;imshow(bimage);
out=Pie(subbimage,subsimage,mask,0);
bimage(pos(2):pos(2)+pos(4),pos(1):pos(1)+pos(3),:)=out;
figure;imshow(bimage);