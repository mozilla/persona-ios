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

