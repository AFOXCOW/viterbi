function binary_output=deci2bin(output,n)
%n=2
        binary_output(n)=rem(output,n);
        binary_output(1)=(output-binary_output(n))/n;
end