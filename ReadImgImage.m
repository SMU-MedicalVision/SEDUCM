function x = ReadImgImage(filename, width, height)
% x = ReadRawImage(filename, width, height)
%
% Read a RAW DATA format image written by IPLAB.
% The raw image data is written as a series of signed
% short integers in row first order.
%
% 2/24/97 jdt wrote it
 

% Open file
id = fopen(filename, 'r');

% Read in the data.
x = fread(id, [width,height], 'int16',0,'b')';
% x = fread(id, [width,height], 'uint16')';

% Close file
fclose(id);