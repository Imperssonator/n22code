datadir = 'data/171222_n22cb20_LogHi';
spec_start = 10;
spec_stop = 450;

% wmin/wmax: wavelengths (nm) over which to calculate the dichroic ratio
wmin=690; wmax=710;

% Load data
if exist(fullfile(datadir,'uvs.mat'))==2
    load(fullfile(datadir,'uvs.mat'))
    if spec_stop>length(uvs)
        spec_stop=length(uvs);
    end
else
    uvs = load_uvabs(datadir);
    spec_stop = length(uvs);
end


% Identify wavelengths of interest
wmin_ind = find(uvs(1).waves_para>=wmin,1);
wmax_ind = find(uvs(1).waves_para>=wmax,1);


% Calculate Dichroic Ratio and "Film Thickness"
for i = 1:length(uvs)
    
    abs_peak_para = mean(uvs(i).abs_para(wmin_ind:wmax_ind));
    abs_peak_perp = mean(uvs(i).abs_perp(wmin_ind:wmax_ind));

    uvs(i).DC = (abs_peak_perp - abs_peak_para) / ...
                (abs_peak_perp + abs_peak_para);
            
    uvs(i).SignalSum = abs_peak_para + abs_peak_perp;
    
end

% Hard coded plot settings
font=12;
line=1;
wavestart = find( uvs(1).waves_para>400, 1 );

% Plot 'Film Thickness'
f=figure;
subplot(4,1,1);
pt = plot([uvs(spec_start:spec_stop).SignalSum]);
pt.LineWidth=line;
ax0=gca; ax0.FontSize=font; ax0.XTickLabel={};
ylabel('Film Thickness?');

% Plot Dichroic
subplot(4,1,2);
pp=plot([uvs(spec_start:spec_stop).DC]);
pp.LineWidth=line;
ax1=gca; ax1.FontSize=font; ax1.XTickLabel={};
ax1.YLim = [floor(min([uvs(spec_start:spec_stop).DC])*10)/10, ...
            ceil(max([uvs(spec_start:spec_stop).DC])*10)/10];
ylabel('Dichroic Ratio');

% Plot pcolor of spectra
paramat = [ uvs(spec_start:spec_stop).abs_para ];
paramat = paramat(wavestart:end,:);
perpmat = [ uvs(spec_start:spec_stop).abs_perp ];
perpmat = perpmat(wavestart:end,:);
absmax = max( max(paramat(:)), max(perpmat(:)) );

subplot(4,1,3);
pc = pcolor(perpmat);
pc.EdgeAlpha=0; caxis([0 absmax]);
ax2=gca; ax2.FontSize=font; ax2.Visible='off';


subplot(4,1,4);
pc2=pcolor(paramat);
pc2.EdgeAlpha=0; caxis([0 absmax]);
ax3=gca; ax3.FontSize=font; ax3.Visible='off';

% Re-align the subplots
hpc = 0.24;
gap = 0.01;
top = 0.03;
hplot = (1-2*(hpc+gap)-top)/2-gap;

ax3.Position(2)=gap; ax3.Position(4)=hpc; ax3.Position(3)=1-ax3.Position(1)-0.01;
ax2.Position(2)=gap+hpc+gap; ax2.Position(4)=hpc; ax2.Position(3)=1-ax2.Position(1)-0.01;
ax1.Position(2)=gap+2*(hpc+gap); ax1.Position(4)=hplot; ax1.Position(3)=1-ax1.Position(1)-0.01;
ax0.Position(2)=gap+2*(hpc+gap)+hplot+gap; ax0.Position(4)=hplot; ax0.Position(3)=1-ax0.Position(1)-0.01;
ax1.XLim = [0, size(paramat,2)]; ax0.XLim = ax1.XLim;
f.Position = [744.2000  472.2000  491.2000  577.6000];

disp(['max. abs. = ', num2str(absmax)])