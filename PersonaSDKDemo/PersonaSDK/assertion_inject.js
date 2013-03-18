function injectPersonaCallbacks()
{
  try
  {
    // The origin is setup when this code template is loaded in the native application
    var origin = "%@";
    
    var callbackToCocoa = function(name, value) {
      window.location = "personacallback://" + name + "/callback?data=" + value;
    };
    
    var internalGetCallback = function(assertion) {
      if (assertion) {
        callbackToCocoa("gotassertion", assertion);
      } else {
        callbackToCocoa("failassertion", "");
      }
    };

    var internalSetPersistentCallback = function() {
      BrowserID.internal.get(origin, internalGetCallback, {silent: false})
    };

    BrowserID.internal.setPersistent(origin, internalSetPersistentCallback);
  
  }
  catch (err)
  {
    return err;
  }
  
  return "success";
};

window.setTimeout(injectPersonaCallbacks, 50);

