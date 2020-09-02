clear
% -------------------------------------------------------------------------
% define folders, input and output names
% -------------------------------------------------------------------------
study_folder                        = 'D:\OSF\Main';
memtoolbox_folder                   = [study_folder '/visionlab-MemToolbox-fea8609'];
loadfolder_suffix                   = 'Preprocessed';
outfolder_suffix                    = 'MM_Out';

infile_name_mm                      = '%s%i_mm_data.mat';
infile_name_mm_acrossval            = '%s%i_mm_data_acrossval.mat';
infile_name_mm_perm                 = '%s%i_mm_permlist.mat';
infile_name_mm_perm_acrossval       = '%s%i_mm_permlist_acrossval.mat';

outfile_name_mm                     = '%s%i_mm.txt';
outfile_name_mm_acrossval           = '%s%i_mm_acrossval.txt';
outfile_name_mm_perm                = '%s%i_mm_perm.txt';
outfile_name_mm_perm_acrossval      = '%s%i_mm_perm_acrossval.txt';
% -------------------------------------------------------------------------
% add MemToolbox, create folders if necessary
% -------------------------------------------------------------------------
addpath(genpath(memtoolbox_folder))
loadfolder  = sprintf('%s\\%s\\',study_folder,loadfolder_suffix);
outfolder   = sprintf('%s\\%s\\',study_folder,outfolder_suffix);
if~exist(outfolder,'dir')
    mkdir(outfolder)
end
% -------------------------------------------------------------------------
% Params
% -------------------------------------------------------------------------
subject_list    = [1:10 12:15];
do_observed     = 1;
do_perm         = 1;
nperm           = 10000;
conditions      = {'validity', 'across_val'}; 
%--------------------------------------------------------------------------
% Modelling Observed Values
% -------------------------------------------------------------------------
if do_observed
    fprintf('Start modelling observed data...\n')
    for cond = conditions
        fprintf('Start modelling the following condition: %s...\n',char(cond))
        for iSub = subject_list
            fprintf('Subject %.0d',iSub)
            tic
            rng(iSub); % set seed 
            % -------------------------------------------------------------
            % Load data
            % -------------------------------------------------------------
            if strcmp(cond,'validity')
                load(sprintf(infile_name_mm,loadfolder, iSub))   
                nloops = 40;
            elseif strcmp(cond,'across_val')
                load(sprintf(infile_name_mm_acrossval,loadfolder,iSub))
                nloops = 20;
            end
            % -------------------------------------------------------------
            % Prepare fitting
            % -------------------------------------------------------------
            % bring data into correct format for MemFit parallel processing
            % requires cell array with one struct for each single subject/soa
            name = fieldnames(d);
            for i = 1:nloops
                data{i}.errors = d.(name{i});            
            end
            % -------------------------------------------------------------
            % MM Fitting
            % -------------------------------------------------------------
            MLEfit = FitMultipleSubjects_MLE(data,StandardMixtureModel);
            % -------------------------------------------------------------
            % Write into textfile for further analysis in R
            % -------------------------------------------------------------
            % open file
            if strcmp(cond,'validity')
                fid         = fopen(sprintf(outfile_name_mm,outfolder,iSub),'w');
            elseif strcmp(cond,'across_val')
                fid         = fopen(sprintf(outfile_name_mm_acrossval,outfolder,iSub),'w');
            end
            % write header
            fprintf(fid,'%6s %6s\n','g','sd');
            % write params
            for loop = 1:length(MLEfit.paramsSubs)
                fprintf(fid,'%i %i\n', MLEfit.paramsSubs(loop,1), MLEfit.paramsSubs(loop,2));
            end
            % close file
            fclose(fid);
            clear data name
            fprintf(' finished. Modelling took %.0d Seconds...\n',round(toc))
        end
    end
end
% -------------------------------------------------------------------------
% Modelling Permutations
% -------------------------------------------------------------------------
if do_perm
    fprintf('Start modelling permuted data...\n')
    for cond = conditions
        fprintf('Start modelling the following condition: %s...\n',char(cond))
        for iSub = subject_list
            fprintf('Subject %.0d',iSub)
            tic
            rng(iSub); % reproducible seed to be able to reproduce findings
            % -------------------------------------------------------------
            % load data
            % -------------------------------------------------------------
            if strcmp(cond,'validity')
                load(sprintf(infile_name_mm_perm,loadfolder, iSub))   
                nloops = 40;
            elseif strcmp(cond,'across_val')
                load(sprintf(infile_name_mm_perm_acrossval,loadfolder,iSub))
                nloops = 20;
            end
            % -------------------------------------------------------------
            % Prepare fitting
            % -------------------------------------------------------------
            % bring data into correct format for MemFit parallel processing
            % requires a cell array with a struct for each single subject /soa
            name = fieldnames(perms);
            for j = 1:nperm
                for i = 1:nloops
                    s.errors = perms.(name{j})(:,i);  
                    data{i+(j-1)*nloops} = s;            
                end
            end
            % -------------------------------------------------------------
            % MM Fitting
            % -------------------------------------------------------------
            fitMLE = FitMultipleSubjects_MLE(data,StandardMixtureModel);
            % -------------------------------------------------------------
            % Write into textfile for further analysis in R
            % -------------------------------------------------------------
            % open file
            if strcmp(cond,'validity')
                fid = fopen(sprintf(outfile_name_mm_perm,outfolder,iSub),'w');
            elseif strcmp(cond,'across_val')
                fid = fopen(sprintf(outfile_name_mm_perm_acrossval,outfolder,iSub),'w');
            end
            % write header
            fprintf(fid,'%6s %6s\n','g','sd');
            % write params
            for iter = 1:length(fitMLE.paramsSubs)
                fprintf(fid,'%i %i\n',fitMLE.paramsSubs(iter,1),fitMLE.paramsSubs(iter,2));
            end
            % close file
            fclose(fid);
            clear data name
            fprintf('...finished. Modelling took %.0d Seconds...\n',round(toc))
        end
    end
end

disp('Done.')