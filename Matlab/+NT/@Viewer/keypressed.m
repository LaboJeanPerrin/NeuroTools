function keypressed(this, event)

% Escape
switch event.Key
    
    case 'escape'
        close(this.figure)
        return
        
    case 'numlock'
        this.autoRange;
        this.updateVisu;
        
    case 'pageup'
    case 'pagedown'
    case 'leftarrow'
    case 'rightarrow'        
        
    otherwise
        
        switch event.Character
            
            case '-'
                this.zoom = this.zoom+1;
                this.setFigureSize;
                
            case '+'
                this.zoom = max(this.zoom-1,1);
                this.setFigureSize;
                
            case '1'
                this.range(1) = this.range(1)/0.8;
                this.updateVisu;
                
            case '3'
                this.range(2) = this.range(2)/0.8;
                this.updateVisu;
            
            case '5'
                set(this.slider, 'Value', floor(get(this.slider, 'max')/2));
                this.updateVisu;
                
            case '7'
                this.range(1) = this.range(1)*0.8;
                this.updateVisu;
                
            case '9'
                this.range(2) = this.range(2)*0.8;
                this.updateVisu;
            
            case '/'
                set(this.slider, 'Value', max(get(this.slider, 'Value')-1, get(this.slider, 'Min')));
                this.updateVisu;
            
                case '*'
                set(this.slider, 'Value', min(get(this.slider, 'Value')+1, get(this.slider, 'Max')));
                this.updateVisu;
            
            otherwise
                event
        end
        
end