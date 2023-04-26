function out=mpie(image,mask,order,simage)

%order:
%   "none"  ƽ����� 
%   "flatten"   ȥ����
%   "color"     ������ɫ
%   "tiling"    �޷�ƴ��

out=image;%�����ʼ��
num=nnz(mask);%�ǿ����ظ��������ںϲ���
[m,n]=size(mask);%����ɰ泤��

map=zeros(m,n);%�����ɰ��С�Ŀվ���
cnt=0;%��˳�����������أ������Ҫ�ں����ص�
for i=1:m
    for j=1:n
        if mask(i,j)==1
            cnt=cnt+1;
            map(i,j)=cnt;
        end
    end
end

k = {[1 -1 0],[0 -1 1],[1;-1;0],[0;-1;1]};%�ĸ�����Ķ���������˹�����˲���
lap=0;
switch order
    case 'none'
        lap = zeros(size(image));
    case 'flatten'
        for d=1:4
            grad = imfilter(image, k{d});
            grad(abs(grad)<0.02)=0;
            lap = lap+grad;
        end
    case 'color'%����ı��ݶ�ʵ�ֵ�ɫ
        for d=1:4
            grad = imfilter(image, k{d});
            grad(:,:,1)=grad(:,:,1)*1.5;
            grad(:,:,2)=grad(:,:,2)/2;
            grad(:,:,3)=grad(:,:,3)/4;
            lap = lap+grad;
        end
    case 'tiling'
        for d=1:4
            grad = imfilter(simage, k{d});
            lap = lap+grad;
        end
    otherwise
        error('smart ass!');
end

coeffNum=5;
A=spalloc(num,num,num*coeffNum);%����ϡ��ϵ������

B=zeros(num,size(image,3));%�����洢ɢ���ÿվ���


cnt = 0;
for i=2:m-1
    for j=2:n-1
        if mask(i,j)==1
            cnt = cnt+1;
            A(cnt,cnt) = 4;
             
            if mask(i-1,j)==0%��߽�
                B(cnt,:) = reshape(image(i-1,j,:),[],1);
            else
                A(cnt,map(i-1,j)) = -1;
            end
            
            if mask(i+1,j)==0%�ұ߽�
                B(cnt,:) = B(cnt,:)+reshape(image(i+1,j,:),[],1)';
            else
                A(cnt,map(i+1,j)) = -1;
            end
              
         
            if mask(i,j-1)==0%�±߽�
                B(cnt,:) = B(cnt,:)+reshape(image(i,j-1,:),[],1)';
            else
                A(cnt,map(i,j-1)) = -1;
            end
            
          
            if mask(i,j+1)==0%�ϱ߽�
                B(cnt,:) = B(cnt,:)+reshape(image(i,j+1,:),[],1)';
            else
                A(cnt,map(i,j+1)) = -1;
            end
            
       
            B(cnt,:)=B(cnt,:)-reshape(lap(i,j,:),[],1)';%���ɢ��
        end
    end
end

X=A\B;%�Ⲵ�ɷ���

for cnt=1:size(X,1)%������ͼ��
    [idx_x,idx_y]=find(map==cnt);
    out(idx_x,idx_y,:)=reshape(X(cnt,:),1,1,3);
end

