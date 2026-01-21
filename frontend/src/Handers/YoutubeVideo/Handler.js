export const embedVideo = function (embedVideoConfig) {
  return function () {
    // Create the player
    try {
      const player = new YT.Player(embedVideoConfig.resultPreviewId, {
        height: embedVideoConfig.height,
        width: embedVideoConfig.width,
        videoId: embedVideoConfig.videoId,
        playerVars: {
          playsinline: 1,
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
