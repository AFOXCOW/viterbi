function output=backdecode(nowstate,laststate,nextstate)
for i=1:2
    if (nextstate(laststate,i)==nowstate)
        output = 0;
    else
        output =1;
    end
end