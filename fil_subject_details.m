% This script defines the subject details for 'fil_mri_organise_batch'

%% SUBJECT DETAILS
% Pilot 1
subj{1}.name       = 'P01';
subj{1}.scanid     = 'MQ05730_FIL.S';
subj{1}.localiser  = 1;
subj{1}.structural = 9;
subj{1}.functional = [6 7 8 10 11 12]; 
subj{1}.fieldmaps  = [4 5];
subj{1}.delete     = [2 3];
subj{1}.map        = 1;

subj{2}.name       = 'sub01';
subj{2}.date       = '20200207';
subj{2}.scanid     = 'MQ05768_FIL.S';
subj{2}.localiser  = 1;
subj{2}.structural = 8;
subj{2}.functional = [5 6 7 9 10 11];
subj{2}.fieldmaps  = [3 4];
subj{2}.delete     = 2; % Short functional check
subj{2}.map        = 1;

subj{3}.name       = 'sub02';
subj{3}.date       = '20200207';
subj{3}.scanid     = 'MQ05769_FIL.S';
subj{3}.localiser  = 1;
subj{3}.structural = 8;
subj{3}.functional = [5 6 7 9 10 11];
subj{3}.fieldmaps  = [3 4];
subj{3}.delete     = 2; % Short functional check
subj{3}.map        = 2;

subj{4}.name       = 'sub03';
subj{4}.date       = '20200211';
subj{4}.scanid     = 'MQ05775_FIL.S';
subj{4}.localiser  = 1;
subj{4}.structural = 8;
subj{4}.functional = [5 6 7 9 10 11];
subj{4}.motion     = []; 
subj{4}.fieldmaps  = [3 4];
subj{4}.delete     = 2; % Short functional check
subj{4}.map        = 1;

subj{5}.name       = 'sub04';
subj{5}.date       = '20200211';
subj{5}.scanid     = 'MQ05774_FIL.S';
subj{5}.localiser  = 1;
subj{5}.structural = 8;
subj{5}.functional = [5 6 7 9 10 11];
subj{5}.fieldmaps  = [3 4 12 13];
subj{5}.delete     = 2; % Short functional check
subj{5}.map        = 2;

subj{6}.name       = 'sub05';
subj{6}.date       = '20200218';
subj{6}.scanid     = 'MQ05790_FIL.S';
subj{6}.localiser  = 1;
subj{6}.structural = 8;
subj{6}.functional = [5 6 7 9 10 11];
subj{6}.fieldmaps  = [3 4];
subj{6}.delete     = 2; % Short functional check
subj{6}.map        = 1;

subj{7}.name       = 'sub06';
subj{7}.date       = '20200217';
subj{7}.scanid     = 'MQ05789_FIL.S';
subj{7}.localiser  = 1;
subj{7}.structural = 8;
subj{7}.functional = [5 6 7 9 10 11];
subj{7}.fieldmaps  = [3 4];
subj{7}.delete     = 2; % Short functional check
subj{7}.map        = 2;

% No sub07 scanning data

subj{8}.name       = 'sub08';
subj{8}.date       = '20200310';
subj{8}.scanid     = 'MQ05831_FIL.S';
subj{8}.localiser  = 1;
subj{8}.structural = 8;
subj{8}.functional = [5 6 7 9 10 11];
subj{8}.fieldmaps  = [3 4];
subj{8}.delete     = 2; % Short functional check
subj{8}.map        = 2;

subj{9}.name       = 'sub09';
subj{9}.date       = '20200310';
subj{9}.scanid     = 'MQ05832_FIL.S';
subj{9}.localiser  = 1;
subj{9}.structural = 8;
subj{9}.functional = [5 6 7 9 10 11];
subj{9}.fieldmaps  = [3 4];
subj{9}.delete     = 2; % Short functional check
subj{9}.map        = 1;

subj{10}.name       = 'sub10'; % Skipped subject number by accident
subj{10}.date       = nan;
subj{10}.scanid     = nan;
subj{10}.localiser  = nan;
subj{10}.structural = nan;
subj{10}.functional = nan;
subj{10}.fieldmaps  = nan;
subj{10}.delete     = nan;
subj{10}.map        = nan;

subj{11}.name       = 'sub11';
subj{11}.date       = '20201001';
subj{11}.scanid     = 'MQ05852_FIL.S';
subj{11}.localiser  = 1;
subj{11}.structural = 8;
subj{11}.functional = [5 6 7 9 10 11];
subj{11}.fieldmaps  = [3 4];
subj{11}.delete     = 2; % Short functional check
subj{11}.map        = 1;

subj{12}.name       = 'sub12';
subj{12}.date       = '20201001';
subj{12}.scanid     = 'MQ05853_FIL.S';
subj{12}.localiser  = 1;
subj{12}.structural = 8;
subj{12}.functional = [5 6 7 9 10 11];
subj{12}.fieldmaps  = [3 4];
subj{12}.delete     = 2; % Short functional check
subj{12}.map        = 2;

