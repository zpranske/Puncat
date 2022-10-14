%% Extract data and organize summary files
function[S] = processSummary(summary_files)
    disp('Combining summary files...')
    S = [];
     for i = 3:length(summary_files)
        temp_S = readtable([summary_files(i).folder '\' summary_files(i).name]);    
        %temp_M = renamevars(temp_M,'Var1','Cell#');
        temp_S = [table(string(repmat(summary_files(i).name,height(temp_S),1))) temp_S];
        temp_S = renamevars(temp_S,'Var1','Filename');
        S = [S; temp_S];
     end 
     
      disp('Preprocessing combined summary file...')


     t2 = [];
     for i=1:height(S)
        temp = strsplit(S.Filename(i),'.'); temp = temp(1); temp = strsplit(temp,'_');
        temp = temp(end); temp = str2num(temp); t2 = [t2; temp];
     end
     S = [table(t2) S];
     S = renamevars(S,'t2','CodedFile#');

     %This code extracts cell z from the auto-generated Slice column in Fiji 
     %Summary files
     label_bin = table();
     labels = string(S.Slice);
     cell_num = 0;
     for i=1:length(labels)
        s = strsplit(labels(i),':');
        z = strsplit(s(3),'/');
        z = str2num(z(1));
        label_bin(i,1) = {z};

        image_code = strsplit(s(3));
        label_bin(i,2) = {image_code(3)};
        if i==1 cell_num = 1;
        else if label_bin{i,2}~=label_bin{i-1,2} cell_num = 1; 
        else if label_bin{i,1}<label_bin{i-1,1} cell_num = cell_num+1; end; end
        end
        label_bin(i,3) = {cell_num};
     end

     S = [S(:,1:3) label_bin(:,1) label_bin(:,3) S(:,4:end)];
     S = renamevars(S,'Var1','Shape_Z');
     S = renamevars(S,'Var3','Cell#');
     warning('on','all')   
 return;