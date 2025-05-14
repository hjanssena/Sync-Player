# just_audio
-keep class com.ryanheise.just_audio.** { *; }

# If using just_audio_media_kit
-keep class com.ryanheise.just_audio_media_kit.** { *; }

# ExoPlayer (required by just_audio or directly by your plugin)
-keep class com.google.android.exoplayer2.** { *; }
