function uvs = insitu_refl_fig(datadir,spec_start,spec_stop)

% datadir = 'data/171222_n22cb20_LogHi';
% spec_start = 10;
% spec_stop = 450;

if exist('spec_start')~=1
    spec_start = 1;
end

if exist('spec_stop')~=1
    spec_stop = 1E6;
end

% wave_start: wavelength below which to truncate the garbage spectrum
wave_start = 375;
% wmin/wmax: wavelengths (nm) over which to calculate the dichroic ratio
wmin=570; wmax=590;

% Load data
if exist(fullfile(datadir,'uvs.mat'))==2
    load(fullfile(datadir,'uvs.mat'))
    if spec_stop>length(uvs)
        spec_stop=length(uvs);
    end
else
    uvs = load_uvrefl(datadir);
    spec_stop = length(uvs);
end


% Identify wavelengths of interest
wave_start_ind = find(uvs(1).waves_para>=wave_start,1);
wmin_ind = find(uvs(1).waves_para>=wmin,1)-wave_start_ind;
wmax_ind = find(uvs(1).waves_para>=wmax,1)-wave_start_ind;

% Calculate Dichroic Ratio and "Film Thickness"
for i = 1:length(uvs)
    
    uvs(i).refl_para_trim = uvs(i).refl_para(wave_start_ind:end)./100;
    uvs(i).refl_perp_trim = uvs(i).refl_perp(wave_start_ind:end)./100;
    uvs(i).refl_para_trim(uvs(i).refl_para_trim<=0) = 0.001;
    uvs(i).refl_perp_trim(uvs(i).refl_perp_trim<=0) = 0.001;
    uvs(i).waves_para_trim = uvs(i).waves_para(wave_start_ind:end);
    uvs(i).waves_perp_trim = uvs(i).waves_perp(wave_start_ind:end);
    
    uvs(i).abs_para = -log(uvs(i).refl_para_trim);
    uvs(i).abs_perp = -log(uvs(i).refl_perp_trim);
    uvs(i).SumAbs = uvs(i).abs_para + uvs(i).abs_perp;
    uvs(i).aniso = (uvs(i).abs_para - uvs(i).abs_perp) ./ ...
                   uvs(i).SumAbs;
    
    abs_peak_para = uvs(i).abs_para(wmin_ind:wmax_ind);
    abs_peak_perp = uvs(i).abs_perp(wmin_ind:wmax_ind);

    uvs(i).DC = mean( ...
                (abs_peak_perp - abs_peak_para) ./ ...
                (abs_peak_perp + abs_peak_para) ...
                );
            
    uvs(i).thick = mean(abs_peak_perp) + mean(abs_peak_para);
    
end

% Hard coded plot settings
font=12;
line=1;

% Plot 'Film Thickness'
f=figure;
subplot(4,1,1);
pt = plot([uvs(spec_start:spec_stop).thick]);
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
perpmat = [ uvs(spec_start:spec_stop).abs_perp ];
anisomat = [ uvs(spec_start:spec_stop).aniso ];

absmax = max( max(paramat(:)), max(perpmat(:)) );

% % Plot Anisotropy
% subplot(4,1,2);
% pc3=pcolor(anisomat);
% pc3.EdgeAlpha=0;
% % Create colormap that is green for negative, red for positive,
% % and a chunk inthe middle that is black.
% greenColorMap = [zeros(1, 132), linspace(0, 1, 124)];
% redColorMap = [linspace(1, 0, 124), zeros(1, 132)];
% colorMap = [redColorMap; greenColorMap; zeros(1, 256)]';
% % Apply the colormap.
% colormap(colorMap);
% ax1=gca; ax1.FontSize=font; ax1.Visible='off';  caxis(ax1,[-1 1]);

subplot(4,1,3);
pc = pcolor(perpmat./absmax);
pc.EdgeAlpha=0;
ax2=gca; ax2.FontSize=font; ax2.Visible='off'; caxis(ax2,[0 1]);


subplot(4,1,4);
pc2=pcolor(paramat./absmax);
pc2.EdgeAlpha=0;
ax3=gca; ax3.FontSize=font; ax3.Visible='off';  caxis(ax3,[0 1]);

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