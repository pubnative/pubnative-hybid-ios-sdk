
#ifndef PNLiteCrashLogger_h
#define PNLiteCrashLogger_h

#define PNLite_LOGLEVEL_DEBUG 40
#define PNLite_LOGLEVEL_INFO 30
#define PNLite_LOGLEVEL_WARN 20
#define PNLite_LOGLEVEL_ERR 10
#define PNLite_LOGLEVEL_NONE 0

#ifndef PNLite_LOG_LEVEL
#define PNLite_LOG_LEVEL PNLite_LOGLEVEL_INFO
#endif

#if PNLite_LOG_LEVEL >= PNLite_LOGLEVEL_ERR
#define pnlite_log_err NSLog
#else
#define pnlite_log_err(format, ...)
#endif

#if PNLite_LOG_LEVEL >= PNLite_LOGLEVEL_WARN
#define pnlite_log_warn NSLog
#else
#define pnlite_log_warn(format, ...)
#endif

#if PNLite_LOG_LEVEL >= PNLite_LOGLEVEL_INFO
#define pnlite_log_info NSLog
#else
#define pnlite_log_info(format, ...)
#endif

#if PNLite_LOG_LEVEL >= PNLite_LOGLEVEL_DEBUG
#define pnlite_log_debug NSLog
#else
#define pnlite_log_debug(format, ...)
#endif

#endif /* PNLiteCrashLogger_h */
