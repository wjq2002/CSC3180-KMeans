function out = Pie(subbimage, subsimage, mask,max)

out=subbimage;%输出初始化
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
if max==1
laplacian_mask=[0 1 0;1 -4 1;0 1 0];%拉普拉斯算子
lap=imfilter(subsimage,laplacian_mask);%通过拉普拉斯滤波求散度（seamless cloning)
else
k={[1 -1 0],[0 -1 1],[1;-1;0],[0;-1;1]};%混合梯度求散度(mixed seamless cloning)

lap=0;
for d=1:4%（比较背景图与源图梯度，取较大者）
    b_grad=imfilter(subbimage,k{d});
    s_grad=imfilter(subsimage,k{d});
   tempmask=abs(s_grad)>abs(b_grad);
    grad=s_grad.*tempmask+b_grad.*(tempmask==0);
    lap=lap+grad;
end
end

coeffNum=5;
A=spalloc(num,num,num*coeffNum);%建立稀疏系数矩阵

B=zeros(num,size(subbimage,3));%建立存储散度用空矩阵


cnt = 0;
for i=2:m-1
    for j=2:n-1
        if mask(i,j)==1
            cnt = cnt+1;
            A(cnt,cnt) = 4;
             
            if mask(i-1,j)==0%左边界
                B(cnt,:) = reshape(subbimage(i-1,j,:),[],1);
            else
                A(cnt,map(i-1,j)) = -1;
            end
            
            if mask(i+1,j)==0%右边界
                B(cnt,:) = B(cnt,:)+reshape(subbimage(i+1,j,:),[],1)';
            else
                A(cnt,map(i+1,j)) = -1;
            end
              
         
            if mask(i,j-1)==0%下边界
                B(cnt,:) = B(cnt,:)+reshape(subbimage(i,j-1,:),[],1)';
            else
                A(cnt,map(i,j-1)) = -1;
            end
            
          
            if mask(i,j+1)==0%上边界
                B(cnt,:) = B(cnt,:)+reshape(subbimage(i,j+1,:),[],1)';
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


    

            
