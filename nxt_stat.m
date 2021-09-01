function [next_state,memory_contents]=nxt_stat(j,t)
    
    if j==0
        if t==0
            next_state=0;
        else
            next_state=1;
        end
        memory_contents=[t 0 0];
    end
    if j==1
        if t==0
            next_state=2;
        else
            next_state=3;
        end
        memory_contents=[t 1 0];
    end
    if j==2
        if t==0
            next_state=0;
        else
            next_state=1;
        end
        memory_contents=[t 0 1];
    end
    if j==3
        if t==0
            next_state=2;
        else
            next_state=3;
        end
        memory_contents=[t 1 1];
    end
end