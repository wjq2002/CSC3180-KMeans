function [mask,pos2,subsimage]=Cut(simage,bimage)

f1=figure;
imshow(simage);%展示源图片
h1=imfreehand;%手动选取
fcn= makeConstrainToRectFcn('imfreehand',get(gca,'XLim'),get(gca,'Ylim'));%限制选取范围
setPositionConstraintFcn(h1,fcn);%应用限制
pos1=wait(h1);%等待选取
mask=double(createMask(h1));%生成蒙版
close(f1);

cc=regionprops(mask,'BoundingBox');%获得蒙版最小包含矩形数据
mask=imcrop(mask,cc(1).BoundingBox);%裁剪蒙版为原蒙版最小包含矩形
mask(1,:)=0;mask(end,:)=0;mask(:,1)=0;mask(:,end)=0;%蒙版边框一像素改为空
subsimage=imcrop(simage,cc(1).BoundingBox);%裁剪源图片为原蒙版最小包含矩形

f2=figure;
imshow(bimage);%展示背景图片
h2=imrect(gca,[1 1 size(mask,2) size(mask,1)]);%手动选取蒙版大小矩形选区
setFixedAspectRatioMode(h2,1);%限制矩形选区长宽比例
fcn=makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'Ylim'));%限制矩形选区范围
setPositionConstraintFcn(h2,fcn);%应用限制
pos2=wait(h2);%等待选取
close(f2);

mask=imresize(mask,[pos2(4) pos2(3)]);%调整蒙版为矩形选区大小
mask=mask>0;%将蒙版内非正数数像素点改为0，正数数像素点改为1

pos2(3:4)=pos2(3:4)-1;
pos2=int32(pos2);%调整矩形选区

