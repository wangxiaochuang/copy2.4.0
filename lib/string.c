#include <linux/types.h>
#include <linux/string.h>

#ifndef __HAVE_ARCH_STRNLEN
size_t strnlen(const char * s, size_t count)
{
	const char *sc;

	for (sc = s; count-- && *sc != '\0'; ++sc)
		/* nothing */;
	return sc - s;
}
#endif