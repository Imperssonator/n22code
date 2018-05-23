function dd = driver_velgrad(datadir)

%,vf,acc,bv,y)

% Driver function for velocity gradient UV
% datadir: path to raw files
% specTime: time between spectrum saving (seconds)
% slideVel: velocity at which slide was pushed under beam (mm/s)

ad = pwd;
paradir = fullfile(datadir,'para');
perpdir = fullfile(datadir,'perp');
cd(paradir)
dd_para = dir('*.txt');
cd(ad)
cd(perpdir)
dd_perp = dir('*.txt');
cd(ad)

num_files = min(length(dd_para),length(dd_perp));
dd_para = dd_para(1:num_files);
dd_perp = dd_perp(1:num_files);
dd = dd_para;

for i = 1:length(dd)
    
    % Load parallel and perpendicular spectra files
    disp([num2str(i), ' of ', num2str(length(dd))])
    dd(i).para_path = fullfile(paradir,dd_para(i).name);
    dd(i).perp_path = fullfile(perpdir,dd_perp(i).name);
    [dd(i).waves_para, dd(i).abs_para] = importUV(dd(i).para_path);
    [dd(i).waves_perp, dd(i).abs_perp] = importUV(dd(i).perp_path);
    
end

save('uvdebug','dd')

w700 = find(dd(1).waves_para>=700,1);
w705 = find(dd(1).waves_para>=705,1);

for i = 1:length(dd)
    
    abs_peak_para = mean(dd(i).abs_para(w700:w705));
    abs_peak_perp = mean(dd(i).abs_perp(w700:w705));
    
    if abs_peak_para > abs_peak_perp
        dd(i).DC = (abs_peak_para - abs_peak_perp) / ...
                    (abs_peak_para + abs_peak_perp);
    else
        dd(i).DC = (abs_peak_perp - abs_peak_para) / ...
                    (abs_peak_para + abs_peak_perp);
    end
    
end

figure;plot([dd(:).DC])
wavemat=[dd(:).abs_para];wavestart=find(dd(1).waves_para>400,1);
figure; ax=gca; pc=pcolor(wavemat(wavestart:end,:)); pc.EdgeAlpha=0;
save('uvdebug','dd')