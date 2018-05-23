function uvs = driver_uvabs(datadir)

%,vf,acc,bv,y)

% Driver function for UV speed tests
% datadir: path to para/perp folders

% Build directory structures of all of the uv files
ad = pwd;
paradir = fullfile(datadir,'para');
perpdir = fullfile(datadir,'perp');
cd(paradir)
dd_para = dir('*.txt');
cd(ad)
cd(perpdir)
dd_perp = dir('*.txt');
cd(ad)

% Trim to the minimum number of spectra in either folder
num_files = min(length(dd_para),length(dd_perp));
dd_para = dd_para(1:num_files);
dd_perp = dd_perp(1:num_files);
uvs = dd_para;

for i = 1:length(uvs)
    
    % Load parallel and perpendicular spectra files
    disp([num2str(i), ' of ', num2str(length(uvs))])
    uvs(i).para_path = fullfile(paradir,dd_para(i).name);
    uvs(i).perp_path = fullfile(perpdir,dd_perp(i).name);
    [uvs(i).waves_para, uvs(i).abs_para] = importUV(uvs(i).para_path);
    [uvs(i).waves_perp, uvs(i).abs_perp] = importUV(uvs(i).perp_path);
    
end

save('uvdebug','dd')

% Identify wavelengths of interest
wmin_ind = find(uvs(1).waves_para>=wmin,1);
wmax_ind = find(uvs(1).waves_para>=wmax,1);



% Plot some figures to find start/end spectra
figure;plot([uvs(:).DC])
wavemat=[uvs(:).abs_para];wavestart=find(uvs(1).waves_para>400,1);
figure; pc=pcolor(wavemat(wavestart:end,:)); pc.EdgeAlpha=0;

save(fullfile(datadir,'uvs'),'uvs')