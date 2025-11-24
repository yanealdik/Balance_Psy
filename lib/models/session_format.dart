enum SessionFormat { video, chat, audio }

String sessionFormatToApi(SessionFormat format) {
  switch (format) {
    case SessionFormat.video:
      return 'VIDEO';
    case SessionFormat.chat:
      return 'CHAT';
    case SessionFormat.audio:
      return 'AUDIO';
  }
}
