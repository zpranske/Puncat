%% Extract data and organize measure files
function[M] = processMeasures(measure_files)
     disp('Combining measure files...')
     %These are the headers the code expects the .csv files generated by 
     %Fiji to have. If they do not match, z coding will not work.
     measure_format = [{'Var1'} {'Label'} {'Area'} {'Mean'} {'Min'} {'Max'} {'X'}...
         {'Y'} {'XM'} {'YM'} {'Perim_'} {'Feret'} {'IntDen'} {'RawIntDen'}...
         {'FeretX'} {'FeretY'} {'FeretAngle'} {'MinFeret'} {'MinThr'} {'MaxThr'}];
     
     warning('off','all')     
     M = [];
     for i = 3:length(measure_files)
        temp_M = readtable([measure_files(i).folder '\' measure_files(i).name]);
        if~(temp_M.Properties.VariableNames == measure_format)
            error(['Header format for file ' measure_files(i).name ' is not correct!'])
        end;
        temp_M = renamevars(temp_M,'Var1','Cell#');
        temp_M = [table(string(repmat(measure_files(i).name,height(temp_M),1))) temp_M];
        temp_M = renamevars(temp_M,'Var1','Filename');
        M = [M; temp_M];
     end 
     
     disp('Preprocessing combined measure file...')

     t = [];
     for i=1:height(M)
        temp = strsplit(M.Filename(i),'.'); temp = temp(1); temp = strsplit(temp,'_');
        temp = temp(end); temp = str2num(temp); t = [t; temp];
     end
     M = [table(t) M];
     M = renamevars(M,'t','CodedFile#');

     %This code extracts cell z from the auto-generated label column in Fiji 
     %Measure files. Needs to be changed if only choosing z using one channel
     %as the default format of the label column is different
     label_bin = table();
     labels = string(M.Label);
     for i=1:length(labels)
        s = strsplit(labels(i),':');
        shape_type = strsplit(s(2),'_');
        label_bin(i,1) = {shape_type(1)};
        coded_z = str2num(s(3));
        %Coded z is written as: 1-2 are z=1, c=1-2. 3-4 are z=2, c=1-2. 
        %Thus, the true z is the coded z extracted from the column divided by 2 
        %and rounded up.
        if(mod(coded_z,2)==0) z = coded_z/2;
        else z = coded_z/2 + 0.5; end
        label_bin(i,2) = {z};
     end
     
     M.("Cell#") = round(M.("Cell#")/2);

     M = [M(:,1:4) label_bin M(:,5:end)];
     M = renamevars(M,'Var1','Shape_Type');
     M = renamevars(M,'Var2','Shape_Z');
     M.Unique_Z_ID = join(strcat([string(M.("CodedFile#")),...
         string(M.("Cell#")),string(M.Shape_Z)]),"_");
     M = [M(:,1:6) M(:,end) M(:,7:end-1)];
         
 return