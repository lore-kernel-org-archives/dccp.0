From: babil <golam.sarwar@nicta.com.au>
Date: Tue, 04 Mar 2008 11:46:19 +0000
Subject: dccp_pr_debug or probe.c
Message-Id: <200803042246.19990.golam.sarwar@nicta.com.au>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_LaTzH2fxCmotHEX"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--Boundary-00=_LaTzH2fxCmotHEX
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi list,

Could anyone please tell me how to grab "dccp_pr_debug" outputs ?? I'm using 
kernel 2.6.20.

I needed to print the loss-interval array (li_entry->dccplih_interval) for 
which I modified the probe.c. But, it wont print anything 
inside "list_for_each_entry_safe(li_entry, li_next, list, dccplih_node)".

I'm attaching my modified probe.c. My modifications are marked with "babil". 
If it cant work, if anyone could please tell me how to grab "dccp_pr_debug" 
outputs, that would have been a great help.

I've also tried putting printk's in loss_interval.c, but failed catch any 
output.

Kind Regards,
-Golam Sarwar (babil)

--Boundary-00=_LaTzH2fxCmotHEX
Content-Type: text/x-csrc;
  charset="us-ascii";
  name="probe.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="probe.c"

/*
 * dccp_probe - Observe the DCCP flow with kprobes.
 *
 * The idea for this came from Werner Almesberger's umlsim
 * Copyright (C) 2004, Stephen Hemminger <shemminger@osdl.org>
 *
 * Modified for DCCP from Stephen Hemminger's code
 * Copyright (C) 2006, Ian McDonald <ian.mcdonald@jandi.co.nz>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <linux/kernel.h>
#include <linux/kprobes.h>
#include <linux/socket.h>
#include <linux/dccp.h>
#include <linux/proc_fs.h>
#include <linux/module.h>
#include <linux/kfifo.h>
#include <linux/vmalloc.h>

#include "dccp.h"
#include "ccid.h"
#include "ccids/ccid3.h"


//babil
static const char *ccid3_tx_state_name(enum ccid3_hc_tx_states state)
{
	static char *ccid3_state_names[] = {
	[TFRC_SSTATE_NO_SENT]  = "1",
	[TFRC_SSTATE_NO_FBACK] = "2",
	[TFRC_SSTATE_FBACK]    = "3",
	[TFRC_SSTATE_TERM]     = "4",
	};

	return ccid3_state_names[state];
}
//---


//babil - copied from loss_interval.h
struct dccp_li_hist_entry {
	struct list_head dccplih_node;
	u64		 dccplih_seqno:48,
			 dccplih_win_count:4;
	u32		 dccplih_interval;
	u32		 dccplih_loss_size;
};

//---





static int port;

static int bufsize = 64 * 1024;

static const char procname[] = "dccpprobe";

struct {
	struct kfifo	  *fifo;
	spinlock_t	  lock;
	wait_queue_head_t wait;
	struct timeval	  tstart;
} dccpw;

static void printl(const char *fmt, ...)
{
	va_list args;
	int len;
	struct timeval now;
	char tbuf[256];
	
	va_start(args, fmt);
	do_gettimeofday(&now);

	now.tv_sec -= dccpw.tstart.tv_sec;
	now.tv_usec -= dccpw.tstart.tv_usec;
	if (now.tv_usec < 0) {
		--now.tv_sec;
		now.tv_usec += 1000000;
	}

	len = sprintf(tbuf, "%lu.%06lu ",
		      (unsigned long) now.tv_sec,
		      (unsigned long) now.tv_usec);
	len += vscnprintf(tbuf+len, sizeof(tbuf)-len, fmt, args);
	va_end(args);

	kfifo_put(dccpw.fifo, tbuf, len);
	wake_up(&dccpw.wait);
}

static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,struct msghdr *msg, size_t size)
{
	const struct dccp_minisock *dmsk = dccp_msk(sk);
	const struct inet_sock *inet = inet_sk(sk);
	const struct ccid3_hc_tx_sock *hctx;
	
	//babil
	const struct ccid3_hc_rx_sock *hcrx;
	struct dccp_li_hist_entry *li_entry, *li_next;
	struct list_head *list;
	int i=1;
	//---


//babil		

	if (dmsk->dccpms_rx_ccid == DCCPC_CCID3)
	{
		hcrx = ccid3_hc_rx_sk(sk);
		list = &hcrx->ccid3hcrx_li_hist;
	}
	else
		hcrx = NULL;

		
		if (hcrx)
		{
			
			list_for_each_entry_safe(li_entry, li_next, list, dccplih_node) 
			{
				printl("\nbabil ");		
				
				if (li_entry->dccplih_interval != ~0U) 
				{
					printl("s[%d]: %d* ",i,li_entry->dccplih_interval);
					i++;
				}
				else
				{
					printl("empty loss interval");
				}
				
				printl("\n");
				
			}
		}
//---


	

	if (dmsk->dccpms_tx_ccid == DCCPC_CCID3)
		hctx = ccid3_hc_tx_sk(sk);
	else
		hctx = NULL;
	

	if (port == 0 || ntohs(inet->dport) == port || ntohs(inet->sport) == port) 
	{
		
		if (hctx)
		{
			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %d %u "
			       "%llu %llu %d %s\n",
			       NIPQUAD(inet->saddr), ntohs(inet->sport),
			       NIPQUAD(inet->daddr), ntohs(inet->dport), size,
			       hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
			       hctx->ccid3hctx_p, hctx->ccid3hctx_x_calc,
			       hctx->ccid3hctx_x_recv >> 6,
			       hctx->ccid3hctx_x >> 6, hctx->ccid3hctx_t_ipi, ccid3_tx_state_name(hctx->ccid3hctx_state) );
		}	
		else 
		{
			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d\n",
			       NIPQUAD(inet->saddr), ntohs(inet->sport),
			       NIPQUAD(inet->daddr), ntohs(inet->dport), size);
		}


	}

	jprobe_return();
	return 0;
}

static struct jprobe dccp_send_probe = {
	.kp	= {
		.symbol_name = "dccp_sendmsg",
	},
	.entry	= JPROBE_ENTRY(jdccp_sendmsg),
};

static int dccpprobe_open(struct inode *inode, struct file *file)
{
	kfifo_reset(dccpw.fifo);
	do_gettimeofday(&dccpw.tstart);
	return 0;
}

static ssize_t dccpprobe_read(struct file *file, char __user *buf,
			      size_t len, loff_t *ppos)
{
	int error = 0, cnt = 0;
	unsigned char *tbuf;

	if (!buf || len < 0)
		return -EINVAL;

	if (len == 0)
		return 0;

	tbuf = vmalloc(len);
	if (!tbuf)
		return -ENOMEM;

	error = wait_event_interruptible(dccpw.wait,
					 __kfifo_len(dccpw.fifo) != 0);
	if (error)
		goto out_free;

	cnt = kfifo_get(dccpw.fifo, tbuf, len);
	error = copy_to_user(buf, tbuf, cnt);

out_free:
	vfree(tbuf);

	return error ? error : cnt;
}

static struct file_operations dccpprobe_fops = {
	.owner	 = THIS_MODULE,
	.open	 = dccpprobe_open,
	.read    = dccpprobe_read,
};

static __init int dccpprobe_init(void)
{
	int ret = -ENOMEM;

	init_waitqueue_head(&dccpw.wait);
	spin_lock_init(&dccpw.lock);
	dccpw.fifo = kfifo_alloc(bufsize, GFP_KERNEL, &dccpw.lock);
	if (IS_ERR(dccpw.fifo))
		return PTR_ERR(dccpw.fifo);

	if (!proc_net_fops_create(procname, S_IRUSR, &dccpprobe_fops))
		goto err0;

	ret = register_jprobe(&dccp_send_probe);
	if (ret)
		goto err1;

	pr_info("DCCP watch registered (port=%d)\n", port);
	return 0;
err1:
	proc_net_remove(procname);
err0:
	kfifo_free(dccpw.fifo);
	return ret;
}
module_init(dccpprobe_init);

static __exit void dccpprobe_exit(void)
{
	kfifo_free(dccpw.fifo);
	proc_net_remove(procname);
	unregister_jprobe(&dccp_send_probe);

}
module_exit(dccpprobe_exit);

MODULE_PARM_DESC(port, "Port to match (0=all)");
module_param(port, int, 0);

MODULE_PARM_DESC(bufsize, "Log buffer size (default 64k)");
module_param(bufsize, int, 0);

MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>");
MODULE_DESCRIPTION("DCCP snooper");
MODULE_LICENSE("GPL");

--Boundary-00=_LaTzH2fxCmotHEX--
