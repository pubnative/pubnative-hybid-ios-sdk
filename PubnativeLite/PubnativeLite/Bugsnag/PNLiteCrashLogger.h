
#ifndef PNLiteCrashLogger_h
#define PNLiteCrashLogger_h

#define PNLITE_LOGLEVEL_DEBUG 40
#define PNLITE_LOGLEVEL_INFO 30
#define PNLITE_LOGLEVEL_WARN 20
#define PNLITE_LOGLEVEL_ERR 10
#define PNLITE_LOGLEVEL_NONE 0

#ifndef PNLITE_LOG_LEVEL
#define PNLITE_LOG_LEVEL PNLITE_LOGLEVEL_INFO
#endif

#if PNLITE_LOG_LEVEL >= PNLITE_LOGLEVEL_ERR
#define pnlite_log_err NSLog
#else
#define pnlite_log_err(format, ...)
#endif

#if PNLITE_LOG_LEVEL >= PNLITE_LOGLEVEL_WARN
#define pnlite_log_warn NSLog
#else
#define pnlite_log_warn(format, ...)
#endif

#if PNLITE_LOG_LEVEL >= PNLITE_LOGLEVEL_INFO
#define pnlite_log_info NSLog
#else
#define pnlite_log_info(format, ...)
#endif

#if PNLITE_LOG_LEVEL >= PNLITE_LOGLEVEL_DEBUG
#define pnlite_log_debug NSLog
#else
#define pnlite_log_debug(format, ...)
#endif

#endif /* PNLiteCrashLogger_h */
