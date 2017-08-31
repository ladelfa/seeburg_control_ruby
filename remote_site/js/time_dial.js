/*!
 * timeDial 
 *
 * based on (stripped down from, mostly)
 *
 *  jquery.tzineClock.js - Tutorialzine Colorful Clock Plugin
 *
 *  Copyright (c) 2009 Martin Angelov
 *  http://tutorialzine.com/
 *
 */

(function($){
  
  // A global array used by the functions of the plug-in:
  var gVars = {};

  // Extending the jQuery core:
  $.fn.timeDial = function(opts){
  
    // "this" contains the elements that were selected when calling the plugin: $('elements').tzineClock();
    // If the selector returned more than one element, use the first one:
    
    var container = this.eq(0);
  
    if(!container)
    {
      try{
        console.log("Invalid selector!");
      } catch(e){}
      
      return false;
    }
    
    if(!opts) opts = {}; 
    
    var defaults = {
      max: 100,
      callback_freq: 1000,
      callback_function: function(){},
      click_function: function(){}
    };
    
    /* Merging the provided options with the default ones (will be used in future versions of the plugin): */
    $.each(defaults,function(k,v){
      opts[k] = opts[k] || defaults[k];
    })

    // Calling the setUp function and passing the container,
    // will be available to the setUp function as "this":
    setUp.call(container, opts);
    
    return this;
  }
  
  function setUp(opts)
  {
    var dial;
    
    // Creating a new element and setting the color as a class name:
    dial = $('<div>').attr('class', 'red dial').html(
      '<div class="display"></div>'+

      '<div class="front left"></div>'+

      '<div class="rotate left">'+
        '<div class="bg left"></div>'+
      '</div>'+

      '<div class="rotate right">'+
        '<div class="bg right"></div>'+
      '</div>'
    );

    // Appending to the container:
    $(this).append(dial);

    // Assigning some of the elements as variables for speed:
    dial.rotateLeft = dial.find('.rotate.left');
    dial.rotateRight = dial.find('.rotate.right');
    dial.display = dial.find('.display');
    dial.click(function(){ opts['click_function'].call(dial, dial, dial.display); callback(); });
    dial.display.click(function(){dial.trigger('click'); return false;});
    
    // Setting up a interval, executed every 1000 milliseconds:
    callback = function(){
      current = opts['callback_function'].call();
      if(isNaN(current)) current = 0;
      animation(dial, current, opts['max']);
    };
    
    setInterval(callback, opts['callback_freq']);
  }
  
  function animation(dial, current, total)
  {
    // Calculating the current angle:
    var angle = (360/total)*(current);
  
    if(angle<=180)
    {
      // The left part is rotated, and the right is currently hidden:
      dial.rotateRight.hide();
      dial.rotateLeft.show();
      rotateElement(dial.rotateLeft,angle);
    }
    else
    {
      // The first part of the rotation has completed, so we start rotating the right part:
      dial.rotateRight.show();
      dial.rotateLeft.show();      
      rotateElement(dial.rotateLeft,180);      
      rotateElement(dial.rotateRight,angle - 180);
    }

    
    // Setting the text inside of the display element, inserting a leading zero if needed:
    dial.display.html(current);
  }
  
  function rotateElement(element,angle)
  {
    // Rotating the element, depending on the browser:
    var rotate = 'rotate('+angle+'deg)';
    
    if(element.css('MozTransform')!=undefined)
      element.css('MozTransform',rotate);
      
    else if(element.css('WebkitTransform')!=undefined)
      element.css('WebkitTransform',rotate);
  
    // A version for internet explorer using filters, works but is a bit buggy (no surprise here):
    else if(element.css("filter")!=undefined)
    {
      var cos = Math.cos(Math.PI * 2 / 360 * angle);
      var sin = Math.sin(Math.PI * 2 / 360 * angle);
      
      element.css("filter","progid:DXImageTransform.Microsoft.Matrix(M11="+cos+",M12=-"+sin+",M21="+sin+",M22="+cos+",SizingMethod='auto expand',FilterType='nearest neighbor')");
  
      element.css("left",-Math.floor((element.width()-100)/2));
      element.css("top",-Math.floor((element.height()-100)/2));
    }
  
  }
  
})(jQuery)

