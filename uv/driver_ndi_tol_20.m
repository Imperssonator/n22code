datadir = 'data/NDI_20gL_logv';
spec_start = 29;
spec_stop = 384;

% wmin/wmax: wavelengths (nm) over which to calculate the dichroic ratio
wmin=690; wmax=710;

% Load data
if exist(fullfile(datadir,'uvs.mat'))==2
    load(fullfile(datadir,'uvs.mat'))
else
    uvs = load_uvabs(datadir);
    spec_stop = length(uvs);
end


% Identify wavelengths of interest
wmin_ind = find(uvs(1).waves_para>=wmin,1);
wmax_ind = find(uvs(1).waves_para>=wmax,1);


% Calculate Dichroic Ratio
for i = 1:length(uvs)
    
    abs_peak_para = mean(uvs(i).abs_para(wmin_ind:wmax_ind));
    abs_peak_perp = mean(uvs(i).abs_perp(wmin_ind:wmax_ind));

    uvs(i).DC = (abs_peak_perp - abs_peak_para) / ...
                (abs_peak_perp + abs_peak_para);
    
end

% Plot Hard-codes
font=14;
line=1;
wavestart = find( uvs(1).waves_para>400, 1 );

% Plot Dichroic
f=figure;
subplot(3,1,1);
pp=plot([uvs(spec_start:spec_stop).DC]);
ylabel('Dichroic Ratio');
pp.LineWidth=line;
ax1=gca; ax1.FontSize=font; ax1.XTickLabel={};
ax1.YLim = [floor(min([uvs(spec_start:spec_stop).DC])*10)/10, ...
            ceil(max([uvs(spec_start:spec_stop).DC])*10)/10];

% Plot pcolor of spectra
paramat = [ uvs(spec_start:spec_stop).abs_para ];
paramat = paramat(wavestart:end,:);
perpmat = [ uvs(spec_start:spec_stop).abs_perp ];
perpmat = perpmat(wavestart:end,:);
absmax = max( max(paramat(:)), max(perpmat(:)) );

subplot(3,1,2);
pc = pcolor(perpmat);
pc.EdgeAlpha=0; caxis([0 absmax]);
ax2=gca; ax2.FontSize=font; ax2.Visible='off';


subplot(3,1,3);
pc2=pcolor(paramat);
pc2.EdgeAlpha=0; caxis([0 absmax]);
ax3=gca; ax3.FontSize=font; ax3.Visible='off';

% Re-align the subplots
hpc = 0.33;
gap = 0.01;
hplot = 1-2*(hpc+gap)-gap-0.03;

ax3.Position(2)=gap; ax3.Position(4)=hpc; ax3.Position(3)=1-ax3.Position(1)-0.01;
ax2.Position(2)=gap+hpc+gap; ax2.Position(4)=hpc; ax2.Position(3)=1-ax2.Position(1)-0.01;
ax1.Position(2)=gap+2*(hpc+gap); ax1.Position(4)=hplot; ax1.Position(3)=1-ax1.Position(1)-0.01;
ax1.XLim = [0, size(paramat,2)];
f.Position = [744.2000 521.8000 514.4000 528.0000];

disp(['max. abs. = ', num2str(absmax)])