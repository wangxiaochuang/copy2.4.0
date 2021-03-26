#ifndef _LINUX_SOCKET_H
#define _LINUX_SOCKET_H

#if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)

#include <asm/socket.h>			/* arch-dependent defines	*/
#include <linux/sockios.h>		/* the SIOCxxx I/O controls	*/
#include <linux/uio.h>			/* iovec support		*/
#include <linux/types.h>		/* pid_t			*/

#endif

#endif