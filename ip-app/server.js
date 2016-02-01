'use strict';

const express = require('express');
const path = require('path');

const routes = require('./routes');

const PORT = 8080;

const app = express();
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(require('stylus').middleware(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'public')));

/*
app.get('/', function (req, res) {
    var result = {};
    
    // Get the hostname
    result['hostname'] = os.hostname();
    
    // Get the IPv4 addresses for each network interface
    result['addresses'] = {};
    var interfaces = os.networkInterfaces();
    for(var i in interfaces) {
        var iaddr = []
        for(var a = 0; a < interfaces[i].length; a++) {
            if(interfaces[i][a].family == 'IPv4') {
                iaddr.push(interfaces[i][a].address)
            }
        }
        if(iaddr.length > 0) {
            result['addresses'][i] = iaddr;
        }
    }
    
    // Look up hostname addresses
    dns.resolve4(result['hostname'], (err, addresses) => {
        if(err) throw err;
        
        result['hostname_ips'] = addresses;
        
        // Send response
        res.send(JSON.stringify(result, null, 2));
    });
});
*/

app.get('/', routes.index);

app.listen(PORT);
console.log('Running on http://localhost:' + PORT);