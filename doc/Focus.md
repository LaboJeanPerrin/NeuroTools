# Focus
Here we explain what the "focus" does and how to use it.

## Initializing focus
Call:

    F = NT.Focus(workingDirectory, study, date, run);

For example:

    F = NT.Focus(pwd, 'RLS1P', '2016-02-29', 'Run 05');

The run name can be replaced by it's number (shortcut):

    F = NT.Focus(pwd, 'RLS1P', '2016-02-29', 5);

It will give you something like:

    F = 
        Focus with properties:
            study: ''
            date: '2016-02-29'
            run: 'Run 05'
            name: 'RLS1P 2016-02-29 (Run 05)'
            dir: [1×1 struct]
            param: [1×1 struct]
            frames: []
            units: [1×1 struct]
            stim: [1×1 struct]
            sets: [1×20 struct]
            set: [1×1 struct]
            IP: [1×1 struct]
            dx: 0.8000
            dy: 0.8000
            dt: 10

## Shortcut for architecture
A lot of functions have the focus as their first argument, it allows them to know the folders architecture.
