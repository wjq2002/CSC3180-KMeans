function [mask,pos2,subsimage]=Cut(simage,bimage)

f1=figure;
imshow(simage);%չʾԴͼƬ
h1=imfreehand;%�ֶ�ѡȡ
fcn= makeConstrainToRectFcn('imfreehand',get(gca,'XLim'),get(gca,'Ylim'));%����ѡȡ��Χ
setPositionConstraintFcn(h1,fcn);%Ӧ������
pos1=wait(h1);%�ȴ�ѡȡ
mask=double(createMask(h1));%�����ɰ�
close(f1);

cc=regionprops(mask,'BoundingBox');%����ɰ���С������������
mask=imcrop(mask,cc(1).BoundingBox);%�ü��ɰ�Ϊԭ�ɰ���С��������
mask(1,:)=0;mask(end,:)=0;mask(:,1)=0;mask(:,end)=0;%�ɰ�߿�һ���ظ�Ϊ��
subsimage=imcrop(simage,cc(1).BoundingBox);%�ü�ԴͼƬΪԭ�ɰ���С��������

f2=figure;
imshow(bimage);%չʾ����ͼƬ
h2=imrect(gca,[1 1 size(mask,2) size(mask,1)]);%�ֶ�ѡȡ�ɰ��С����ѡ��
setFixedAspectRatioMode(h2,1);%���ƾ���ѡ���������
fcn=makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'Ylim'));%���ƾ���ѡ����Χ
setPositionConstraintFcn(h2,fcn);%Ӧ������
pos2=wait(h2);%�ȴ�ѡȡ
close(f2);

mask=imresize(mask,[pos2(4) pos2(3)]);%�����ɰ�Ϊ����ѡ����С
mask=mask>0;%���ɰ��ڷ����������ص��Ϊ0�����������ص��Ϊ1

pos2(3:4)=pos2(3:4)-1;
pos2=int32(pos2);%��������ѡ��

