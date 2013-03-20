//  Created by Dan Walkowski dwalkowski@mozilla.com

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

function injectLogoutCallback()
{
  try
  {    
    //experimental logout callback
    var logoutCallback = function() {
      window.location = "personacallback://logouteverywhere";
    };
    
    BrowserID.internal.logoutEverywhere(logoutCallback);
    
  }
  catch (err)
  {
    return err;
  }
  
  return "success";
};

window.setTimeout(injectLogoutCallback, 50);

