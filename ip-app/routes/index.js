const os = require('os');
const dns = require('dns');

// Get the home page.
exports.index = function(req, res){
    var hostinfo = {};
    
    // Get the hostname
    hostinfo['hostname'] = os.hostname();
    
    // Get the IPv4 addresses for each network interface
    hostinfo['interfaces'] = {};
    var interfaces = os.networkInterfaces();
    for(var i in interfaces) {
        var iaddr = []
        for(var a = 0; a < interfaces[i].length; a++) {
            if(interfaces[i][a].family == 'IPv4') {
                iaddr.push(interfaces[i][a].address)
            }
        }
        if(iaddr.length > 0) {
            hostinfo['interfaces'][i] = iaddr;
        }
    }
    
    // Look up hostname addresses
    dns.resolve4(hostinfo['hostname'], (err, addresses) => {
        if(err) throw err;
        
        hostinfo['hostname_ips'] = addresses;
        
        console.log(hostinfo);
        
        // Send response
        res.render('index', { title: hostinfo.hostname, hostinfo: hostinfo });
    });
};