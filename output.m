classdef output
    methods(Static)
        function save_figure(fig, comp_names, full_file_name)
            if (~exist('full_file_name', 'var'))
                [file_name, path_name]  = uiputfile({'*.png'; '*.fig'}, 'Select file to save');
                if(~file_name)
                    return;
                end
                full_file_name         = [path_name file_name];
            end

            [~,~,type] = fileparts(full_file_name);
            
            if strcmp(type,'.fig') 
                temp_fig = figure('position', [-10000 -10000 800 600]);
            else
                temp_fig = figure('visible', 'off', 'position', [-10000 -10000 800 600],'units','normalized','outerposition',[0 0 1 1]);
            end

            copyobj(fig, temp_fig);
            comp_names = strrep(strrep(comp_names, '_x_', ' & '),'_',' ');


            if strcmp(type,'.fig') 
                legend(char(comp_names), 'Location', 'Best');
                saveas(temp_fig, full_file_name);
            elseif strcmp(type, '.png')
                set(findobj(temp_fig, 'Type', 'Line', 'Linestyle', '-'), 'LineWidth', 8);
                set(findobj(temp_fig, 'Type', 'Line', 'Linestyle', '-'),  'Marker','o')
                set(findobj(temp_fig, 'Type', 'Line', 'Linestyle', '-'),  'MarkerSize',.3)
                set(findobj(temp_fig, 'Type', 'Line', 'Linestyle', '--'), 'LineWidth', 6);
                set(findobj(gca, 'Type', 'Line', 'Linestyle', 'none'),  'LineWidth', 2);
                set(findobj(gca, 'Type', 'Line', 'Linestyle', 'none'),  'MarkerSize', 10);
                set(gca, 'LineWidth', 3);
                set(gca, 'FontSize', 40) 
                h=get(gca,'xlabel');
                set(h, 'FontSize', 40) 
                h=get(gca,'ylabel');
                set(h, 'FontSize', 40) 
                h=get(gca,'title');
                set(h, 'FontSize', 40) 
                set(gca,'YLim',[-inf inf])
%               title(gca, '');
                legend(gca,'off');

                set(temp_fig, 'PaperUnits', 'inches', 'PaperPosition', [0 0 20 15]);
                legend(char(comp_names), 'Location', 'Best');
                try
                    print(temp_fig, '-dpng', '-r300', full_file_name);
                catch
