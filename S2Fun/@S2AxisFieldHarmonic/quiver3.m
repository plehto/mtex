function h = quiver3(sAF,varargin)
% 3-dimensional quiver spherical vector field
%
% Syntax
%   quiver3(sAF)
%
% See also
%   S2VectorField/plot
%

% plot the function values
h = plot(sAF,'3d',varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end