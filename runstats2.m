function[] = runstats2(T, var2graph, x_group_string, x_groups)

var2graph = "Count";
x_groups = ["ctrl_test" "sema4d_test"];
if length(x_groups)>2 
    error('This function is only designed to compare 2 groups! Use (new function name) to compare >2 groups');
end
%Make a cell containing one subtable for each x_group
subT_x_group{1} = T(table2array(T(:,strcmp(T.Properties.VariableNames,x_group_string)))==x_groups(1),:);
subT_x_group{2} = T(table2array(T(:,strcmp(T.Properties.VariableNames,x_group_string)))==x_groups(2),:);


%Independent samples t-test, uncorrected
alpha = 0.05;
[H P CI Stats] = ttest2(subT_x_group{1}.NormCount, subT_x_group{2}.NormCount,'alpha',alpha);
if H>0 sig = ""; 
    else sig = "NOT "; 
end
fprintf('Independent samples Ttest for %s by %s \n%sSignificant\n',var2graph,x_group_string,sig)
fprintf('p = %d \t t = %d \t df = %d\n',P,Stats.tstat,Stats.df) 

return