%                     set(findobj(gca, 'Type', 'Area', 'Linestyle', 'none'),  'facealpha',1);
% 
%                     print(temp_fig, '-dpng', '-r300', full_file_name);
                end


            end
            close(temp_fig);
        end

        
        function save_figure2(fig, full_file_name)
            if (~exist('full_file_name', 'var'))
                [file_name, path_name]  = uiputfile({'*.png';'*.fig'}, 'Select file to save');
                if(~file_name)
                    return;
                end

                full_file_name         = [path_name file_name];

            end
            [~,~,type] = fileparts(full_file_name);

            if strcmp(type,'.fig') 
             temp_fig = figure('position', [-10000 -10000 800 600]);
            else
                temp_fig = figure('visible','off');
            end
            copyobj(fig, temp_fig);

            axis = findobj(fig,'type','axe');

            if strcmp(get(get(axis, 'ylabel'), 'string'), 'BF')
                legend(['BF_{10}'; 'BF_{01}']);
            end

            if strcmp(type,'.fig') 
                saveas(temp_fig, full_file_name);
            elseif strcmp(type, '.png')
                set(findobj(temp_fig, 'Type', 'Line', 'Linestyle', '-'), 'LineWidth', 8);
                set(findobj(temp_fig, 'Type', 'Line', 'Linestyle', '-'),  'Marker','o')
                set(findobj(temp_fig, 'Type', 'Line', 'Linestyle', '-'),  'MarkerSize',.3)
                set(findobj(temp_fig, 'Type', 'Line', 'Linestyle', '--'), 'LineWidth', 6);
                set(findobj(gca, 'Type', 'Line', 'Linestyle', 'none'),  'LineWidth', 2);
                set(findobj(gca, 'Type', 'Line', 'Linestyle', 'none'),  'MarkerSize', 10);
                set(gca, 'LineWidth', 3);
                set(gca, 'FontSize', 40) 
                h=get(gca,'xlabel');
                set(h, 'FontSize', 40) 
                h=get(gca,'ylabel');
                set(h, 'FontSize', 40) 
                h=get(gca,'title');
                set(h, 'FontSize', 40) 
                set(gca,'YLim',[-inf inf])
                set(temp_fig, 'PaperUnits', 'inches', 'PaperPosition', [0 0 20 15]); %
                print(temp_fig, '-dpng', '-r300', full_file_name);
            end
            close(temp_fig);
        end

        
        function save_csv_header2(data_analyzed, full_file_name, mrd)
            comp_names = fieldnames(data_analyzed);
            max_trail = 0;
            for i=1:size(comp_names, 1)
                max_trail = max(max_trail, size(data_analyzed.(char(comp_names(i))).cuted_data, 2));
             end

            
            fid = fopen(full_file_name, 'w') ;
            if ~mrd
                fprintf(fid, 'subject,#,condition,') ;
            else
                fprintf(fid, 'subject,condition,');
            end
            for i=1:max_trail
                fprintf(fid, '%s,', num2str(i)) ;
             end
            fprintf(fid, '\n') ;
            fclose(fid) ;
        end

        function save_csv_header(comp_names, full_file_name)
            
            comp_names_fixed = cellfun(@(x) x(3:end), comp_names, 'UniformOutput', false);
            comp_names_fixed = strrep(strrep(comp_names_fixed, '_x_', ' & '),'_',' ');

            fid = fopen(full_file_name, 'w') ;
            fprintf(fid, ',bin,time(ms),') ;
            for i=1:size(comp_names_fixed, 1)
                fprintf(fid, '%s,', comp_names_fixed{i}) ;
             end
            fprintf(fid, '\n') ;
            fclose(fid) ;
        end

        
        function save_csv_header4(full_file_name, num_of_conds)
            conds_str = '';
            for i=1:num_of_conds
                conds_str = strcat(conds_str, ',c', num2str(i));
            end
             
            fid = fopen(full_file_name, 'w') ;
            fprintf(fid, 'subject,trial_id,mean,max,min,first_bin,last_bin,mean_blinks,num_of_blinks\n');
            fclose(fid) ;
        end
        
        function save_csv(data_analyzed, var_data_table, configuration, cond_ids, full_file_name, participant_id, rate)
            comp_names = fieldnames(data_analyzed);

            output.save_csv_header(comp_names, full_file_name);
            output.save_csv_append(data_analyzed, full_file_name, participant_id);
            
            [folder, file_name, ext]   = fileparts(full_file_name);

            full_mrd2_file_name =  [folder, filesep, file_name, '_trials_data', ext];


            data.var_data_table = var_data_table;
            data.printed_data   = data_analyzed;
            data.file_name      = file_name;
            data.configuration  = configuration;

            single_var_data_table = output.save_csv_append4(data, cond_ids, rate);
            writetable(single_var_data_table, full_mrd2_file_name);
        end

        function var_data_table = save_csv_append4(single_data, cond_ids, rate)
            participant_id = repmat({single_data.file_name}, size(single_data.var_data_table, 1), 1);
            trial_id = [1:size(single_data.var_data_table, 1)]';
            single_data.var_data_table = [table(participant_id), table(trial_id), single_data.var_data_table];            

            data_analyzed = single_data.printed_data;
            
            comp_names = fieldnames(data_analyzed);
            comp_names_fixed = cellfun(@(x) x(3:end), comp_names, 'UniformOutput', false);
            comp_names_fixed = strrep(strrep(comp_names_fixed, '_x_', ','),'_',' ');
            
            max_trail = 0;
        
            for i=1:size(comp_names_fixed, 1)
                max_trail = max(max_trail, size(data_analyzed.(char(comp_names(i))).pupil, 1));
             end

            single_data.var_data_table.trial_mean = NaN(size(single_data.var_data_table, 1), 1);
            single_data.var_data_table.trial_max  = NaN(size(single_data.var_data_table, 1), 1);
            single_data.var_data_table.trial_min  = NaN(size(single_data.var_data_table, 1), 1);
            single_data.var_data_table.first_bin  = NaN(size(single_data.var_data_table, 1), 1);
            single_data.var_data_table.last_bin   = NaN(size(single_data.var_data_table, 1), 1);
            
            single_data.var_data_table.valid_blinks = zeros(size(single_data.var_data_table, 1), 1);
            single_data.var_data_table.blinks_mean  = zeros(size(single_data.var_data_table, 1), 1);

            from_event = single_data.configuration.from_val;
            to_event   = single_data.configuration.to_val;

            relevant_trials = zeros(size(single_data.var_data_table, 1), 1);
            for comp=1:size(comp_names_fixed, 1)  
                relevant_trials(cond_ids.(char(comp_names(comp))))=1;
                 for trial=1:size(data_analyzed.(char(comp_names(comp))).cuted_data, 2)
                    
                    trial_id = cond_ids.(char(comp_names(comp)))(trial);
                    
                    min_trial_length = min(size(data_analyzed.(char(comp_names(comp))).cuted_data,1), max_trail);

                    single_data.var_data_table.trial_mean(trial_id) = nanmean(data_analyzed.(char(comp_names(comp))).cuted_data(1:min_trial_length, trial));
                    
                    single_data.var_data_table.trial_max(trial_id)  = nanmax(data_analyzed.(char(comp_names(comp))).cuted_data(1:min_trial_length, trial));
                    single_data.var_data_table.trial_min(trial_id)  = nanmin(data_analyzed.(char(comp_names(comp))).cuted_data(1:min_trial_length, trial));
                    
                    trial_data = data_analyzed.(char(comp_names(comp))).cuted_data(1:min_trial_length, trial);
                    nonnan_trial_data = trial_data(~isnan(trial_data));
                    first_bin = nan;
                    last_bin  = nan;
                    if ~isempty(nonnan_trial_data)
                        first_bin = nonnan_trial_data(1);
                        last_bin  = nonnan_trial_data(end);
                    end
                    single_data.var_data_table.first_bin(trial_id) = first_bin;
                    single_data.var_data_table.last_bin(trial_id) = last_bin;
                    
                    blinks_data = data_analyzed.(char(comp_names(comp))).blinks{trial};
                   
                    total_dur = 0;
                    blink_pos = 1;
                    valid_blinks = 0;

                    while (blink_pos<size(blinks_data, 2)) 
                        if blinks_data(blink_pos)<single_data.var_data_table.(char(strcat('event_',from_event)))(trial_id)  - (single_data.configuration.PreEventNumber_val)/(1000/rate) || blinks_data(blink_pos)>single_data.var_data_table.(char(strcat('event_', to_event)))(trial_id)
                            blink_pos = blink_pos + 2;
                            continue;
                        end
                        blink_duration = (1000/rate)*(blinks_data(blink_pos+1)-blinks_data(blink_pos));
                        if blink_duration > 100 && blink_duration < 400 % && 1000/rate*(blinks_data(blink_pos+1))<2120 && 1000/rate*(blinks_data(blink_pos+1))>1070
                            total_dur = total_dur + blink_duration;
                            valid_blinks = valid_blinks + 1;
                        end
                        blink_pos = blink_pos + 2;
                    end
                    if (valid_blinks>0)
                        blinks_mean = total_dur/valid_blinks;
                    else
                        blinks_mean = NaN;
                    end
                    single_data.var_data_table.valid_blinks(trial_id) = valid_blinks;
                    single_data.var_data_table.blinks_mean(trial_id)  = blinks_mean;
                 end
            end
            single_data.var_data_table = single_data.var_data_table(find(relevant_trials>0), :);
            var_data_table = single_data.var_data_table;
            variable_names = var_data_table.Properties.VariableNames;
            events     = find(~cellfun(@isempty, strfind(variable_names,'event_')));
            for event = 1:length(events)
                var_data_table{:,events(event)} = round(table2array(var_data_table(:,events(event)))*(1000/rate));
            end

        end
        
       
        
        function save_csv_append(data_analyzed, full_file_name, participant_id)
            comp_names = fieldnames(data_analyzed);
            comp_names_fixed = cellfun(@(x) x(3:end), comp_names, 'UniformOutput', false);
            comp_names_fixed = strrep(strrep(comp_names_fixed, '_x_', ' & '),'_',' ');
            max_trail = 0;
            x_axis = [];
            fid = fopen(full_file_name, 'a+') ;
            for i=1:size(comp_names_fixed, 1)
                max_trail = max(max_trail, size(data_analyzed.(char(comp_names(i))).pupil, 1));
                if length(x_axis) < length(data_analyzed.(char(comp_names(i))).x_axis)
                    x_axis = round(data_analyzed.(char(comp_names(i))).x_axis);
                end
            end
            
            for bin=1:max_trail    
                fprintf(fid, '%s,%d,%d,', participant_id, bin, x_axis(bin)) ;
                for comp=1:size(comp_names_fixed, 1)
                    if size(data_analyzed.(char(comp_names(comp))).pupil, 1) >=bin
                        fprintf(fid, '%s,', num2str(data_analyzed.(char(comp_names(comp))).pupil(bin)));
                    end
                    
                end
                fprintf(fid, '\n');
            end
            fclose(fid) ;
        end
        
        function save_output(src, full_file_name)

            data = guidata(src);
            
            participant_id = data.file_name;
            if (~exist('full_file_name', 'var'))
                [file_name ,path_name] = uiputfile({'*.csv';'*.mat'}, 'Select file to save', participant_id);
                full_file_name         =     [path_name file_name];
                if(~file_name)
                    return;
                end
            end
            
            [~, ~, ext]   = fileparts(full_file_name);
            
            data_analyzed = data.analyzed_data;

            if strcmp(ext, '.mat')
                comp_names = fieldnames(data_analyzed);
                data_analyzed.rate = data.rate;
                data_analyzed.min_trials = data.min_trials;

                for i = 1:size(comp_names,2)
                    comp = char(comp_names(i));
                    data_analyzed.(char(comp)).outliers    = data.outliers.(char(comp));
                    data_analyzed.(char(comp)).valid_trials = data.valid_trials.(char(comp));
                end

                save(full_file_name, 'data_analyzed');
            end
            if strcmp(ext, '.csv')
                cond_ids = data.cond_ids;
                output.save_csv(data_analyzed, data.var_data_table, data.configuration, cond_ids, full_file_name, participant_id, data.rate);
            end
        end
        
    end
end

