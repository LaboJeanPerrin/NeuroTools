function this = subsasgn(this, s, varargin)

switch s(1).type
    
    case '()'
        this.mmap.Data.array = subsasgn(this.mmap.Data.array, s, varargin{:});
        
    otherwise
        this = builtin('subsasgn', this, s, varargin);
end