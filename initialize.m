% Initialize system's configuration
global config

% Libraries

% VLFeat
run('lib/vlfeat-0.9.20/toolbox/vl_setup.m');

% FLANN
addpath('lib/flann');

% Functions
addpath('functions');
config.cmd = @(x) dos(x);

% File Paths
config.dataPath = 'data';
config.queryPath = 'query';
config.groundtruthPath = 'groundtruth';
config.rankListPath = 'ranklist';
config.tempPath = 'temp';
config.apPath = 'ap';



% Create folders
mkdir(config.dataPath);
mkdir(config.queryPath);
mkdir(config.groundtruthPath);
mkdir(config.rankListPath);
mkdir(config.tempPath);
mkdir(config.apPath);

mkdir(fullfile(config.dataPath, 'feature'));
mkdir(fullfile(config.queryPath, 'feature'));

mkdir(fullfile(config.dataPath, 'quantize'));
mkdir(fullfile(config.queryPath, 'quantize'));

mkdir(fullfile(config.dataPath, 'bow'));
mkdir(fullfile(config.queryPath, 'bow'));



% Codebook file
config.codebookFile = fullfile(config.dataPath, 'codebook.hdf5');


config.allDataKpFile = fullfile(config.dataPath, 'dataset_kp.mat');
config.allDataBoWFile = fullfile(config.dataPath, 'dataset_bow.mat');
config.allDataBinsFile = fullfile(config.dataPath, 'dataset_bins.mat');

% IDF file
config.idfFile = fullfile(config.dataPath, 'idf.mat');

% Quantize features argument for flann
config.quantStruct = struct('quantize', 'kdtree', 'buildconfig', struct('algorithm', 'kdtree', 'trees', 8, 'checks', 800, 'cores', 2), 'knn', 3, 'deltaSqr', 6250, 'topK', 100);

% Constants
config.kpLen = 5;
config.descLen = 128;
config.histLen = 1000000;
