function decoder_output=viterbi_hard(channel_output,k)
max=10;
    G=[1 1 1;1 0 1];
    n=size(G,1);
    %k=1;����1bit
    %(2,1,3)  
    %ȡ����G����������n=2�����õ�����˿ڣ���2��ģ2�ӷ��� 
    
    %����G��ά��  
    if rem(size(G,2),k)~=0 %������G��������Ϊk��������ʱ��remΪ���ຯ��     
        error('Size of G and k do not agree')%���� 
    end
    if rem(size(channel_output,2),n)~=0 %����������������������˿�n��������ʱ��
        error('channel output not of the right size') 
    end
    L=size(G,2)/k;%�ó���λ�������Ĵ������� L=3
    %����L-1���Ĵ�����״̬���ɱ�ʾ�����״̬�������ܵ�״̬��number_of_states����ǰL-1���Ĵ�����״̬�����ȷ��  
    number_of_states=2^((L-1)*k);%��������2^2����λ�Ĵ������״̬��Ϊ4�� 
    
    %����״̬ת�ƾ������������������ 
    
    for j=0:number_of_states-1 %��ʾ��ǰ�Ĵ������״̬����״̬��0��ʼ������ѭ��Ϊ��0��number_of_states-1    
        for t=0:2^k-1 %kλ����˵��ź���ɵ�״̬���ܵ�״̬��Ϊ2^k������ѭ��Ϊ��0��2^k-1  ����Ϊ0 1    
            [next_state,memory_contents]=nxt_stat(j,t);%nxt_stat��ɴӵ�ǰ��״̬�������ʸ���ó��¼Ĵ������һ��״̬      
            input(j+1,next_state+1)=t;%input����ֵ�����ڼ�¼��ǰ״̬����һ��״̬��Ҫ�������ź�ʸ��                               
            %input�����ά����һά����x=j+1ָ��ǰ״̬��ֵ����ά����y=next_state+1ָ��һ��״̬��ֵ                     
            %����Matlab��������±��Ǵ�1��ʼ�ģ���״ֵ̬�Ǵ�0��ʼ�ģ�������������ֵΪ��״ֵ̬+1     
            branch_output=rem(memory_contents*G',2);%branch_output���ڼ�¼��״̬j������tʱ�����     
            nextstate(j+1,t+1)=next_state;%nextstate״̬ת�ƾ��󣬼�¼�˵�ǰ״̬j������tʱ����һ��״̬    
            output(j+1,t+1)=bin2deci(branch_output);%output��¼�˵�ǰ״̬j������tʱ�������ʮ���ƣ� 
        end
    end
    
    state_metric=zeros(number_of_states,2);%state_metric�������ڼ�¼���������ÿ��״̬ʱ�ĺ������룬��СΪnumber_of_states,2                           
    %������1��Ϊ��ǰ״̬λ�õĺ������룬Ϊȷ��ֵ��������2��Ϊ��ǰ״̬������õ�����һ��״̬�������룬Ϊ��ʱֵ 
    depth_of_trellis=length(channel_output)/n;
    %depth_of_trellis���ڼ�¼����ͼ����� 
    channel_output_matrix=reshape(channel_output,n,depth_of_trellis);%channel_output_matrixΪ�������ÿһ��Ϊһ�����״̬                        
    %reshape�ı�ԭ������״����channel_output�����Ϊn��depth_of_trellis�о��� 
    survivor_state=max*ones(number_of_states,depth_of_trellis+1);%survivor_state�������������������ͼ�е�·��  
    %[row_survivor col_survivor]=size(survivor_state); 
    %��ʼ��β�ŵ�����Ľ���  %iΪ�Σ�jΪ��һ�׶ε�״̬��tΪ����  
    lastflag=[1 0 0 0];
    for i=1:depth_of_trellis-L+1 %iָʾ����ͼ�����
        flag=zeros(1,number_of_states);%flag�������ڼ�¼����ͼ�е�ĳһ���Ƿ񱻷��ʹ�     
        for j=0:number_of_states-1 %j��ʾ�Ĵ����ĵ�ǰ״̬   
            if (lastflag(j+1)==0)
                break;
            end
            for t=0:2^k-1 %tΪ��ǰ������           
                branch_metric=0; %���ڼ�¼������          
                binary_output=deci2bin(output(j+1,t+1),n);
                %����ǰ״̬������״̬tʱ�����outputתΪnλ2���ƣ��Ա���������롣��˵�������������С�仯ͬ�ϣ�         
                for tt=1:n 
                    %����ʵ�ʵ������ͬ����ͼ�д˸�ĳ�������������           
                    branch_metric=branch_metric+metric(channel_output_matrix(tt,i),binary_output(tt));           
                end
                %ѡ���������С��·����������һ��״̬û�б�����ʱ��ֱ�Ӹ�ֵ�������ñ���С�Ľ��串��
                if  ((state_metric(nextstate(j+1,t+1)+1,2)>state_metric(j+1,1)+branch_metric)||flag(nextstate(j+1,t+1)+1)==0)          
                    state_metric(nextstate(j+1,t+1)+1,2)=state_metric(j+1,1)+branch_metric;
                    %��һ״̬�ĺ������루��ʱֵ��=��ǰ״̬�ĺ������루ȷ��ֵ��+������        
                    survivor_state(nextstate(j+1,t+1)+1,i+1)=j;
                    %survivor_state�����һά����Ϊ��һ��״ֵ̬����ά����Ϊ��״̬                          
                    %������ͼ�е���λ�ã���¼����ֵΪ��ǰ״̬�������Ϳ��Դ�������ĳλ�õ�                                              
                    %ĳ��״̬�ó����Ӧ��һ����λ�õ�״̬,�Ӷ��ܷܺ�������������̡�            
                    flag(nextstate(j+1,t+1)+1)=1;%ָʾ��״̬�ѱ����ʹ� 
                end
            end
            
        end
        lastflag=flag;
        if (i~=depth_of_trellis-L+1)
            state_metric=state_metric(:,2:-1:1);
        end
        %�ƶ�state_metric������ʱֵ��Ϊȷ��ֵ 
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
    
    
%     %��ʼβ�ŵ�����Ľ���
%         for i=depth_of_trellis-L+2:depth_of_trellis   
%             flag=zeros(1,number_of_states);      
%             %״̬����number_of_states��number_of_states/2��??��2��1    
%             %����˵��ͬ�ϣ�ֻ��������ʸ��ֻΪ
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
%         %������·�������������
%         %������̿ɴ�����survivor_state�����һ��λ������ǰ���� 
%         %�ɶεõ�״̬���У�����״���д�input�����еõ��öε���� 
%         %����survivor_state���������״̬�϶�Ϊ��0�� 
%         state_sequence=zeros(1,depth_of_trellis+1); size(state_sequence); 
%         state_sequence(1,depth_of_trellis)=survivor_state(1,depth_of_trellis+1); 
%         %��������� 
%         for i=1:depth_of_trellis 
%             state_sequence(1,depth_of_trellis-i+1)=survivor_state((state_sequence(1,depth_of_trellis+2-i)+1),depth_of_trellis-i+2);
%             %�ɺ���ǰ 
%         end
%         state_sequence;  
%         decoder_output_matrix=zeros(k,depth_of_trellis-L+1); 
%         for i=1:depth_of_trellis-L+1     
%             dec_output_deci=input(state_sequence(1,i)+1,state_sequence(1,i+1)+1);
%             %��������input�Ķ������ó��ӵ�ǰ״̬����һ��״̬�������ź�ʸ��      
%             dec_output_bin=deci2bin(dec_output_deci,k);
%             %ת����2�����ź�   
%             decoder_output_matrix(:,i)=dec_output_bin(k:-1:1)';
%             %��ÿһ��������������������decoder_output_matrix��Ӧ��λ�� 
%         end
%         decoder_output=reshape(decoder_output_matrix,1,k*(depth_of_trellis-L+1));
%         %����һά������ʽ������֯��� 
%         cumulated_metric=state_metric(1,1);
%         %state_metricΪ����ͼ���һ����λ���С�0��״̬λ�õĺ������룬��ֵ����������������еĺ������� %������ά�ر����뺯��  
%         figure;plot(decoder_output,'*r') 
%         %��ԭ���������ź� 


