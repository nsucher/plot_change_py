sx_input = 'lhx';
mx_input = '2';

sx_mx = [sx_input ' ' mx_input];

opscea_path = '/Users/nataliasucher/Desktop/UCSF/coding/OPSCEA/';
avg_path= [opscea_path 'OPSCEADATA/avg_change_folders/'];   %path for parameters sheet

[LL_num,LL_txt] = xlsread('sign_change_LL',sx_mx);
[em_num,em_txt] = xlsread('em_LL',sx_mx);

direction_list = LL_txt(1,1:end);
sz_list = LL_txt(2,1:end);


em_nsz=(size(em_txt,2)+2)/3;
em_szlaterality=em_txt(1,1:3:end);
em_ptsz=em_txt(2,1:3:end);
szxyz=[];



% figure('color','w','position',[779 58 892 889])

for sz_i = 1:length(sz_list)
    %SEPARATE EMNUM INTO COLUMNS OF 3 TO GET EACH ELEC MATRIX FOR EACH PTSZ
    idx=(sz_i-1)*3;
    szxyz(:,:,sz_i)=em_num(:,idx+1:idx+3);

%     nsz=(size(em_txt,2)+2)/3;
%     szlaterality=em_txt(1,1:3:end);
%     ptsz=em_txt(2,1:3:end);
%     szxyz=[];
%     for i=1:nsz
%         idx=(i-1)*3;
%         szxyz(:,:,i)=em_num(:,idx+1:idx+3);
%     end

    sz_LL = LL_num(:,sz_i);
    sz_w8s = squeeze(sz_LL);
    sz_nns = ~isnan(sz_w8s);

    pt_split = split(sz_list{sz_i},'_');
    pt = pt_split{1};
    sz = pt_split{2};

    getbrain4(pt,1,1,lower(direction_list{sz_i}))
    shading flat
% 
%     max_abs_LL_num = max([abs(max(LL_num)) abs(min(LL_num))]);
%     caxis([-max_abs_LL_num max_abs_LL_num]); %sz specific max and min for color axis
% 
%     %FIND ELECMATRIX FOR SZ
    ptpath = [avg_path pt];
    load([ptpath '/Imaging/elecs/clinical_elecs_all.mat'])
