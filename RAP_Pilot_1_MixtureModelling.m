clear
% -------------------------------------------------------------------------
% define folders, input and output names
% -------------------------------------------------------------------------
study_folder                        = 'C:\Data\OSF_public\Pilot';
memtoolbox_folder                   = [study_folder '/visionlab-MemToolbox-fea8609'];

loadfolder_suffix                   = 'Preprocessed';
outfolder_suffix                    = 'MM_Out';

infile_name_mm                      = '%s%i_mm_data.mat';
outfile_name_mm                     = '%s%i_mm.txt';
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
subject_list    = [1:9 12:16];
%--------------------------------------------------------------------------
% Modelling
% -------------------------------------------------------------------------
fprintf('Start modelling data...\n')
for iSub = subject_list
    fprintf('Subject %.0d',iSub)
    tic
    rng(iSub); % set seed
    % -----------------------------------------------------------------
    % Load data
    % -----------------------------------------------------------------
    load(sprintf(infile_name_mm,loadfolder, iSub))   
    nloops          = 6;
    name            = fieldnames(d);
    % -----------------------------------------------------------------
    % Prepare fitting
    % -----------------------------------------------------------------
    % bring data into correct format for MemFit parallel processing
    % requires a cell array with a struct for each single subject /soa
    for i = 1:nloops
        data{i}.errors = d.(name{i});            
    end

    % -----------------------------------------------------------------
    % MM fitting
    % -----------------------------------------------------------------
    MLEfit = FitMultipleSubjects_MLE(data,StandardMixtureModel);
    % -----------------------------------------------------------------
    % Write into textfile for further analysis in R
    % -----------------------------------------------------------------
    fid         = fopen(sprintf(outfile_name_mm,outfolder,iSub),'w');

    % write header
    fprintf(fid,'%6s %6s\n','g','sd');
    % write params
    for loop = 1:length(MLEfit.paramsSubs)
        fprintf(fid,'%i %i\n', MLEfit.paramsSubs(loop,1), MLEfit.paramsSubs(loop,2));
    end
    % close file
    fclose(fid);
    clear data g sd name
    fprintf(' finished. Modelling took %.0d Seconds...\n',ceil(toc))
end


disp('Done.')