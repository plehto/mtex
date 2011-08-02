function mtexdata(name)
% load of data provided with mtex and often used in documentation
%
%% Syntax
% mtexdata        - displays a list of available loading routines
% mtexdata name   - loads specified data set
%
%% Input
%% Flags
% aachen -
% 3d - serial section 3d EBSD data from Leo Kestens
% mylonite - collected by Daniel Rutte (Brad R. Hacker)
% epidote - data provided by David Mainprice
%
% dubna - collected by Florian Wobbe at Dubna
% ptx -
% geesthacht -
%
%
%% See also
%

list = listmtexdata;

if nargin < 1
  
  disp('available loading routines for mtex sample data');
  cprintf({'TYPE', list.type; 'NAME',list.name}');
  return
  
elseif strcmpi(name,'clear')
  
  files = dir(fullfile(mtexDataPath,'*.mat'));
  for k=1:numel(files)
    fullfile(mtexDataPath,[files(k).name]);
    delete(fullfile(mtexDataPath,[files(k).name]));
  end
  return
  
elseif strcmpi(name,'all')
  
  for files = list
    mtexdata(files.name)
  end
  return
  
end


ndx = strmatch(name,{list.name});
file = fullfile(mtexDataPath,[ lower(list(ndx).name) '.mat']);

if any(ndx) && isempty(dir(file))
  
  switch list(ndx).type
    case 'ebsd'
      
      [CS,ebsd] = feval(['mtexdata_' list(ndx).name]);
      save(file,'CS','ebsd');
      
    case 'pf'
      
      [CS,h,pf] = feval(['mtexdata_' list(ndx).name]);
      save(file,'CS','h','pf');     
      
  end
  
end

S = load(file);

disp([ upper(list(ndx).name) ' data loaded in variables']);
fld = fields(S);
for k=1:numel(fld)
  assignin('base',fld{k},S.(fld{k}));
end

disp(fld)
evalin('base',fld{end});




function data = listmtexdata

fid = fopen([mfilename('fullpath') '.m'],'r');
A = char(fread(fid,'char')');
fclose(fid);

data = regexp(A,'function(.*?)(?<type>(ebsd|pf))(.*?)mtexdata_(?<name>\w*)','names');
data(cellfun('isempty',{data.name})) = [];


% ----------------------------------------------------------- PoleFigure data --
function [CS,h,pf] = mtexdata_dubna

CS = symmetry('-3m',[1.4 1.4 1.5]);
SS = symmetry;
fname = {...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-10)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-11)(01-11)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(11-22)_amp.cnv')};

h = {...
  Miller(1,0,-1,0,CS),...
  [Miller(0,1,-1,1,CS),Miller(1,0,-1,1,CS)],... % superposed pole figures
  Miller(1,1,-2,2,CS)};

c = {1,[0.52 ,1.23],1};

pf = loadPoleFigure(fname,h,CS,SS,'interface','dubna','superposition',c);

function [CS,h,pf] = mtexdata_geesthacht

CS = symmetry('m-3m');
SS = symmetry('-1');

fname = fullfile(mtexDataPath,'PoleFigure','geesthacht','ST42-104-110.dat');

h = { ...
  Miller(1,0,4,CS), ...
  Miller(1,0,4,CS), ...
  Miller(1,1,0,CS), ...
  Miller(1,1,0,CS), ...
  };

pf = loadPoleFigure(fname,h,CS,SS);


function   [CS,h,pf] = mtexdata_ptx

CS = symmetry('mmm');
SS = symmetry('-1');

pname = fullfile(mtexDataPath,'PoleFigure','ptx');
fname = {...
  [pname '/gt9104.ptx'], ...
  [pname '/gt9110.ptx'], ...
  [pname '/gt9202.ptx'], ...
  };

pf = loadPoleFigure(fname,CS,SS);
h = get(pf,'h');

% ----------------------------------------------------------------- EBSD data --
function [CS,ebsd] = mtexdata_aachen
CS = {...
  symmetry('m-3m','mineral','Fe'),...
  symmetry('m-3m','mineral','Mg')};

ebsd = loadEBSD(fullfile(mtexDataPath,'EBSD','85_829grad_07_09_06.txt'),CS,symmetry,...
  'interface','generic' , ...
  'ColumnNames', { 'Index' 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'MAD' 'BC' 'BS' 'Bands' 'Error' 'ReliabilityIndex'},...
  'Bunge', 'ignorePhase', 0);

function [CS,ebsd] = mtexdata_3d

ebsd = loadEBSD(fullfile(mtexDataPath,'EBSD','3dData','*.ang'),'3d', (0:58)*0.12);
CS = get(ebsd,'CS');

function [CS,ebsd] = mtexdata_mylonite

CS = {...
  symmetry('-1',[8.169,12.851,7.1124],[93.63,116.4,89.46]*degree,'mineral','Andesina An28'),...
  symmetry('-3m',[4.913,4.913,5.504],'mineral','Quartz-new'),...
  symmetry('2/m',[5.339,9.249,20.196],[95.06,90,90]*degree,'mineral','Biotite'),...
  symmetry('2/m',[8.5632,12.963,7.2099],[90,116.07,90]*degree,'mineral','Orthoclase')};

ebsd = loadEBSD(fullfile(mtexDataPath,'EBSD','P5629U1.txt'),CS, ...
  'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3'});

function [CS,ebsd] = mtexdata_epidote

ebsd = loadEBSD([mtexDataPath '/EBSD/data.ctf'],'ignorePhase',[0 3 4]);
CS = get(ebsd,'CS');
