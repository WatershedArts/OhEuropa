'use strict'

// Import Electron Data
const {app,BrowserWindow,ipcMain,Menu,net} = require('electron');

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
// * When App is Ready
//----------------------------------------------------------------
app.on('ready',function() {

    console.log('App Is Ready');
    createWindow();
    // loginToRadio();
});

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
    // main_window.webContents.openDevTools()

    // Emit Event On Close
    main_window.on('closed', function() {
        console.log('Closing Window');
        // logoutOfRadio();
        main_window = null;
    });
}
