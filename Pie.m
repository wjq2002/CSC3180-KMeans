function out = Pie(subbimage, subsimage, mask,max)

out=subbimage;%�����ʼ��
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
if max==1
laplacian_mask=[0 1 0;1 -4 1;0 1 0];%������˹����
lap=imfilter(subsimage,laplacian_mask);%ͨ��������˹�˲���ɢ�ȣ�seamless cloning)
else
k={[1 -1 0],[0 -1 1],[1;-1;0],[0;-1;1]};%����ݶ���ɢ��(mixed seamless cloning)

lap=0;
for d=1:4%���Ƚϱ���ͼ��Դͼ�ݶȣ�ȡ�ϴ��ߣ�
    b_grad=imfilter(subbimage,k{d});
    s_grad=imfilter(subsimage,k{d});
   tempmask=abs(s_grad)>abs(b_grad);
    grad=s_grad.*tempmask+b_grad.*(tempmask==0);
    lap=lap+grad;
end
end

coeffNum=5;
A=spalloc(num,num,num*coeffNum);%����ϡ��ϵ������

B=zeros(num,size(subbimage,3));%�����洢ɢ���ÿվ���


cnt = 0;
for i=2:m-1
    for j=2:n-1
        if mask(i,j)==1
            cnt = cnt+1;
            A(cnt,cnt) = 4;
             
            if mask(i-1,j)==0%��߽�
                B(cnt,:) = reshape(subbimage(i-1,j,:),[],1);
            else
                A(cnt,map(i-1,j)) = -1;
            end
            
            if mask(i+1,j)==0%�ұ߽�
                B(cnt,:) = B(cnt,:)+reshape(subbimage(i+1,j,:),[],1)';
            else
                A(cnt,map(i+1,j)) = -1;
            end
              
         
            if mask(i,j-1)==0%�±߽�
                B(cnt,:) = B(cnt,:)+reshape(subbimage(i,j-1,:),[],1)';
            else
                A(cnt,map(i,j-1)) = -1;
            end
            
          
            if mask(i,j+1)==0%�ϱ߽�
                B(cnt,:) = B(cnt,:)+reshape(subbimage(i,j+1,:),[],1)';
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


    

            
