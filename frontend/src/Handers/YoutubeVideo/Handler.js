export const embedVideo = function (embedVideoConfig) {
  return function () {
    // Check if YouTube API is loaded
    if (typeof YT === 'undefined' || typeof YT.Player === 'undefined') {
      const errorMsg = 'YouTube IFrame API is not loaded. Please wait a moment and try again, or refresh the page.';
      console.error(errorMsg);
      console.error('Make sure the script tag is in the HTML: <script src="https://www.youtube.com/iframe_api"></script>');
      throw new Error(errorMsg);
    }

    // Get the target element
    const targetElement = document.getElementById(embedVideoConfig.resultPreviewId);
    if (!targetElement) {
      const errorMsg = 'Target element not found: ' + embedVideoConfig.resultPreviewId;
      console.error(errorMsg);
      throw new Error(errorMsg);
    }

    console.log('Creating YouTube player with videoId:', embedVideoConfig.videoId);
    console.log('Target element:', targetElement);
    
    // Check if there's already a player and destroy it
    if (targetElement.dataset.playerId) {
      try {
        var existingPlayer = window['ytplayer_' + targetElement.dataset.playerId];
        if (existingPlayer && typeof existingPlayer.destroy === 'function') {
          console.log('Destroying existing player');
          existingPlayer.destroy();
        }
      } catch (e) {
        console.warn('Error destroying existing player:', e);
      }
    }
    
    // Create the player
    try {
      const player = new YT.Player(embedVideoConfig.resultPreviewId, {
        height: "390",
        width: "640",
        videoId: embedVideoConfig.videoId,
        playerVars: {
          playsinline: 1,
        },
        events: {
          'onReady': function(event) {
            console.log('YouTube player is ready');
            // Store player ID for later cleanup
            if (event.target && event.target.a && event.target.a.id) {
              targetElement.dataset.playerId = event.target.a.id;
            }
          },
          'onError': function(event) {
            console.error('YouTube player error:', event.data);
            console.error('Error codes: 2=invalid video ID, 5=HTML5 error, 100=video not found, 101/150=playback not allowed');
          },
          'onStateChange': function(event) {
            console.log('YouTube player state changed:', event.data);
          }
        }
      });
      console.log('Player created successfully');
      return player;
    } catch (error) {
      console.error('Error creating YouTube player:', error);
      throw error;
    }
  };
};
