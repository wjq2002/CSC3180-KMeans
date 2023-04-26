function out=mpie(image,mask,order,simage)

%order:
%   "none"  平滑填充 
%   "flatten"   去纹理
%   "color"     调节颜色
%   "tiling"    无缝拼接

out=image;%输出初始化
num=nnz(mask);%非空像素个数，需融合部分
[m,n]=size(mask);%获得蒙版长宽

map=zeros(m,n);%生成蒙版大小的空矩阵
cnt=0;%按顺序填充待求像素，标记需要融合像素点
for i=1:m
    for j=1:n
        if mask(i,j)==1
            cnt=cnt+1;
            map(i,j)=cnt;
        end
    end
end

k = {[1 -1 0],[0 -1 1],[1;-1;0],[0;-1;1]};%四个方向的独立拉普拉斯算子滤波核
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
    case 'color'%随意改变梯度实现调色
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
A=spalloc(num,num,num*coeffNum);%建立稀疏系数矩阵

B=zeros(num,size(image,3));%建立存储散度用空矩阵


cnt = 0;
for i=2:m-1
    for j=2:n-1
        if mask(i,j)==1
            cnt = cnt+1;
            A(cnt,cnt) = 4;
             
            if mask(i-1,j)==0%左边界
                B(cnt,:) = reshape(image(i-1,j,:),[],1);
            else
                A(cnt,map(i-1,j)) = -1;
            end
            
            if mask(i+1,j)==0%右边界
                B(cnt,:) = B(cnt,:)+reshape(image(i+1,j,:),[],1)';
            else
                A(cnt,map(i+1,j)) = -1;
            end
              
         
            if mask(i,j-1)==0%下边界
                B(cnt,:) = B(cnt,:)+reshape(image(i,j-1,:),[],1)';
            else
                A(cnt,map(i,j-1)) = -1;
            end
            
          
            if mask(i,j+1)==0%上边界
                B(cnt,:) = B(cnt,:)+reshape(image(i,j+1,:),[],1)';
            else
                A(cnt,map(i,j+1)) = -1;
            end
            
       
            B(cnt,:)=B(cnt,:)-reshape(lap(i,j,:),[],1)';%填充散度
        end
    end
end

X=A\B;%解泊松方程

for cnt=1:size(X,1)%输出结果图像
    [idx_x,idx_y]=find(map==cnt);
    out(idx_x,idx_y,:)=reshape(X(cnt,:),1,1,3);
end

