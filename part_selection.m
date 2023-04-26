function [mask,pos,subimage]=part_selection(image)

f1=figure;
imshow(image);%展示源图片
h1=imfreehand;%手动选取
fcn= makeConstrainToRectFcn('imfreehand',get(gca,'XLim'),get(gca,'Ylim'));%限制选取范围
setPositionConstraintFcn(h1,fcn);%应用限制
position=wait(h1);%等待选取
mask=double(createMask(h1));%生成蒙版
close(f1);

cc=regionprops(mask,'BoundingBox');%获得蒙版最小包含矩形数据
mask=imcrop(mask,cc(1).BoundingBox);%裁剪蒙版为原蒙版最小包含矩形
mask(1,:)=0;mask(end,:)=0;mask(:,1)=0;mask(:,end)=0;%蒙版边框一像素改为空

pos(1:2)=int32(min(position,[],1));%获取最小包含矩形左上角坐标
pos(3:4)=max(position,[],1)-min(position,[],1);%获取最小包含矩形长宽

subimage = imcrop(image,pos);

mask = imresize(mask,[pos(4)+1 pos(3)+1]);
mask = mask>0;
