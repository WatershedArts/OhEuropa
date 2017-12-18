'use strict'

// Import Electron Data
const {app,BrowserWindow,ipcMain,Menu} = require('electron');

let main_window = null;

const menu_template = [ 
    {
        label: "View",
        submenu: [
            { label: "Map Manager", role: "Map Manager" },
            { label: "Song Manager", role: "Song Manager" }
        ]
    },
    {
        label: "Help",
        submenu: [
            { label: "Refresh", role: "Refresh" },
            { label: "Help", role: "Help" },
        ]
    }
];

//----------------------------------------------------------------
// * Create New Window
//----------------------------------------------------------------
function createWindow()
{
    console.log('Creating New Window');
    main_window = new BrowserWindow({
        height:800,
        width:800,
        resizable:false
    });

    main_window.loadURL('file://' + __dirname + '/index.html');


    console.log('Logging User On');

    // Emit Event On Close
    main_window.on('closed', function() {
        console.log('Closing Window');
        main_window = null;
    });
}
//----------------------------------------------------------------
// * When App is Ready
//----------------------------------------------------------------
app.on('ready',function() {
    
    console.log('App Is Ready');
    createWindow();
    // const menu = Menu.buildFromTemplate(menu_template)
    // Menu.setApplicationMenu(menu)
    
});