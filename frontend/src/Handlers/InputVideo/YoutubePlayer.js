let player;
export const embedVideo = function (embedVideoConfig) {
  return function () {
    // Check if player already exists
    if (typeof player !== "undefined" && player !== null) {
      // Check if the video ID is the same as the currently loaded video
      try {
        if (player.getVideoData && typeof player.getVideoData === "function") {
          const videoData = player.getVideoData();
          const currentVideoId = videoData && videoData.video_id;

          // If the video ID is the same, do nothing
          if (currentVideoId === embedVideoConfig.videoId) {
            console.log("Video ID is the same, skipping reload");
            return;
          }
        }
      } catch (e) {
        // If we can't get video data, proceed with loading the video
        console.log("Could not get current video data, proceeding with load");
      }

      // Player exists and video ID is different, load new video using loadVideoById
      try {
        player.loadVideoById({
          videoId: embedVideoConfig.videoId,
          startSeconds: embedVideoConfig.startTime,
          // endSeconds: Number,
        });
        console.log("Video loaded using loadVideoById");
      } catch (error) {
        console.error("Error loading video:", error);
        throw error;
      }
    } else {
      // Player doesn't exist, create a new one
      try {
        player = new YT.Player(embedVideoConfig.resultPreviewId, {
          height: embedVideoConfig.height,
          width: embedVideoConfig.width,
          videoId: embedVideoConfig.videoId,
          playerVars: {
            playsinline: 1,
            start: embedVideoConfig.startTime,
            loop: 1,
          },
        });
        console.log("Player created successfully");
      } catch (error) {
        console.error("Error creating YouTube player:", error);
        throw error;
      }
    }
  };
};
export const getPlayerCurrentTime = () => {
  if (typeof player !== "undefined" && player !== null) {
    try {
      if (
        player.getCurrentTime &&
        typeof player.getCurrentTime === "function"
      ) {
        return player.getCurrentTime();
      }
    } catch (e) {
      console.error("Error calling getCurrentTime:", e);
    }
  }
  return 0;
};

export const getVideoDuration = () => {
  if (typeof player !== "undefined" && player !== null) {
    try {
      // Check if getDuration method exists and player is ready
      if (player.getDuration && typeof player.getDuration === "function") {
        const duration = player.getDuration();
        // getDuration returns NaN or undefined if not ready
        if (duration && !isNaN(duration) && duration > 0) {
          return duration;
        }
      }
    } catch (e) {
      console.error("Error calling getDuration:", e);
    }
  }
  return 100; // Default fallback
};

export const isPlayerReady = () => {
  // Check if player exists
  if (typeof player === "undefined" || player === null) {
    return false;
  }

  // Check if getDuration is available
  const hasGetDuration =
    player.getDuration && typeof player.getDuration === "function";

  // Check if getCurrentTime is available
  const hasGetCurrentTime =
    player.getCurrentTime && typeof player.getCurrentTime === "function";

  // Check if player is actually ready by trying to get duration
  let isReady = false;
  if (hasGetDuration) {
    try {
      const duration = player.getDuration();
      // getDuration returns NaN or undefined if not ready, or a positive number if ready
      isReady = duration && !isNaN(duration) && duration > 0;
    } catch (e) {
      // If calling getDuration throws an error, player is not ready
      isReady = false;
    }
  }

  // Return true only if all checks pass
  return hasGetDuration && hasGetCurrentTime && isReady;
};