subj{13}.name       = 'sub13';
subj{13}.date       = '20201006';
subj{13}.scanid     = 'MQ05855_FIL.S';
subj{13}.localiser  = 1;
subj{13}.structural = 9;
subj{13}.functional = [6 7 8 10 11 12];
subj{13}.fieldmaps  = [3 4];
subj{13}.delete     = [2, 5]; % Short functional check
subj{13}.map        = 1;

subj{14}.name       = 'sub14';
subj{14}.date       = '20201006';
subj{14}.scanid     = 'MQ05856_FIL.S';
subj{14}.localiser  = 1;
subj{14}.structural = 8;
subj{14}.functional = [5 6 7 9 10 11];
subj{14}.fieldmaps  = [3 4];
subj{14}.delete     = 2; % Short functional check
subj{14}.map        = 2;

subj{15}.name       = 'sub15';
subj{15}.date       = '20201008';
subj{15}.scanid     = 'MQ05858_FIL.S';
subj{15}.localiser  = 1;
subj{15}.structural = 8;
subj{15}.functional = [5 6 7 9 10 11];
subj{15}.fieldmaps  = [3 4];
subj{15}.delete     = 2; % Short functional check
subj{15}.map        = 1;

subj{16}.name       = 'sub16';
subj{16}.date       = '20201012';
subj{16}.scanid     = 'MQ05859_FIL.S';
subj{16}.localiser  = 1;
subj{16}.structural = 8;
subj{16}.functional = [5 6 7 9 10 11];
subj{16}.motion     = [];
subj{16}.fieldmaps  = [3 4];
subj{16}.delete     = 2; % Short functional check
subj{16}.map        = 2;

subj{17}.name       = 'sub17';
subj{17}.date       = '20201014';
subj{17}.scanid     = 'MQ05862_FIL.S';
subj{17}.localiser  = 1;
subj{17}.structural = 9;
subj{17}.functional = [6 7 8 10 11 12];
subj{17}.fieldmaps  = [3 4];
subj{17}.delete     = [2 5]; % Short functional check
subj{17}.map        = 1;

subj{18}.name       = 'sub18';
subj{18}.date       = '20201015';
subj{18}.scanid     = 'MQ05863_FIL.S';
subj{18}.localiser  = 1;
subj{18}.structural = 9;
subj{18}.functional = [5 7 8 10 11 12];
subj{18}.motion     = [];
subj{18}.fieldmaps  = [3 4];
subj{18}.delete     = [2 6]; % Short functional check
subj{18}.map        = 2;

subj{19}.name       = 'sub19';
subj{19}.date       = '20201020';
subj{19}.scanid     = 'MQ05866_FIL.S';
subj{19}.localiser  = 1;
subj{19}.structural = 8;
subj{19}.functional = [5 6 7 9 10 11];
subj{19}.fieldmaps  = [3 4];
subj{19}.delete     = 2; % Short functional check
subj{19}.map        = 1;

subj{20}.name       = 'sub20';
subj{20}.date       = '20201022';
subj{20}.scanid     = 'MQ05869_FIL.S';
subj{20}.localiser  = 1;
subj{20}.structural = 8;
subj{20}.functional = [5 6 7 9 10 11];
subj{20}.motion     = [];
subj{20}.fieldmaps  = [3 4];
subj{20}.delete     = 2; % Short functional check
subj{20}.map        = 2;

subj{21}.name       = 'sub21';
subj{21}.date       = '20201023';
subj{21}.scanid     = 'MQ05870_FIL.S';
subj{21}.localiser  = 1;
subj{21}.structural = 8;
subj{21}.functional = [5 6 7 9 10 11];
subj{21}.motion     = [];
subj{21}.fieldmaps  = [3 4];
subj{21}.delete     = 2; % Short functional check
subj{21}.map        = 1;

subj{22}.name       = 'sub22';
subj{22}.date       = '20201029';
subj{22}.scanid     = 'MQ05878_FIL.S';
subj{22}.localiser  = 1;
subj{22}.structural = 8;
subj{22}.functional = [5 6 7 9 10 11];
subj{22}.fieldmaps  = [3 4];
subj{22}.delete     = 2; % Short functional check
subj{22}.map        = 2;

subj{23}.name       = 'sub23';
subj{23}.date       = '20201103';
subj{23}.scanid     = 'MQ05883_FIL.S';
subj{23}.localiser  = 1;
subj{23}.structural = 8;
subj{23}.functional = [5 6 7 9 10 11];
subj{23}.fieldmaps  = [3 4];
subj{23}.delete     = 2; % Short functional check
subj{23}.map        = 1;

subj{24}.name       = 'sub24';
subj{24}.date       = '20201118';
subj{24}.scanid     = 'MQ05896_FIL.S';
subj{24}.localiser  = 1;
subj{24}.structural = 9;
subj{24}.functional = [5 6 10 11 12 13];
subj{24}.fieldmaps  = [3 4 7 8];
subj{24}.delete     = 2; % Short functional check
subj{24}.map        = 2;

