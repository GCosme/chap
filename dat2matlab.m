function output = dat2matlab(full_dat_name, output_folder_name, log, events2, vars2)
    clc
    
    if (~exist('log', 'var'))
        log = false;
    end
    if (~exist('events2', 'var'))
        events2 = [];
    end    
    if (~exist('vars2', 'var'))
        vars2 = [];
    end
    output = [];
    [path, file_name, ext] = fileparts(full_dat_name);
    if ~strcmpi(ext, '.dat')
        return;
    end
      
    event_csv_name = [path filesep file_name '_events.csv'];
    if ~exist(event_csv_name, 'file')
        print_log(strcat('Error (3): events file does not found, please add: ', strrep(strcat(file_name, '_events.csv') ,'_','\_') , ' to ', path), log);    
        return;
    end
    
    output_path = ['.' filesep 'mat_files'];
    if ~exist(output_path, 'dir')
        mkdir(output_path);
    end
    
    print_log(['Start load and convert DAT file: ' strrep(file_name, '_', '\_') ext], log);
    
    if exist('detectImportOptions', 'file')
        raw_data = readtable(full_dat_name, detectImportOptions(full_dat_name));
    else
        raw_data = readtable(full_dat_name, 'Delimiter', ',');
    end    

    data.timestamps = raw_data.timestamp;
    data.pupil_size = raw_data.pupil_size;
    data.pupil_x    = raw_data.pupil_x;
    data.pupil_y    = raw_data.pupil_y;
    
    print_log('Start loading pupil data', log);    
    try
        timestamps = 86400*(datenum(data.timestamps(:), 'yyyy-mm-dd HH:MM:SS.FFF')- datenum('01-Jan-1970'))';
    catch
        timestamps = 86400*(datenum(data.timestamps(:)) - datenum('01-Jan-1970'))';
    end

    data.rate = 0;
    first_index = 3;
    while data.rate==0
        first_index = first_index+1;
        data.rate   = roundn(1000/(1000*(timestamps(first_index) - timestamps(first_index-1))), 1);
    end

    data.file_name  = full_dat_name;     

    %% Get all the indexes of user's messages
    
    tic;
        
    print_log(['Adding missing samples to ' strrep(file_name, '_', '\_') ext], log);    

    [timestamps, data] = parse_data.add_missing_samples(timestamps, data);

    
    timestamps = timestamps*data.rate;

    print_log(['Finished loading messages: ' num2str(toc) ' seconds'], log);    

    %%  Get gase's information & timestamps
    tic;
    
    %% find trials
    
    
    print_log('starting loading messages', log);    
    
    try
        if exist('detectImportOptions', 'file')
            mes_data_table = readtable(event_csv_name, detectImportOptions(event_csv_name));
        else
            mes_data_table = readtable(event_csv_name, 'Delimiter', ',');
        end     
    catch
        print_log('Error (4): incompetible file, please check your file', log);    
        return;
    end
    
    print_log(['Finished loading messages: ' num2str(toc) ' seconds'], log);    

    event_msgs        = mes_data_table.message;

    event_timestamps  = data.rate*86400*(datenum(mes_data_table.timestamp)- datenum('01-Jan-1970')); % GONCALO COSME - Removed extra info it was asking. For consistency this should have a try catch

    print_log('Parsing trials', log);
    
    trial_ids = find(~cellfun(@isempty, strfind(event_msgs,'TRIALID'))); %trial is defined by message with the form TRIALID [num_of_trial]
    if(isempty(trial_ids))
        print_log('Error: trials did not found', log);
        return;
    end
    trial_data.trial_names     = cellfun(@(x) str2double(char(regexp(char(x),'\d+','match'))), event_msgs(trial_ids));        
    trial_data.Trial_Onset_num = arrayfun(@(timestamp) get_trial_data_start(timestamp, timestamps), event_timestamps(trial_ids), 'UniformOutput', false);
    
    
    Trial_Offset_ids              = ~cellfun(@isempty, strfind(event_msgs, 'TRIAL_END')); %trial is defined by message with the form TRIALID [num_of_trial]
    trial_data.Trial_Offset_num   = arrayfun(@(x) get_trial_data_start(x, timestamps), event_timestamps(Trial_Offset_ids));
   
    % GONCALO COSME
    trial_data.Trial_Onset_num(1) = {1};
    trial_data.Trial_Onset_num = cell2mat(trial_data.Trial_Onset_num);
    % end GONCALO COSME

    trial_data.trial_length    = (trial_data.Trial_Offset_num-trial_data.Trial_Onset_num);

    data.trial_data = struct2table(trial_data);
    
    data.total_var_data_table = [];
    print_log('Parsing variables', log);    
    var_ids = find(~cellfun(@isempty, strfind(event_msgs,'!V TRIAL_VAR')));

    if ~isempty(var_ids)
        total_var_data = parse_data.parse_vars(event_msgs, event_timestamps, timestamps, var_ids, trial_data.Trial_Onset_num);
        data.total_var_data_table = struct2table(total_var_data);
    end

    vars_file = strcat(path, filesep, file_name, '_vars.csv');
    if exist(vars_file, 'file')
        try
            var_data_table = parse_data.parse_external_vars(vars_file);
            data.total_var_data_table = [data.total_var_data_table, var_data_table];
        catch err
            print_log(['Error: ' err.message], log);
            return;
        end
    end
    
    if isempty(data.total_var_data_table)
        print_log('There are no variables, dummy variable is created...', log);
        dummy.dummy = repmat({'dummy'},size(trial_ids));
        data.total_var_data_table = struct2table(dummy);
    end

    print_log('Parsing events', log);    
    data.event_data = [];
    event_ids = find(~cellfun(@isempty, strfind(event_msgs,'!E TRIAL_EVENT_VAR')));
        event_full_data = event_msgs(event_ids);
        event_full_timestamps = event_timestamps(event_ids);

    if ~isempty(event_ids)
        event_data_table = parse_data.parse_events(event_full_data, event_full_timestamps, timestamps, data.trial_data.Trial_Onset_num);
        
        % GONCALO COSME EDIT FOR SAT
        % MANUALLY EDITING THE EVENT TABLE TO CORRECTLY LOAD THE EVENTS
        % SPECIFIC FOR SAT TASK
        % REQUIRES LOOKING NITO THE parse_data.parse_events, but I have no
        % time
        event_data_array = cell2mat(table2array(event_data_table));
        event_LEARN_FIXATION = event_data_array(:,1);
        event_LEARN_CS = event_data_array(:,2);
        event_LEARN_UA_SHOWPROBE = event_data_array(:,3);
        event_LEARN_UA_SHOWBLANK = event_data_array(:,4);
        event_LEARN_LEARN_FEEDBACK = event_data_array(:,5);
        event_LEARN_LEARN_INTER_TRIAL = event_data_array(:,6);

        event_data_table = table(event_LEARN_FIXATION, event_LEARN_CS, event_LEARN_UA_SHOWPROBE, event_LEARN_UA_SHOWBLANK, event_LEARN_LEARN_FEEDBACK, event_LEARN_LEARN_INTER_TRIAL);
        % end GONCALO COSME

        data.total_var_data_table = [data.total_var_data_table, event_data_table];
    end
    mm_file = strcat(path, filesep, file_name, '_mm.csv');
    if exist(mm_file, 'file')
        if exist('detectImportOptions', 'file')
            ap_data = readtable(mm_file, detectImportOptions(mm_file));
        else
            ap_data = readtable(mm_file, 'Delimiter', ',');
        end
        ap_mm     = ap_data.mm;
        ap_pixels = ap_data.pixels;
        ratio     = ap_mm/(2*sqrt(ap_pixels/pi));
        
        pupil_diameter_pixels = 2*sqrt(data.pupil_size/pi);
        pupil_diameter_mm     = pupil_diameter_pixels*ratio;
        data.pupil_size       = pupil_diameter_mm;
    end
        
    data.events2 = events2;
    data.vars2   = vars2;
    trial_data.trial_length = trial_data.Trial_Offset_num-trial_data.Trial_Onset_num;
    data.total_var_data_table.event_Trial_Offset = trial_data.trial_length;
    save([output_folder_name filesep file_name '.chp'], 'data');
    output = data;
end


function start_time = get_trial_data_start(timestamp, timestamps)
    start_time      = find(timestamp>timestamps, 1, 'last');
end
