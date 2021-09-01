function decoder_output=viterbi_hard(channel_output,k)
max=10;
    G=[1 1 1;1 0 1];
    n=size(G,1);
    %k=1;输入1bit
    %(2,1,3)  
    %取矩阵G的行数，故n=2。即得到输出端口，即2个模2加法器 
    
    %检验G的维数  
    if rem(size(G,2),k)~=0 %当矩阵G的列数不为k的整数倍时，rem为求余函数     
        error('Size of G and k do not agree')%报错 
    end
    if rem(size(channel_output,2),n)~=0 %当输出矩阵的列数不是输出端口n的整数倍时。
        error('channel output not of the right size') 
    end
    L=size(G,2)/k;%得出移位数，即寄存器个数 L=3
    %由于L-1个寄存器的状态即可表示出输出状态，所以总的状态数number_of_states可由前L-1个寄存器的状态组合来确定  
    number_of_states=2^((L-1)*k);%此例程中2^2，移位寄存器组的状态数为4个 
    
    %产生状态转移矩阵，输出矩阵和输入矩阵 
    
    for j=0:number_of_states-1 %表示当前寄存器组的状态。因状态从0开始，所以循环为从0到number_of_states-1    
        for t=0:2^k-1 %k位输入端的信号组成的状态，总的状态数为2^k，所以循环为从0到2^k-1  输入为0 1    
            [next_state,memory_contents]=nxt_stat(j,t);%nxt_stat完成从当前的状态和输入的矢量得出下寄存器组的一个状态      
            input(j+1,next_state+1)=t;%input数组值是用于记录当前状态到下一个状态所要的输入信号矢量                               
            %input数组的维数：一维坐标x=j+1指当前状态的值，二维坐标y=next_state+1指下一个状态的值                     
            %由于Matlab中数组的下标是从1开始的，而状态值是从0开始的，所以以上坐标值为：状态值+1     
            branch_output=rem(memory_contents*G',2);%branch_output用于记录在状态j下输入t时的输出     
            nextstate(j+1,t+1)=next_state;%nextstate状态转移矩阵，记录了当前状态j下输入t时的下一个状态    
            output(j+1,t+1)=bin2deci(branch_output);%output记录了当前状态j下输入t时的输出（十进制） 
        end
    end
    
    state_metric=zeros(number_of_states,2);%state_metric数组用于记录译码过程在每个状态时的汉明距离，大小为number_of_states,2                           
    %（：，1）为当前状态位置的汉明距离，为确定值；（：，2）为当前状态加输入得到的下一个状态汉明距离，为临时值 
    depth_of_trellis=length(channel_output)/n;
    %depth_of_trellis用于记录网格图的深度 
    channel_output_matrix=reshape(channel_output,n,depth_of_trellis);%channel_output_matrix为输出矩阵，每一列为一个输出状态                        
    %reshape改变原矩阵形状，将channel_output矩阵变为n行depth_of_trellis列矩阵 
    survivor_state=max*ones(number_of_states,depth_of_trellis+1);%survivor_state描述译码过程中在网格图中的路径  
    %[row_survivor col_survivor]=size(survivor_state); 
    %开始非尾信道输出的解码  %i为段，j为何一阶段的状态，t为输入  
    lastflag=[1 0 0 0];
    for i=1:depth_of_trellis-L+1 %i指示网格图的深度
        flag=zeros(1,number_of_states);%flag矩阵用于记录网格图中的某一列是否被访问过     
        for j=0:number_of_states-1 %j表示寄存器的当前状态   
            if (lastflag(j+1)==0)
                break;
            end
            for t=0:2^k-1 %t为当前的输入           
                branch_metric=0; %用于记录码间距离          
                binary_output=deci2bin(output(j+1,t+1),n);
                %将当前状态下输入状态t时的输出output转为n位2进制，以便计算码间距离。（说明：数组坐标大小变化同上）         
                for tt=1:n 
                    %计算实际的输出码同网格图中此格某种输出的码间距离           
                    branch_metric=branch_metric+metric(channel_output_matrix(tt,i),binary_output(tt));           
                end
                %选择码间距离较小的路径，即当下一个状态没有被访问时就直接赋值，否则，用比它小的将其覆盖
                if  ((state_metric(nextstate(j+1,t+1)+1,2)>state_metric(j+1,1)+branch_metric)||flag(nextstate(j+1,t+1)+1)==0)          
                    state_metric(nextstate(j+1,t+1)+1,2)=state_metric(j+1,1)+branch_metric;
                    %下一状态的汉明距离（临时值）=当前状态的汉明距离（确定值）+码间距离        
                    survivor_state(nextstate(j+1,t+1)+1,i+1)=j;
                    %survivor_state数组的一维坐标为下一个状态值，二维坐标为此状态                          
                    %在网格图中的列位置，记录的数值为当前状态，这样就可以从网格中某位置的                                              
                    %某个状态得出其对应上一个列位置的状态,从而能很方便的完成译码过程。            
                    flag(nextstate(j+1,t+1)+1)=1;%指示该状态已被访问过 
                end
            end
            
        end
        lastflag=flag;
        if (i~=depth_of_trellis-L+1)
            state_metric=state_metric(:,2:-1:1);
        end
        %移动state_metric，将临时值移为确定值 
    end
    
    %decode
    min=state_metric(1,2);
    mins=1;
    for state=2:number_of_states
        if(state_metric(state,2)<min)
            min=state_metric(state,2);
            mins=state;
        end
    end
    decoder_output=zeros(1,i);
    nowstate=mins;
    for back2zero=i+1:-1:2
        laststate=survivor_state(nowstate,back2zero)+1;
        decoder_output(back2zero-1)=backdecode(nowstate,laststate,nextstate);
        nowstate=laststate;
    end
end
    
    
%     %开始尾信道输出的解码
%         for i=depth_of_trellis-L+2:depth_of_trellis   
%             flag=zeros(1,number_of_states);      
%             %状态数从number_of_states→number_of_states/2→??→2→1    
%             %程序说明同上，只不过输入矢量只为
%             last_stop=number_of_states/(2^((i-depth_of_trellis+L-2)*k));    
%             for j=0:last_stop-1      
%                 branch_metric=0;     
%                 binary_output=deci2bin(output(j+1,1),n);        
%                 for tt=1:n              
%                     branch_metric=branch_metric+metric(channel_output_matrix(tt,i),binary_output(tt));         
%                 end
%                 if  ((state_metric(nextstate(j+1,1)+1,2)>state_metric(j+1,1)+branch_metric)||flag(nextstate(j+1,1)+1)==0)           
%                     state_metric(nextstate(j+1,1)+1,2)=state_metric(j+1,1)+branch_metric;         
%                     survivor_state(nextstate(j+1,1)+1,i+1)=j;            
%                     flag(nextstate(j+1,1)+1)=1;          
%                 end
%             end
%             state_metric=state_metric(:,2:-1:1); 
%         end
%         %从最优路径产生解码输出
%         %译码过程可从数组survivor_state的最后一个位置逐级向前译码 
%         %由段得到状态序列，再由状序列从input矩阵中得到该段的输出 
%         %数组survivor_state的最后的输出状态肯定为“0” 
%         state_sequence=zeros(1,depth_of_trellis+1); size(state_sequence); 
%         state_sequence(1,depth_of_trellis)=survivor_state(1,depth_of_trellis+1); 
%         %逐级译码过程 
%         for i=1:depth_of_trellis 
%             state_sequence(1,depth_of_trellis-i+1)=survivor_state((state_sequence(1,depth_of_trellis+2-i)+1),depth_of_trellis-i+2);
%             %由后向前 
%         end
%         state_sequence;  
%         decoder_output_matrix=zeros(k,depth_of_trellis-L+1); 
%         for i=1:depth_of_trellis-L+1     
%             dec_output_deci=input(state_sequence(1,i)+1,state_sequence(1,i+1)+1);
%             %根据数组input的定义来得出从当前状态到下一个状态的输入信号矢量      
%             dec_output_bin=deci2bin(dec_output_deci,k);
%             %转换成2进制信号   
%             decoder_output_matrix(:,i)=dec_output_bin(k:-1:1)';
%             %将每一次译码存入译码输出矩阵decoder_output_matrix相应的位置 
%         end
%         decoder_output=reshape(decoder_output_matrix,1,k*(depth_of_trellis-L+1));
%         %按照一维序列形式重新组织输出 
%         cumulated_metric=state_metric(1,1);
%         %state_metric为网格图最后一个列位置中“0”状态位置的汉明距离，此值就是整个译码过程中的汉明距离 %卷积码的维特比译码函数  
%         figure;plot(decoder_output,'*r') 
%         %还原出的输入信号 


