clear; clc;
global G Z %S_ROW S_COL
G = 14;
% S_ROW = [0 4 1 0 0 0 4 0];
% S_COL = [3 0 5 3 0 4 0 5];

A = 10; B = 11; C = 12; D = 13; E = 14;
X = [
  0 0 0 0 0 0 C 8 0 0 5 0 A 0;
  0 0 D A 6 0 5 0 0 4 E 0 0 C;
  0 4 0 0 0 0 B 0 3 0 2 0 0 0;
  6 A 0 0 0 0 0 0 0 B 7 0 0 0;
  0 0 0 6 0 1 0 0 E D C 0 0 7;
  0 8 9 0 A 0 4 0 6 0 3 0 0 0;
  D 0 0 2 0 0 0 0 0 E 9 0 0 0;
  0 0 0 C 1 0 0 0 0 0 4 0 0 2;
  0 0 0 B 0 5 0 6 0 C 0 A 4 0;
  9 0 0 1 4 7 0 0 C 0 8 0 0 0;
  0 0 0 E C 0 0 0 0 0 0 0 2 D;
  0 0 0 9 0 D 0 7 0 0 0 0 B 0;
  E 0 0 7 D 0 0 4 0 3 A 2 0 0;
  0 2 0 5 0 0 A E 0 0 0 0 0 0;
 ];
Z = [
  1 1 2 D D D D E E E E B B B;
  1 2 2 D D D D E E B B B B B;
  1 2 2 2 2 D D E E B B B A A;
  1 1 2 2 2 D D E E B B B A A;
  1 1 1 2 2 D E E E C C C C A;
  1 1 1 1 2 D C C E C C A A A;
  3 1 4 4 2 4 C C C C C C A A;
  3 4 4 4 4 4 4 9 9 9 9 9 A A;
  3 4 4 4 4 5 4 8 8 9 9 9 A A;
  3 3 3 3 3 5 8 8 8 8 9 9 9 9;
  3 3 3 3 3 5 5 8 8 8 8 8 9 9;
  3 5 5 5 5 5 5 8 8 7 7 7 7 7;
  5 5 5 6 6 6 6 6 8 7 7 7 7 7;
  5 6 6 6 6 6 6 6 6 6 7 7 7 7;
];

S = rec_grid_solver(X);
% disp(S)

S_pretty = repmat('x', G);
for i = 1:G
  for j = 1:G
    v = S(i,j);
    if v < A
      S_pretty(i,j) = num2str(v);
    elseif v == A
      S_pretty(i,j) = 'A';
    elseif v == B
      S_pretty(i,j) = 'B';
    elseif v == C
      S_pretty(i,j) = 'C';
    elseif v == D
      S_pretty(i,j) = 'D';
    elseif v == E
      S_pretty(i,j) = 'E';
    end
  end
end
for i = 1:G
  for j = 1:G
    fprintf('\t%c', S_pretty(i,j));
  end
  fprintf('\n');
end
% disp(S_pretty)

function X = rec_grid_solver(X) 
global G Z %S_ROW S_COL
% Solve Grid Puzzles using recursive backtracking. 
%   rec_grid_solver(X), expects a G-by-G array X. 
 % Fill in all “singletons”. 
 % C is a cell array of candidate vectors for each cell. 
 % s is the first cell, if any, with one candidate. 
 % e is the first cell, if any, with no candidates. 
 [C,s,e] = candidates(X);
 while ~isempty(s) && isempty(e)
    X(s) = C{s};
    [C,s,e] = candidates(X);
 end
 % Return for impossible puzzles.
 if ~isempty(e)
    return
 end
 % Recursive backtracking.
 if any(X(:) == 0)
    Y = X;
    z = find(X(:) == 0,1);    % The first unfilled cell.
    for r = [C{z}]            % Iterate over candidates.
       X = Y;
       X(z) = r;              % Insert a tentative value.
       X = rec_grid_solver(X);         % Recursive call.
       if all(X(:) > 0) % && check_skyscrapers(X)  % Found a solution.
          return
       end
    end
 end
% ------------------------------
  function [C,s,e] = candidates(X)
      C = cell(G,G);
%       tri = @(k) 3*ceil(k/3-1) + (1:3);
      for j = 1:G
         for i = 1:G
            if X(i,j)==0
               z = 1:G;
               z(nonzeros(X(i,:))) = 0;
               z(nonzeros(X(:,j))) = 0;  % z() index matches val found/removed
%                z(nonzeros(X(tri(i),tri(j)))) = 0;
               z(nonzeros(X(Z==Z(i,j)))) = 0;
               C{i,j} = nonzeros(z)'; 
            end 
         end 
      end 
  L = cellfun(@length,C);   % Number of candidates. 
  s = find(X==0 & L==1,1); 
  e = find(X==0 & L==0,1); 
  end % candidates 

%   function valid = check_skyscrapers(X)
%     valid = true;
%     for i = 1:G
%       if ~isSkyscraperRowValid(X(i,:), S_ROW(i)) || ~isSkyscraperRowValid(X(:,i), S_COL(i))
% %       if (S_ROW(i)~=0 && S_ROW(i)~=sum(diff(X(i,:)) > 0)) || ...
% %          (S_COL(i)~=0 && S_COL(i)~=sum(diff(X(:,i)) > 0))
%         valid = false;
%         return
%       end
%     end
% 
%     
%     function isValid = isSkyscraperRowValid(row, clue)
%       if clue == 0
%         isValid = true;
%         return
%       end
%       n = numel(row); % Number of buildings in the row
%       stack = zeros(1, n); % Initialize the stack
%       top = 0; % Top index of the stack
%       visibleCount = sum(arrayfun(@(x) addToStack(x), row)); % Count of visible buildings
% 
%       % Check if the visible count matches the clue
%       isValid = (visibleCount == clue);
% 
%       function isVisible = addToStack(height)
%         while top > 0 && stack(top) < height
%           top = top - 1; % Pop the stack
%         end
%         if top == 0 || stack(top) ~= height
%           top = top + 1; % Push to the stack
%           stack(top) = height;
%           isVisible = true;
%         else
%           isVisible = false;
%         end
%       end % isVisible
%     end % isSkyscraperRowValid
%     
%     
%   end %check_skyscrapers



end % rec_grid_solver

