function varargout = subsref(this, s)

switch s(1).type
    
   case '()'
        varargout = { builtin('subsref', this.mmap.Data.array, s) };
        
    otherwise
        varargout = { builtin('subsref', this, s) };
        
end