function id = findAvailableDataConnection(this)

% % % if isempty(this.Conn.Data)
% % %     id = this.newDataConnection(); 
% % % else
% % %     
% % %     id = 1;
% % %     
% % % %     if this.Conn.Data(1).available
% % % %         id = 1;
% % % %     else
% % % %         id = NaN;
% % % %     end
% % % end
% % % 
% % % return

% % % fprintf('[ ');
% % % for i = 1:numel(this.Conn.Data)
% % %     fprintf('%i ', this.Conn.Data(i).available);
% % % end
% % % fprintf(']\n');

id = find([this.Conn.Data(:).available], 1, 'first');

if isempty(id)
    id = this.newDataConnection();  
end

