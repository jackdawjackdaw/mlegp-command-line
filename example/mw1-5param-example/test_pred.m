clear all

testPoints = [ 0.1 0.1 0.1 0.1 0.1; 
        0.2 0.2 0.2 0.2 0.2; 
        0.3 0.3 0.3 0.3 0.3]

means = [1.2002e+01   5.5983e+01   9.9993e-02   1.0000e-10   1.2001e-01];

sigs = [ 4.0483e+00   3.2400e+01   5.7856e-02   4.6294e-11 4.6278e-02];



fidIn = fopen('data_pipe_in','w');
fidOut = fopen('data_pipe_out', 'r');

nheader = 6; %% number of header lines

for count = 1:3
fprintf(fidIn, '%f %f %f %f %f\n', testPoints(count,:).*sigs + means);
    if(count == 1) %% skip the header lines the first time
         'skipping header'
      for c2=1:nheader
        hline = fgetl(fidOut);
        disp(hline)
        end
     end%     
impJointLine = fscanf(fidOut, '%f',1);
impSingleLine = fscanf(fidOut, '%f', 6);
disp(impJointLine)
disp(impSingleLine)
fprintf('%d %g\n', count, impJointLine); 
end

fprintf(fidIn, 'EOF\n')

fclose(fidOut)
fclose(fidIn)

% 
% %vals = fgetl(fid);
% %'first line'
% %disp(vals)
% while(~feof(fid))
%     vals = fgetl(fid);
%     'it allows to do other crap'
%     disp(vals)
% 
% end
% 
% fclose(fid);
% % 
