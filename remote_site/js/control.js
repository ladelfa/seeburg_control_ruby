var currentlyPlaying = false;

$(document).ready(function(){
  function guidGenerator() {
      var S4 = function() {
         return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
      };
      return (S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4());
  }


  var controlUrl = '/control.rb?session=' + guidGenerator();
  var actionUrl = function(a){return (controlUrl + '&action=' + a)};

  var rejectRecord = function(){
    if(confirm("This will reject the current record and move on to the next one.\n\n" +
                "Are you sure you hate this song enough to prevent\n" +
                "everyone else in the world from hearing the end of it?\n\n" +
                "WARNING: Abusers of this feature are subject to blacklisting.")) {
      $.get(actionUrl('reject'));
    }
    return(false);
  };

  var addTime = function(){$.get(actionUrl('add_time'), function(){
    setTimeout(updateStatus, 300); // Give the server a chance to update the time-left cache.
    setTimeout(updateStatus, 900); // Give the server a chance to update the time-left cache.
    setTimeout(updateStatus, 2700); // Give the server a chance to update the time-left cache.
  }); };

  var addMinimumTime = function(){
    $.get(actionUrl('get_current_status'), function(d){
      if(d == 'standby') addTime();
    })
  };

  var rejectButton = $(".rejectButton").click(rejectRecord);

  var timeDial = $('#timeDial').timeDial({
      max: 120,
      callback_freq: 300,
      callback_function: function(){
        return(parseInt($('#minutesLeft').html()));
      },
      click_function: function(dial, display) {
        $(display).effect("shake", { direction:'right', distance:3, times:1 }, 100);
        addTime.call();
      }
    });

  var updateStatus = function(){
    // Get current status and enable various parts of the page
    $.get(actionUrl('get_current_status'), function(d){
      var sentence = 'The jukebox is currently ';
      var controllable = false;
      var playable = false;
      currentlyPlaying = false;

      switch(d) {
        case 'off':
          sentence += 'turned off.';
          break;
        case 'standby':
          sentence += 'in standby mode, and can be turned on remotely.';
          controllable = playable = true;
          break;
        case 'public_play':
          sentence += 'on, and can be controlled remotely.';
          controllable = playable = true;
          currentlyPlaying = true;
          break;
        case 'home_play':
          sentence += 'on, but remote control is disabled at this time.';
          playable = true;
          currentlyPlaying = true;
          break;
        case 'maintenance':
          sentence += 'offline for maintenance.';
          break;
        default:
          sentence += 'currently in an unknown state.';
      }


      $('#currentStatus').html(sentence);

      if(controllable){
        $('.controller').show();
        // Get number and stow it where timeDial can read it frequently.
        $.get(actionUrl('get_minutes_remaining'), function(d){
          $('#minutesLeft').html(d);
        });
      } else {
        $('.controller').hide();
        $('#minutesLeft').html('0');
      }

      if(playable){
        $('.player').show();
      } else {
        $('.player').hide();
      }

      if(currentlyPlaying){
        $.get(actionUrl('get_current_audio_connection_count'), function(d){
          var sentence
          switch(parseInt(d)) {
            case 0:
              sentence = "Nobody is listening to the jukebox right now."
              break;
            case 1:
              sentence = "One person is listening to the jukebox right now."
              break;
            default:
              sentence = d + " people are listening to the jukebox right now."
              break;
          }
          $("#current_listeners").html(sentence).show();
        });

      } else {
       $("#current_listeners").html(sentence).hide();
      }

    });
  }

  updateStatus();
  setInterval(updateStatus, 60000);

  $('.pointAtControlPanel').click(function(){
    _this = this;
    $('html, body').animate({ scrollTop: $(_this).offset().top }, 1000, function(){
      $("#controlPanel").effect("shake", { direction:'up', distance:6, times:1 }, 150);
    });
    return false;
  });

  var radio_media = { mp3: "http://www.seeburgremote.net/radio" };
  radio_media = { mp3: "http://www.seeburgremote.net/radio/stream.mp3" };

  $("#jquery_jplayer").jPlayer({
    ready: function () {
      $(this).jPlayer("setMedia", radio_media);
    },
    preload: "none",
    swfPath: "/js",
    supplied: "mp3",
    play: function(){ addMinimumTime(); },
    pause: function(){
      // Disconnect the stream
      $("#jquery_jplayer").jPlayer("clearMedia");
      $("#jquery_jplayer").jPlayer("setMedia", radio_media);
      setTimeout(updateStatus, 1000);
    }
  });
  //$("#jplayer_inspector").jPlayerInspector({jPlayer:$("#jquery_jplayer_1")});

});

