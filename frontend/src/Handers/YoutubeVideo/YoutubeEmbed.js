export const embedVideo = function (embedVideoConfig) {
  return new YT.Player(embedVideoConfig.resultPreviewId, {
    height: "390",
    width: "640",
    videoId: embedVideoConfig.videoId,
    playerVars: {
      playsinline: 1,
    },
    //,
    // events: {
    //   'onReady': onPlayerReady,
    //   'onStateChange': onPlayerStateChange
    // }
  });
}
