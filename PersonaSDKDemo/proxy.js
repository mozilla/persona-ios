//  PersonaSDKDemo
//
// Created by Dan Walkowski dwalkowski@mozilla.com

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */


// This receives assertion verification requests from clients, and if they are valid, we send back the
//   verification receipt with an added secret for use as a cookie.
// In the code below, we are not verifying it ourselves, but instead passing the assertion on to the 
//   persona.org verifier. Then I'm sticking one of two canned 'secrets' into the headers of the response if the 
//   verification succeeded.


// In simplest terms, this is an HTTP <-> HTTPS reverse proxy to the persona assertion verifier.
// In a 'real' configuration, it would be HTTPS <-> HTTPS, but that's a pain for testing.

var http = require('http');
var https = require('https');
var querystring = require('querystring');

//A 'database' of users on this site, with 'secrets' (canned cookie values) to return to the client
// if there is a match.

//password for personasdktest@gmail.com is 'testuser'
var users = {'personasdktest@gmail.com':'1234567890', '<YOUR_EMAIL>':'ABCDEFGHIJKL'};


//THIS IS THE VERIFICATION SERVER
http.createServer(function(clientRequest, clientResponse) {

  var proxyRequest = https.request({
    host: 'verifier.login.persona.org',
    port: 443,
    path: '/verify',
    method: 'POST'
  }, 

  function(proxyResponse) {
    //if assertion valid, then add proper secret
    var responsedata = '';
    proxyResponse.on('data', function(chunk) {
                                            responsedata += chunk;
                                          });
    proxyResponse.on('end', function() {
                                        try {
                                        var receipt = JSON.parse(responsedata);
                                        if (receipt['status'] == 'okay') {
                                          var email = receipt['email']; 
                                          var secret = users[email];
                                          if (secret) {
                                            clientResponse.setHeader("Set-Cookie", [secret]);
                                          }
                                        }
                                      } catch(err) {
                                        console.log("error parsing verification result: " + err);
                                      }

                                        clientResponse.writeHead(proxyResponse.statusCode, proxyResponse.headers);
                                        clientResponse.write(responsedata);
                                        clientResponse.end();
                                    });

    
  });
  
  var clientReqData = '';
  clientRequest.on('data', function(chunk) {
                                            clientReqData += chunk;
                                          });
  

  clientRequest.on('end', function() {
                                    try {
                                      var reqjson = JSON.parse(clientReqData);
                                      var proxyData = querystring.stringify({
                                                                            assertion: reqjson.assertion,
                                                                            audience: "http://www.mozilla.com"
                                                                          });
                                    } catch(err) {
                                      console.log("error parsing incoming json result: " + err);
                                    }

                                    proxyRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                                    proxyRequest.setHeader('Content-Length', proxyData.length);
                                    proxyRequest.write(proxyData);
                                    proxyRequest.end();
                                });


}).listen(8080);













//THIS IS THE USER DATA RETRIEVAL SERVER.  SUPPLY A VALID COOKIE, RECEIVE THE USER DATA
var userdata = {'1234567890':{'name':'Persona Test User', 'color':'#AAAAFF', 'monster':'Godzilla'},
                'ABCDEFGHIJ':{'name':'Your Name', 'color':'#AAFFAA', 'monster':'Rodan'}};

http.createServer(function(contentRequest, contentResponse) {
  var cookie = contentRequest.headers['cookie'];
  if (cookie) {
    if (userdata[cookie]){
      console.log('found user data ' + userdata[cookie]);
      contentResponse.write(JSON.stringify(userdata[cookie]));
    }
    else {
      console.log('no matching user');
      contentResponse.write('User Not Found');
    }
  } else {
    console.log('no user cookie');
    contentResponse.write('No Cookie Found');
  }
  contentResponse.end();
}).listen(8090);


