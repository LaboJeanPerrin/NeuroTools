clc
close all

F = figure();

b1 = uicontrol(F, 'Style', 'togglebutton', 'String', 'Button toggle', 'Position', [10 10 100 30]);

b2 = uicontrol(F, 'Style', 'pushbutton', 'String', 'Button push', 'Position', [10 50 100 30]);

tab = uitabgroup(F, 'unit', 'pixel', 'Position', [10 100 300 250]);

t1 = uitab(tab, 'Title', 'Tab 1');

t2 = uitab(tab, 'Title', 'Tab 2');

uicontrol(t1, 'Style', 'slider', 'Position', [10 10 200 20])

uicontrol(t1, 'Style', 'edit', 'Position', [10 40 200 20])

uicontrol(t1, 'Style', 'checkbox', 'String', 'Check', 'Position', [10 70 200 20])