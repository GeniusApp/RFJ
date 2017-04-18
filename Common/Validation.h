#ifndef Validation_h
#define Validation_h

#ifndef ISEMPTY
#define ISEMPTY(__OBJECT) ( (nil == __OBJECT) ? YES : ( (nil != __OBJECT && [__OBJECT respondsToSelector:@selector(count)]) ? ([__OBJECT performSelector:@selector(count)] <= 0) : ( (nil != __OBJECT && [__OBJECT respondsToSelector:@selector(length)]) ? ([__OBJECT performSelector:@selector(length)] <= 0) : NO ) ) )
#endif

#ifndef NOTEMPTY
#define NOTEMPTY(__OBJECT) (ISEMPTY(__OBJECT) == NO)
#endif

#ifndef VALID
#define VALID(__OBJECT, __CLASSNAME) (nil != __OBJECT && [__OBJECT isKindOfClass:[__CLASSNAME class]])
#endif

#ifndef VALID_EMPTY
#define VALID_EMPTY(__OBJECT, __CLASSNAME) (VALID(__OBJECT, __CLASSNAME) == YES && ISEMPTY(__OBJECT) == YES)
#endif

#ifndef VALID_NOTEMPTY
#define VALID_NOTEMPTY(__OBJECT, __CLASSNAME) (VALID(__OBJECT, __CLASSNAME) == YES && ISEMPTY(__OBJECT) == NO)
#endif

#endif /* Validation_h */
