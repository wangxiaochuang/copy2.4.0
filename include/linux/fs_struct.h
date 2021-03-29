#ifndef _LINUX_FS_STRUCT_H
#define _LINUX_FS_STRUCT_H
#ifdef __KERNEL__

struct fs_struct {
	atomic_t count;
	rwlock_t lock;
	int umask;
	struct dentry * root, * pwd, * altroot;
	struct vfsmount * rootmnt, * pwdmnt, * altrootmnt;
};

#define INIT_FS { \
	ATOMIC_INIT(1), \
	RW_LOCK_UNLOCKED, \
	0022, \
	NULL, NULL, NULL, NULL, NULL, NULL \
}

/*
 * Replace the fs->{rootmnt,root} with {mnt,dentry}. Put the old values.
 * It can block. Requires the big lock held.
 */

/*
 * Replace the fs->{pwdmnt,pwd} with {mnt,dentry}. Put the old values.
 * It can block. Requires the big lock held.
 */

#endif
#endif
