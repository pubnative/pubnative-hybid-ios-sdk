/**
 * @file NETypeUtils.h
 * Common utils for NETypes.
 */

#ifndef NETypeUtils_H
#define NETypeUtils_H

#include <stddef.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>


// Enums and Options
#ifndef NE_ENUM

#ifdef NS_ENUM
# define NE_ENUM(...) NS_ENUM(__VA_ARGS__)
# define NE_CLOSED_ENUM(_type, _name) NS_CLOSED_ENUM(_type, _name)
# define NE_OPTIONS(_type, _name) NS_OPTIONS(_type, _name)
#else

#if __has_attribute(enum_extensibility)
#define __NE_ENUM_ATTRIBUTES __attribute__((enum_extensibility(open)))
#define __NE_CLOSED_ENUM_ATTRIBUTES __attribute__((enum_extensibility(closed)))
#define __NE_OPTIONS_ATTRIBUTES __attribute__((flag_enum,enum_extensibility(open)))
#else
#define __NE_ENUM_ATTRIBUTES
#define __NE_CLOSED_ENUM_ATTRIBUTES
#define __NE_OPTIONS_ATTRIBUTES
#endif

#define __NE_ENUM_GET_MACRO(_1, _2, NAME, ...) NAME
#if (__cplusplus && __cplusplus >= 201103L && \
    (defined(__has_extension) && defined(__has_feature) && \
        (__has_extension(cxx_strong_enums) || __has_feature(objc_fixed_enum))) || (!__cplusplus && __has_feature(objc_fixed_enum)))
#define __NE_NAMED_ENUM(_type, _name)     enum __NE_ENUM_ATTRIBUTES _name : _type _name; enum _name : _type
#define __NE_ANON_ENUM(_type)             enum __NE_ENUM_ATTRIBUTES : _type
#define NE_CLOSED_ENUM(_type, _name)      enum __NE_CLOSED_ENUM_ATTRIBUTES _name : _type _name; enum _name : _type
#if (__cplusplus)
#define NE_OPTIONS(_type, _name) _type _name; enum __NE_OPTIONS_ATTRIBUTES : _type
#else
#define NE_OPTIONS(_type, _name) enum __NE_OPTIONS_ATTRIBUTES _name : _type _name; enum _name : _type
#endif
#else
#define __NE_NAMED_ENUM(_type, _name) _type _name; enum
#define __NE_ANON_ENUM(_type) enum
#define NE_CLOSED_ENUM(_type, _name) _type _name; enum
#define NE_OPTIONS(_type, _name) _type _name; enum
#endif
#define NE_ENUM(...) __NE_ENUM_GET_MACRO(__VA_ARGS__, __NE_NAMED_ENUM, __NE_ANON_ENUM, )(__VA_ARGS__)

#endif

#endif


// Min Max
#ifndef MAX

#define MAX(x, y) (((x) > (y)) ? (x) : (y))

#endif

#ifndef MIN

#define MIN(x, y) (((x) < (y)) ? (x) : (y))

#endif

#ifdef __cplusplus
extern "C" {
#endif

int findStrIndexWithDefault(const char * const arr[], int n, const char * const searchTerm, int defaultIndex);

#ifdef __cplusplus
}
#endif

#ifndef LOOKUP_ENUM_FROM_REPR

#define LOOKUP_ENUM_FROM_REPR(_repr, _enumName, _default) \
    ((_enumName) findStrIndexWithDefault(_enumName##Reprs, \
                                         sizeof(_enumName##Reprs) / sizeof(const char *), \
                                         _repr, \
                                         (int) _default))

#endif

#endif /* NETypeUtils_H */