subj{25}.name       = 'sub25';
subj{25}.date       = '20201125';
subj{25}.scanid     = 'MQ05905_FIL.S';
subj{25}.localiser  = 1;
subj{25}.structural = 8;
subj{25}.functional = [5 6 7 9 10 11];
subj{25}.fieldmaps  = [3 4];
subj{25}.delete     = 2; % Short functional check
subj{25}.map        = 1;

subj{26}.name       = 'sub26';
subj{26}.date       = '20210416';
subj{26}.scanid     = 'MQ05917_FIL.S';
subj{26}.localiser  = 1;
subj{26}.structural = 8;
subj{26}.functional = [5 6 7 9 10 11];
subj{26}.fieldmaps  = [3 4];
subj{26}.delete     = 2; % Short functional check
subj{26}.map        = 1;

subj{27}.name       = 'sub27';
subj{27}.date       = '20210416';
subj{27}.scanid     = 'MQ05918_FIL.S';
subj{27}.localiser  = 1;
subj{27}.structural = 8;
subj{27}.functional = [5 6 7 9 10 11];
subj{27}.fieldmaps  = [3 4];
subj{27}.delete     = 2; % Short functional check
subj{27}.map        = 2;

subj{28}.name       = 'sub28';
subj{28}.date       = '20210422';
subj{28}.scanid     = 'MQ05922_FIL.S';
subj{28}.localiser  = 1;
subj{28}.structural = 8;
subj{28}.functional = [5 6 7 9 10 11];
subj{28}.fieldmaps  = [3 4];
subj{28}.delete     = 2; % Short functional check
subj{28}.map        = 2;

subj{29}.name       = 'sub29';
subj{29}.date       = '20210427';
subj{29}.scanid     = 'MQ05930_FIL.S';
subj{29}.localiser  = 1;
subj{29}.structural = 8;
subj{29}.functional = [5 6 7 9 10 11];
subj{29}.fieldmaps  = [3 4];
subj{29}.delete     = 2; % Short functional check
subj{29}.map        = 2;

subj{30}.name       = 'sub30';
subj{30}.date       = '20210427';
subj{30}.scanid     = 'MQ05932_FIL.S';
subj{30}.localiser  = 1;
subj{30}.structural = 8;
subj{30}.functional = [5 6 7 9 10 11];
subj{30}.fieldmaps  = [3 4];
subj{30}.delete     = 2; % Short functional check
subj{30}.map        = 1;

subj{31}.name       = 'sub31';
subj{31}.date       = '20210429';
subj{31}.scanid     = 'MQ05936_FIL.S';
subj{31}.localiser  = 1;
subj{31}.structural = 8;
subj{31}.functional = [5 6 7 9 10 11];
subj{31}.fieldmaps  = [3 4];
subj{31}.delete     = 2; % Short functional check
subj{31}.map        = 2;

subj{32}.name       = 'sub32';
subj{32}.date       = '20210505';
subj{32}.scanid     = 'MQ05942_FIL.S';
subj{32}.localiser  = 1;
subj{32}.structural = 9;
subj{32}.functional = [6 7 8 10 11 12];
subj{32}.fieldmaps  = [3 4];
subj{32}.delete     = [2 5]; % Short functional check & false start
subj{32}.map        = 1;

subj{33}.name       = 'sub33';
subj{33}.date       = '20210506';
subj{33}.scanid     = 'MQ05945_FIL.S';
subj{33}.localiser  = 1;
subj{33}.structural = 8;
subj{33}.functional = [5 6 7 9 10 11];
subj{33}.fieldmaps  = [3 4];
subj{33}.delete     = 2; % Short functional check
subj{33}.map        = 2;

subj{34}.name       = 'sub34';
subj{34}.date       = '20210512';
subj{34}.scanid     = 'MQ05957_FIL.S';
subj{34}.localiser  = 1;
subj{34}.structural = 8;
subj{34}.functional = [5 6 7 9 10 11];
subj{34}.fieldmaps  = [3 4];
subj{34}.delete     = 2; % Short functional check
subj{34}.map        = 1;

subj{35}.name       = 'sub35';
subj{35}.date       = '20210513';
subj{35}.scanid     = 'MQ05959_FIL.S';
subj{35}.localiser  = 1;
subj{35}.structural = 8;
subj{35}.functional = [5 6 7 9 10 11];
subj{35}.fieldmaps  = [3 4];
subj{35}.delete     = 2; % Short functional check
subj{35}.map        = 2;

subj{36}.name       = 'sub36';
subj{36}.date       = '20210519';
subj{36}.scanid     = 'MQ05965_FIL.S';
subj{36}.localiser  = 1;
subj{36}.structural = 8;
subj{36}.functional = [5 6 7 9 10 11];
subj{36}.fieldmaps  = [3 4];
subj{36}.delete     = 2; % Short functional check
subj{36}.map        = 1;
%% Save details
save('\\blur\infabs\MRI\subject_details.mat','subj');
