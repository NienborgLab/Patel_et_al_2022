% This creates the subplots for Figure 1.
close all

% Get the 'relative' folder path to get the resource folderpath
path = mfilename( 'fullpath' );

if ispc % Windows file system
    parts = strsplit(path, '\');
else
    parts = strsplit(path, '/');
end

root_path = strjoin(parts(1:end-2), '/');

% For data
data_path = [root_path, '/resources/Data/'];

addpath(genpath([root_path, '/helper_code'])) % Plotting helper functions

%% Create the subplot folder if needed, save figures there
save_path = [strjoin(parts(1:end-2), '/'), '/resources/Figure_1/subplots/'];

if ~exist(save_path, 'dir') % Check if folder exists
    mkdir(save_path)
end
addpath(save_path)

%% Plot example baseline LFP and single unit recording
% Plots session ka_258 baseline data, trial 20
visualize_lfp_spk()

% Give the figure window a name to distinguish it
set(gcf, 'name', 'ka_258_20_base');

% Obtain the last created figure handle
figHandles = findobj('Type', 'figure');

% Save the figure
savefig(figHandles(1), [save_path '/ka_258_20_base.fig'])

%% Plot example drug LFP and its single unit recording

% Load the data
load([data_path, '/LFPprepro/filtered/ka_0258_c1_sortLH_17.33.grating.ORxRC_5HT.mat']);
        
% Plots session ka_258 5HT data, trial 20
visualize_lfp_spk(ex, 'r');

% Give the figure window a name to distinguish it
set(gcf, 'name', 'ka_258_20_drug');

% Obtain the last created figure handle
figHandles = findobj('Type', 'figure');

% Save the figure
savefig(figHandles(1), [save_path '/ka_258_20_5HT.fig'])

%% Plot the mean firing rate plot

% Load the LFP data
load([data_path, '/Lfps_pair/Lfps_rc.mat']);

% Process the LFP data into a usable analysis table
anaT = analysis_table(Lfps, 'drug');

% Plot the mean firing rates of baseline condition against drug condition
plot_vars(anaT, 'fr base', 'fr drug');

% Remove p-val significance marker from the plot
fig = gcf;
delete(fig.Children(1).Children(2))
delete(fig.Children(1).Children(1))

% Obtain the last created figure handle
figHandles = findobj('Type', 'figure');

% Save the figure
savefig(figHandles(1), [save_path '/fr.fig'])


%% Plot the Gain Change

% Load, process, and analysis the data to plot gain change
plot_gain_change();

% Give the figure window a name to distinguish it
set(gcf, 'name', 'gain_change');

figHandles = findobj('Type', 'figure');

% Save the figure
savefig(figHandles(1), [save_path '/gain_change.fig']);

%% Plot the microsaccade comparisons - Figure 1 D & E

% Load the data file
load([data_path, '/microsaccades/summary_microsaccades.mat'])

% plotting the microsaccade comparisons
cols = [1 0 0; 0 0 0];
mrcs = {'s', 'o'};
msz = {15, 8};
a = cell(2,2);


% data groups
a{1,1} = [res.uniqueSession]==true & [res.serotonin]==true & [res.animal]==true;
a{1,2} = [res.uniqueSession]==true & [res.serotonin]==true & [res.animal]==false; % ma
a{2,1} = [res.uniqueSession]==true & [res.serotonin]==false & [res.animal]==true;
a{2,2} = [res.uniqueSession]==true & [res.serotonin]==false & [res.animal]==false; % ma

figure;
set(findall(gcf,'-property','FontName'),'FontName','Arial')
set(findall(gcf,'-property','fontsize'),'fontsize',6)
subplot('position',[.1 .2 .3 .3])
for n=1:2 % drug
    for n2 = 1:2 % animal
        
        scatter(gca,[res(a{n,n2}).msAmp_control],[res(a{n,n2}).msAmp_drug], ...
            msz{n2},'marker',mrcs{n2},'markerfacecolor',cols(n,:),...
            'markeredgecolor',cols(n,:),'markerfacealpha', 0.4, 'linewidth', 0.05);
        hold on;
    end
end

axis square
offsetAxes
set(gca,'box','off','tickdir','out','xlim',[.15 .55],'ylim',[.15 .55],'xtick',[.2:.1: .5],'ytick',[.2:.1:.5])
range = [.2 .55];
plot(range,range,'-','color',[.5 .5 .5])

title('microsaccade amplitude\newline               (dva)')
xlabel baseline
ylabel drug

% Microsaccade frequencies plot

subplot('position',[.45 .2 .3 .3])
for n=1:2 % drug
    for n2 = 1:2 % animal
        
        scatter(gca,[res(a{n,n2}).msFreq_control],[res(a{n,n2}).msFreq_drug], ...
            msz{n2},'marker',mrcs{n2},'markerfacecolor',cols(n,:),...
            'markeredgecolor',cols(n,:),'markerfacealpha', 0.4, 'linewidth', 0.05);
        hold on;
    end
end

axis square
set(gca,'box','off','tickdir','out','xtick',[0, 1:2],'ytick',[0, 1 :2],'xlim',[-0.2 2.8],'ylim',[-0.2 2.8])
offsetAxes
range = [0 2.8];
plot(range,range,'-','color',[.5 .5 .5])
set(gca,'xticklabel',[{''},{'1'},{'2'}],'yticklabel',[{''},{'1'},{'2'}])
title('microsaccade frequency\newline                (Hz)')
xlabel('baseline')

savefig(gcf, [save_path '/micro_sac.fig'])
