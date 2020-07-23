pnum  = [295];
yearnum = [2016];
vers = 'v13';
mPlant = 309;
myear = 2017;
% sz = [15:5:300]';
load('BIN_INDEX')
%%
for p = 1:length(pnum)
    
iPlant = pnum(p);
year = yearnum(p);

foldername = ['Model_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant)];
mkdir(foldername)
%% bootstrap_SAT_data
filename1 = ['Hourly_SAT_' num2str(year) '_' num2str(iPlant) '.mat'];
filename_input = ['Hourly_input_adjust_' num2str(year) '_' num2str(iPlant) '.mat'];

matObj = matfile(filename1);
a = who(matObj);

matObj2 = matfile(filename_input);


                                    if iPlant == 277
                                        Pcap = 101;
                                    elseif iPlant == 295
                                        Pcap = 53;
                                    elseif iPlant == 309
                                        Pcap = 20;
                                    elseif iPlant == 320
                                        Pcap = 50;
                                    end

for i = 1:length(a)
    i
     c1 = sscanf(a{i},'Hourly_SAT_%d_%d_%d');
    load(filename1,a{i});
    a_input = who(matObj2,['*_' num2str(c1(3))]);
    load(filename_input,a_input{:});
    SAT_data = eval(a{i});
    input_data = eval(a_input{:});
    if isempty(vertcat(input_data.TimeStamp{:})) || sum(input_data.DataSum ~= 0) == 0
        mat_index = NaN([height( input_data) 900]);
        A_cell = mat2cell(mat_index,ones([1,24]));
        A_cell = cellfun(@(x) x',A_cell,'UniformOutput',0);
        Tcell = table(A_cell,'VariableNames',{'ClearSkyIdxOutput'});
        T1 = [SAT_data Tcell];
    else
    input_clearsky = input_data.ClearSkyOutputIdx;
    input_inf = cellfun(@(x) x(x~= inf),input_clearsky,'UniformOutput',0);
    input_avg = cellfun(@(x) mean(x,'omitnan'),input_inf,'UniformOutput',0);
    input_avg = vertcat(input_avg{:});
    input_avg(input_avg>1.5) = 1.5;
    DataAvg = input_data.DataAvg;
    input_cs = input_data.ClearSkyOutputAdj;
    for s = 1:length(input_cs)
        if ~isempty(input_cs{s}) && ~all(isnan(input_cs{s})) && s < 12 && length(input_cs{s}) < 900
            input_cs{s} = [NaN([900 - length(input_cs{s}),1]);input_cs{s}];
        elseif ~isempty(input_cs{s}) && ~all(isnan(input_cs{s})) && s > 12 && length(input_cs{s}) < 900
            input_cs{s} = [input_cs{s}; NaN([900 - length(input_cs{s}),1])];
        end
     end
    
    ClearNumGHI = SAT_data.ClearNumGHI_Adj;
    ClearNumDNI = SAT_data.ClearNumDNI_Adj;
   
    interval_array = NaN([24 2]);
    mat_array = NaN([24 900]);
    row_idx = find(~isnan(ClearNumGHI) & ~isnan(ClearNumDNI));
    %%%%%%%%%%%
    
%     Plantsz = round(Pcap/5)*5;
%     szidx = find(Plantsz == sz);
    
    ModelSelect = '2016_295';
    
    filename2 = ['bin_dist_pool_' num2str(myear) '_' num2str(mPlant) '_' num2str(iPlant)];
        
    load(filename2)
    filename3 = ['F:\Bin_pool\' 'bin_dist_pool_' ModelSelect '\' 'bin_interval_' ModelSelect];
    load(filename3)
    filename4 = ['F:\Bin_pool\' 'bin_dist_pool_' ModelSelect '\' 'bin_sum_' ModelSelect];
    load(filename4)
    bin_exist = eval(['BIN_INDEX_exist_' num2str(mPlant)]);
    bin_index = BIN_INDEX(bin_exist,:);
    
    %%%%%%%
     jdiff = diff(row_idx);
    jinitial = NaN([height(input_data),1]);
    ja3 = cell([height( input_data),1]);
    jc = NaN([height( input_data),3]);
    mat_index = NaN([height( input_data) 900]);
    mat_output = NaN([height( input_data) 900]);
    jj = 0;
    
    for j = row_idx'
         j
         jj = jj+1;
          a2 = who(['bin_pool_*_' num2str(ClearNumGHI(j)) '_'  num2str(ClearNumDNI(j))]);
        if isempty(a2)
            Bg = ClearNumGHI(j);
            Bd = ClearNumDNI(j);
            t = 0;
            while isempty(a2)
                t = t+1;
                Bg1 = Bg+t;
                a2 = who(['bin_pool_*_' num2str(Bg1) '_'  num2str(Bd)]);
                if isempty(a2)
                    Bg1 = Bg-t;
                a2 = who(['bin_pool_*_' num2str(Bg1) '_'  num2str(Bd)]);
                end
                    if isempty(a2)
                       Bd1 = Bd+t;
                a2 = who(['bin_pool_*_' num2str(Bg) '_'  num2str(Bd1)]);
                    end
                    if isempty(a2)
                           Bd1 = Bd-t;
                    a2 = who(['bin_pool_*_' num2str(Bg) '_'  num2str(Bd1)]);
                    end
                    if isempty(a2)
                        Bg1 = Bg+t;
                         Bd1 = Bd+t;
                         a2 = who(['bin_pool_*_' num2str(Bg1) '_'  num2str(Bd1)]);
                    end
                     if isempty(a2)
                        Bg1 = Bg-t;
                         Bd1 = Bd-t;
                         a2 = who(['bin_pool_*_' num2str(Bg1) '_'  num2str(Bd1)]);
                     end
              end
        end
        
       
        c = sscanf(a2{:},'bin_pool_%d_%d_%d');
        a3 = who(['bin_pool_' num2str(c(1)) '_*']);
        ja3{j,1} = a3;
        jc(j,:) = c';

            if isnan(input_avg(j))
                interval1 = 0;
            else
                interval1 = input_avg(j);
            end

        interval1(interval1 > 1.5) = 1.5;
             jinitial(j,1) = interval1;
    end
      
        jinitial(row_idx(1)-1) = 0;
        jinitial(row_idx(end)+1) = 0;
     jinitial_final = [jinitial(1:end-1) jinitial(2:end)];
        nan_idx = ~isnan(jinitial_final(:,1)) & isnan(jinitial_final(:,2));
        jinitial_final(nan_idx,2) = jinitial_final(nan_idx,1);
    %%%%%%%%
         tic
%      jidx = NaN([height(T2),1]);
%      jidx(row_idx') = row_idx';
     for ij = row_idx'
         ij
              initial_final = jinitial_final(ij,:);
     if sum(initial_final) == 0 || isnan(sum(initial_final)) || isempty(input_cs{ij}) || isnan(DataAvg(ij))
         continue
     else
        bin_pool = eval(ja3{ij,1}{:});
        bin_pool = bin_pool';
        
                   A = NaN([500, 900]);% leave 900 for the last column
                   B = [];
                   tt1 = 0;
          
                   interval1  = initial_final(1);
                   interval2 = initial_final(2);
                    tvec = [1:899];
                       while isempty(B)
                           tt1 = tt1+1
                           if tt1 > 300
                               break
                           end
                           A(:,1) = interval1.*ones([500,1]);
%                            if SAT_data.ClearSkyIdxGHI(ij) >1 && SAT_data.ClearSkyIdxDNI(ij) > 1 ||...
                       if ClearNumGHI(ij) >= 11 && ClearNumDNI(ij) >= 11
                               Bcoeff = (tvec./900).*(interval2 - interval1);
                               A(:,2:end)= 0;
                               B1 = cumsum(A,2);
                               B = B1;
                               B(:,2:end) = B1(:,2:end) + Bcoeff;
                           else
                       idx_pool = ceil(rand(500,899)*length(bin_pool));
                       mat_pool = round(bin_pool(idx_pool),2);
                    
                        A(:,2:end) = mat_pool;
                        B1 = cumsum(A,2);
                        B = B1;
                        idx_neg = sum((B(:,2:end-1) <= 0),2) == 0;
                       B = B(idx_neg,:);
                       idx_over = sum(B(:,2:end-1) > 1.5,2) == 0;
                       B = B(idx_over,:);
     
                       prc99 = prctile(abs(bin_pool),99);
                       if interval2 == 0 || tt1 > 295
                           continue
                       else
                       prc99 = prctile(abs(bin_pool),99);
                       if tt1 >= 150
                        idx_99 = abs(B(:,end)- interval2)< max(abs(bin_pool));
                       else
                       idx_99 = abs(B(:,end)- interval2) < prc99;
                       end
                       B = B(idx_99,:);
                       end
                       end
                       end
                       
                       B_output = B.*input_cs{ij}';
                       B_avg = mean(B_output,2);
                      
                             [M,I] = min(abs(B_avg - DataAvg(ij)));
                          mat_index(ij,:) = B(I,:);
     end
     end
     toc
 
    A_cell = mat2cell(mat_index,ones([1,24]));
    A_cell = cellfun(@(x) x',A_cell,'UniformOutput',0);
    Tcell = table(A_cell,'VariableNames',{'ClearSkyIdxOutput'});
    T1 = [SAT_data Tcell];
    end
    assignin('base',a{i},T1)
end
 filename_save = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Hourly_SAT_bin_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
 save(filename_save,a{:});
  clear(a{:})
 clear('bin_pool_*')
%% model_bootstrap_output
'step2'
                                    if iPlant == 277
                                        Pcap = 101;
                                    elseif iPlant == 295
                                        Pcap = 53;
                                    elseif iPlant == 309
                                        Pcap = 20;
                                    elseif iPlant == 320
                                        Pcap = 50;
                                    end

filename1 = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Hourly_SAT_bin_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
matObj1 = matfile(filename1);
a = who(matObj1);

filename2 = ['Hourly_input_adjust_' num2str(year) '_' num2str(iPlant) '.mat'];
matObj2 = matfile(filename2);

day_number = 1:length(a);
tic
for dd = 1:length(day_number)
    dd
    a1 = who(matObj1,['*_' num2str(dd)]);
    a2 = who(matObj2,['*_' num2str(dd)]);
    
    load(filename1,a1{:}); load(filename2,a2{:});
    SAT_array = eval(a1{:}); input_array = eval(a2{:}); %input_array only inlcude hours that power is generating
    ModelledOutput = cell([24,1]);
    ClearSkyOutputCurtailed = input_array.ClearSkyOutputAdj;
    ClearSkyIdxOutput = SAT_array.ClearSkyIdxOutput;
    if ~isempty(vertcat(input_array.TimeStamp{:})) || sum(input_array.DataSum) ~= 0
    h1 = ~cellfun(@isempty,SAT_array.ClearSkyIdxOutput);
    h2 = ~cellfun(@isempty,input_array.ClearSkyOutputAdj);
    h3 = find(h1.*h2);
    for i = 1:length(h3)
        start_h1 = length(SAT_array.ClearSkyIdxOutput{h3(i)});
        start_h2 = length(input_array.ClearSkyOutputAdj{h3(i)});
        if i == 1 && start_h1 ~= start_h2
            ModelledOutput{h3(i),1} = SAT_array.ClearSkyIdxOutput{h3(i)}(end-start_h2+1:end).*input_array.ClearSkyOutputAdj{h3(i)};
        elseif i == length(h3) && start_h1 ~= start_h2
            ModelledOutput{h3(i),1} = SAT_array.ClearSkyIdxOutput{h3(i)}(1:start_h2).*input_array.ClearSkyOutputAdj{h3(i)};
        else
        ModelledOutput{h3(i),1} = SAT_array.ClearSkyIdxOutput{h3(i)}.*input_array.ClearSkyOutputAdj{h3(i)};
        end
        ModelledOutput{h3(i),1}(ModelledOutput{h3(i),1} > Pcap) = Pcap;
    end
    end
        OutputSum = cellfun(@sum,ModelledOutput);
        OutputAvg = cellfun(@mean,ModelledOutput);
        OutputStd = cellfun(@std,ModelledOutput);
        
        T1 = table(ModelledOutput,OutputSum,OutputAvg,OutputStd);
        T2 = [SAT_array T1];
        
        mmonth = T2.TimeStamp(1).Month; dday = T2.TimeStamp(1).Day;
        
        if mmonth <= 9 
        mmn = ['0' num2str(mmonth)];
    else
        mmn = num2str(mmonth);
    end
    
    if dday <=9
        ddy = ['0' num2str(dday)];
    else
        ddy = num2str(dday);
    end
    
     parname_save = ['Hourly_model_' num2str(iPlant) '_' num2str(year) mmn ddy '_' num2str(dd)];
    assignin('base',parname_save,T2)
    
      clear(a1{:},a2{:})
end
toc
 filename_save = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Hourly_model_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
 a3 = who('Hourly_model_*');
 save(filename_save,a3{:})
clear(a3{:})
%%  hourly_model_diff

filename1= ['F:\Variability Modelling - ' vers '\' foldername '\' 'Hourly_model_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
mat1 = matfile(filename1);
a1 = who(mat1);
load(filename1)

filename2 = ['Hourly_input_adjust_' num2str(year) '_' num2str(iPlant) '.mat'];
mat2 = matfile(filename2);
a2 = who(mat2);
load(filename2)

for i = 1:length(a1)
    data_array = eval(a1{i});
    input_array = eval(a2{i});

    T1 = data_array(:,[1 2 7 8 13 14]);
    %HourNumber, TimeStamp, ClearNumGHI,ClearNumDNI, ClearskyIdxOutput,
    %Modelled Output
    diff_array = cellfun(@diff, T1.ModelledOutput,'UniformOutput',0);
    diff_array_cs = cellfun(@diff,input_array.ClearSkyOutputAdj, 'UniformOutput',0);
    
    OutputDiff = diff_array;
    VarIndex = cellfun(@(x,y) sum(sqrt(x.^2 + (4/60)^2))/sum(sqrt(y.^2 + (4/60)^2)),diff_array,diff_array_cs);
    DiffSum = cellfun(@(x) sum(abs(x),'omitnan'),diff_array);
    DiffAvg = cellfun(@(x) mean(abs(x),'omitnan'),diff_array);
    DiffStd = cellfun(@(x) std(abs(x),'omitnan'),diff_array);
    T2 = table(OutputDiff,VarIndex, DiffSum, DiffAvg, DiffStd);
    
   T3 = [T1 T2];

    b = sscanf(a1{i},'Hourly_model_%d_%d_%d');
    parname_save = ['Hourly_model_diff_' num2str(b(1)) '_' num2str(b(2)) '_' num2str(b(3))];
    assignin('base',parname_save,T3)
   
end
clear(a1{:},a2{:}) 

filename_save = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Hourly_model_diff_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
a3 = who('Hourly_model_diff_*');
save(filename_save,a3{:})

clear(a3{:})
%% merge_hourly_result
filename1 = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Hourly_model_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
filename2 = ['Hourly_input_adjust_' num2str(year) '_' num2str(iPlant) '.mat'];

mat1 = matfile(filename1); mat2 = matfile(filename2);
a1 = who(mat1); a2 = who(mat2);

load(filename1,a1{1}); load(filename2,a2{1});
model_array = eval(a1{1}); input_array = eval(a2{1});

T1_col = [2 11 12 15:17]; D1_col = [2 7:9];
T1 = model_array(:,T1_col); D1 = input_array(:,D1_col);

%T1 = TimeStamp, ClearNumGHI, ClearNumDNI, OutputSum, OutputAvg, OutputStd.
%D1 = TimeStamp, DataSum,DataAvg,DataStd.
clear(a1{1},a2{1})

for i = 2:length(a1)
    i
    load(filename1,a1{i}); load(filename2,a2{i});
model_array = eval(a1{i}); input_array = eval(a2{i});
T1 = [T1; model_array(:,T1_col)];
D1 =  [D1; input_array(:,D1_col)];
clear(a1{i},a2{i})

end

 filename_save = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Model_result_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
    if ~exist(filename_save)
        save(filename_save,'D1','T1')
    else
        save(filename_save,'D1','T1','-append')
    end
    
%% merge variability

filename1 = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Hourly_model_diff_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
filename2 = ['Hourly_input_diff_' num2str(year) '_' num2str(iPlant) '.mat'];

mat1 = matfile(filename1); mat2 = matfile(filename2);
a1 = who(mat1); a2 = who(mat2);

load(filename1,a1{1}); load(filename2,a2{1});
model_array = eval(a1{1}); input_array = eval(a2{1});

% T2_col = [2 3 4 8:11]; D2_col = [2 7:10];
T2_col = {'TimeStamp', 'ClearNumGHI','ClearNumDNI','VarIndex','DiffSum','DiffAvg','DiffStd'};
D2_col = {'TimeStamp', 'VarIndex','DiffSum','DiffAvg','DiffStd'};
T2 = model_array(:,T2_col); 
D2 = input_array(:,D2_col); %[2 8:10] [2 5:7]
% T2 = TimeStamp, ClearNumGHI,ClearNumDNI,VarIndex,DiffSum,DiffAvg,DiffStd
% D2 = TimeStamp, VarIndex,DiffSum,DiffAvg,DiffStd
clear(a1{1},a2{1})
for i = 2:length(a1)
    i
    load(filename2,a2{i});input_array = eval(a2{i});
    load(filename1,a1{i}); 
model_array = eval(a1{i}); 
    
T2 = [T2; model_array(:,T2_col)];
D2 =  [D2; input_array(:, D2_col)];
clear(a1{i},a2{i})
end

 filename_save = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Model_result_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
        save(filename_save,'D2','T2','-append')
        clear('D2','T2')

%% stats
KSI_percent = KSI_4sec_diff(iPlant,year,mPlant,vers,foldername);

 [RMSE, NRMSE,MBD] = hourly_result_stat(D1,T1)
 
 filename_save = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Stat_result_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant)];
 save(filename_save,'RMSE','NRMSE','MBD','KSI_percent')
 
 clear('D1','T1')
end


 
 