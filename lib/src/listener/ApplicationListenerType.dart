enum ApplicationListenerType {
  // 应用启动前
  STARTING,
  // 环境准备完成
  ENVIRONMENT_PREPARED,
  // 应用上下文初始化完成
  CONTEXT_INITIALIZED,
  // 应用准备完成
  PREPARED,
  // 应用启动完成
  STARTUP,
  // 应用准备就绪
  READY,
  // 应用启动失败
  FAILED,
  // 应用关闭
  CLOSE,
  // 应用错误
  ERROR
}
