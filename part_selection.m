function [mask,pos,subimage]=part_selection(image)

f1=figure;
imshow(image);%չʾԴͼƬ
h1=imfreehand;%�ֶ�ѡȡ
fcn= makeConstrainToRectFcn('imfreehand',get(gca,'XLim'),get(gca,'Ylim'));%����ѡȡ��Χ
setPositionConstraintFcn(h1,fcn);%Ӧ������
position=wait(h1);%�ȴ�ѡȡ
mask=double(createMask(h1));%�����ɰ�
close(f1);

cc=regionprops(mask,'BoundingBox');%����ɰ���С������������
mask=imcrop(mask,cc(1).BoundingBox);%�ü��ɰ�Ϊԭ�ɰ���С��������
mask(1,:)=0;mask(end,:)=0;mask(:,1)=0;mask(:,end)=0;%�ɰ�߿�һ���ظ�Ϊ��

pos(1:2)=int32(min(position,[],1));%��ȡ��С�����������Ͻ�����
pos(3:4)=max(position,[],1)-min(position,[],1);%��ȡ��С�������γ���

subimage = imcrop(image,pos);

mask = imresize(mask,[pos(4)+1 pos(3)+1]);
mask = mask>0;
