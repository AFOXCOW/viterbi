function code_decode()
    N=1000;
    input=(sign(-0.5+rand(1,N))+1)/2;
    coder_output=coder(input);
    ber=zeros(1,301);
    j=1;
    for SNRdb=-10:0.1:20
        awgn_coder_output=awgn(coder_output,SNRdb);
        for i=1:2*(N+2)
           if(awgn_coder_output(i)>0.5)
               awgn_coder_output(i)=1;
           else
               awgn_coder_output(i)=0;
           end
        end
        decoder_output=viterbi_hard(awgn_coder_output,1);
        eb=0;
        for i=1:N
           if(input(i)~=decoder_output(i))
               eb=eb+1;
           end
        end
        ber(j)=eb/N;
        j=j+1;
    end
    SNRdb=-10:0.1:20;
    plot(SNRdb,ber);
end