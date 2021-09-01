function coder_output=coder(x)
%survivor state是一个矩阵，它显T了通过网格的最优路径，这个矩阵通过一个单独的函数metric(x,y)给出。  
%其中G是一个矩阵，它的任一行决定了从移位寄存器到模2加法器的连接方式.为生成矩阵 
%这里，我们做了一个简单的(2,1,3)卷积码编码器。 
k=1;  G=[1 1 1;1 0 1];

%以下3种输入序列，可任选一种% 

%input=[0 0 0 0 0 0 0];%全0输入 
%input=[1 1 1 1 1 1 1];%全1输入  
input=x;
%随机系列输入，也可用 randint(1,7,[0 1]) 

s=input; 
g1=G(1,:);
g2=G(2,:);  
c1=conv(s,g1);
%作卷积 
%disp(c1); 
c2=conv(s,g2); 
%disp(c2); 
n=length(c1);
c=zeros(1,2*n);
%生成全0矩阵
%disp(c); 
for i=1:n     
    c(2*i-1)=c1(i);
    c(2*i)=c2(i);%两个模2加法器分别输出卷积结果序列后，由旋转开关读取的结果（此时仅为卷积结果，非2进制0/1） 
end
for i=1:2*n     
    if(mod(c(i),2)==0)% mod(c(i),2)==0意思：c(i)除以2，余数为0        
        c(i)=0;        
    else c(i)=1;    
    end
end
output=c;
coder_output=output;%输出矩阵  
end