% %     em = elecmatrix;
% %     clear elecmatrix;
% % 
% %     load([ptpath '/' sz_list{sz_i} '/' sz_list{sz_i} '_badch.mat'])
% %     badch = bad_chs; 
% %     clear bad_chs; 
% %     
% %     emnan=isnan(mean(em,2)); 
% %     badch(emnan)=1; 
% %     em(emnan,:)=0; 
% % 
% % %PULL IN NO NEED AND MATCH EM(NNS) WITH W8S(NNS)
% % 
% % %define anat for noneed
% %     noneed=false(size(anat,1),4);
% %     anat_rows = size(anat,1); 
% %     badch = badch(1:anat_rows); % cut down badch to eliminate extra bad channels after anatomy rows size
% %     for num_rows=1:size(anat,1)
% %       noneed(num_rows,1) = contains(lower(anat{num_rows,4}),'ctx'); % cell array containing row index of strings with "ctx" in u1
% %       noneed(num_rows,2) = contains(lower(anat{num_rows,4}),'wm'); % cell array containing row index of strings with "wm" in u1
% %       noneed(num_rows,3) = contains(lower(anat{num_rows,4}),'white-matter'); % cell array containing row index of strings with "Right-Cerebral-White-Matter" in u1             
% %       noneed(num_rows,4) = contains(lower(anat{num_rows,4}),'unknown'); % cell array containing row index of strings with "Unknown" in u1
% %       noneed(num_rows,5) = contains(lower(anat{num_rows,4}),'vent'); % cell array containing row index of strings with "Unknown" in u1             
% %     end
% %     noneed=any(noneed,2);
% %     
% %     noneed = noneed | badch; % now is either uncessary (noneed) or bad channels
% % 
% 
% 
% 
    %IMPORT PARAMS
    meshpath='/Imaging/Meshes/';
    Rcortex=load([ptpath meshpath pt '_rh_pial.mat']); 
        loaf.rpial=Rcortex; 
        Rcrtx=Rcortex.cortex; 
        clear Rcortex
    Lcortex=load([ptpath meshpath pt '_lh_pial.mat']); 
        loaf.lpial=Lcortex; 
        Lcrtx=Lcortex.cortex; 
        clear Lcortex
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [~,prm_allPtSz]=xlsread([opscea_path 'OPSCEAparams'],'params'); 
        fields_SZ=prm_allPtSz(1,:); % header for columns of seizure parameters
        prm=prm_allPtSz(strcmp(pt,prm_allPtSz(:,1))&strcmp(sz,prm_allPtSz(:,2)),:);
        if isempty(prm); error(['ATTENTION: No entry exists for ' pt ' seizure ' sz ' in the params master sheet']); end

    % Import parameters for patient's specific plot (layout of video frame)
    [~,plt]=xlsread([opscea_path 'OPSCEAparams'],pt); 
        fields_PLOT=plt(1,:); plt(1,:)=[]; % header for columns of plotting parameters
        plottype=plt(:,strcmpi(fields_PLOT,'plottype')); %type of plot for each subplot (accepts: iceeg, surface, depth, or colorbar)

    cd 

    surfaces=plt(:,strcmpi(fields_PLOT,'surfaces'));
    surfacesopacity=plt(:,strcmpi(fields_PLOT,'surfacesopacity'));

    %% plot the weights on the brain

    params_cax=str2double(regexp(prm{strcmp('cax',fields_SZ)},',','split'));         %color axis for heatmap
    params_gsp=str2double(prm{strcmp('gsp',fields_SZ)}); %gaussian spreading parameter (default 10)
    for j=1:size(plt,1) 
              srf=regexp(surfaces{j},',','split'); % list the specific surfaces wanted for this subplot
              srfalpha=regexp(surfacesopacity{j},',','split'); % list their corresponding opacities (values from 0 to 1; 0=invisible, 1=opaque)
              if length(srf)~=length(srfalpha); msgbox('Number of surface to plot does not match number of alpha designations, check excel sheet'); return; end
              acceptedterms={'rcortex','lcortex','rhipp','lhipp','ramyg','lamyg','wholebrain'};
                for s=1:length(srf)
                    srf{s}=lower(srf{s}); %convert to lower case for easier string matching
                  if ~isempty(intersect(srf{s},acceptedterms)) %make sure user specified accepted terminologies for the meshes
                    switch srf{s}; %see below for case "wholebrain"s
                        case 'rcortex'; srfplot=Rcrtx; 
                        case 'lcortex'; srfplot=Lcrtx; 
    %                     case 'rhipp';   srfplot=Rhipp; 
    %                     case 'lhipp';   srfplot=Lhipp; 
    %                     case 'ramyg';   srfplot=Ramyg; 
    %                     case 'lamyg';   srfplot=Lamyg; 
                    end
                  end
                end
    end


    hh=ctmr_gauss_plot_edited(srfplot,szxyz(sz_nns,:,sz_i),sz_w8s(sz_nns),params_cax,0,cmocean('balance'),params_gsp); 
    colorbar

%     lightsout
%     litebrain('r',1)
%     litebrain('l',1)
% 
    isR=nansum(szxyz(:,1,sz_i))>0; isL=isR~=1; %handy binary indicators for laterality

    lightsout; if isR; litebrain('r',1); else; litebrain('l',1); end
%         hold on; for i=1:size(new_em,1); plot3(new_em(i,1),new_em(i,2),new_em(i,3),'k.','markersize',15); end
%     cmocean('balance')
    
%     colorbar('Ticks',caxis,'fontsize',18)
    
    alpha(1)


end
% 
% %% plot the weights on the brain
% % hh=ctmr_gauss_plot_edited(srfplot,em(nns,:),sz_w8s(nns),S.cax,0,cmocean('balance'),S.gsp); 
% % hh=ctmr_gauss_plot_edited(srfplot,em(nns,:),w8s(nns),S.cax,0,cmocean('balance'),S.gsp); 
