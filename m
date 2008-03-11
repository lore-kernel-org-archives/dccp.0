From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 11 Mar 2008 12:54:33 +0000
Subject: Re: dccp_pr_debug or probe.c
Message-Id: <20080311125433.GB15352@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803042246.19990.golam.sarwar@nicta.com.au>
In-Reply-To: <200803042246.19990.golam.sarwar@nicta.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Babil,
as per last email - you are using an old kernel which is known to have
problems. Please consider using at least the current stable version
(2.6.24.3) from http://www.kernel.org/

If you are able to use git, you are still encouraged to use the test
tree. A howto for pulling from it is on 
http://www.linux-foundation.org/en/Net:DCCP_Testing#Experimental_DCCP_source_tree

Gerrit

Quoting babil:
| Thanks Ian. Thank you Gerrit.
| 
| I've found the problem. My modified code on 2.6.20 was going 
| to "dccp_tfrc_lib". But all the time, I was only reloading my newly 
| compiled "dccp_ccid3.ko". And also, I had to kill klogd and start it 
| as "klogd -x -f - -n -c 8" to capture the outputs to my preferred log file.
| 
| "echo 8 > /proc/sys/kernel/printk" was another trick, which I'm not sure, was 
| really necessary.
| 
| I've implemented a new function to comfortably print my debug lines from 
| loss_interval.h (attached: my_printk.c)
| 
| But, Now that I can log my loss interval samples ( s[0],s[1]... in my log 
| file), I can see, for a 1 min experiment, my P is gradually 
| decreasing/increasing. But for those instances my s[0] and w_tot are not 
| changing, which naturally brings the question, what's causing P to change 
| then ?
| 
| I'm calling "my_printk" directly after "i_mean" 
| and "hcrx->ccid3hcrx_p00000/i_mean" is calculated 
| in "ccid3_hc_rx_packet_recv" function. So, if "P" is changing there, "s[0]" 
| or "w_tot" must change. Or is this function inappropriate to track changes 
| in "P" and s[0].
| 
| I'm attaching my logged outputs for you to take a look.
| 
| Kind Regards,
| -babil.
| 
| 
| On Wed, 5 Mar 2008 12:35:19 am Gerrit Renker wrote:
| > | Could anyone please tell me how to grab "dccp_pr_debug" outputs ?? I'm
| > | using kernel 2.6.20.
| >
| > You need to enable debugging output (both in the kernel, options _
| > CONFIG_IP_DCCP_DEBUG, CONFIG_IP_DCCP_CCID2_DEBUG,
| > CONFIG_IP_DCCP_CCID3_DEBUG) and as module parameters:
| > http://www.linux-foundation.org/en/Net:DCCP_Testing#Enabling_debugging_outp
| >ut
| >
| > | I needed to print the loss-interval array (li_entry->dccplih_interval)
| > | for which I modified the probe.c. But, it wont print anything
| > | inside "list_for_each_entry_safe(li_entry, li_next, list, dccplih_node)".
| > |
| > | I'm attaching my modified probe.c. My modifications are marked with
| > | "babil". If it cant work, if anyone could please tell me how to grab
| > | "dccp_pr_debug" outputs, that would have been a great help.
| >
| > The code you are using is older hand has some problems. You can get a a
| > more up-to-date version from
| >   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25
| >
| > Using the test tree is encouraged for all testing:
| > 
| > http://www.linux-foundation.org/en/Net:DCCP_Testing#Experimental_DCCP_sourc
| >e_tree
| >
| > Secondly, the code tries to print RX socket variables in a kprobe which
| > is tied to events triggered by the TX socket (sendmsg). You can simply
| > use printk for output.
| >
| > | I've also tried putting printk's in loss_interval.c, but failed catch any
| > | output.
| >
| > There will only be output if actual loss occurs. You need to have loss
| > events, see
| > http://www.linux-foundation.org/en/Net:DCCP_Testing#Testbed_setup_for_DCCP
| >
| > | Kind Regards,
| > | -Golam Sarwar (babil)
| > |
| > | /*
| > |  * dccp_probe - Observe the DCCP flow with kprobes.
| > |  *
| > |  * The idea for this came from Werner Almesberger's umlsim
| > |  * Copyright (C) 2004, Stephen Hemminger <shemminger@osdl.org>
| > |  *
| > |  * Modified for DCCP from Stephen Hemminger's code
| > |  * Copyright (C) 2006, Ian McDonald <ian.mcdonald@jandi.co.nz>
| > |  *
| > |  * This program is free software; you can redistribute it and/or modify
| > |  * it under the terms of the GNU General Public License as published by
| > |  * the Free Software Foundation; either version 2 of the License, or
| > |  * (at your option) any later version.
| > |  *
| > |  * This program is distributed in the hope that it will be useful,
| > |  * but WITHOUT ANY WARRANTY; without even the implied warranty of
| > |  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
| > |  * GNU General Public License for more details.
| > |  *
| > |  * You should have received a copy of the GNU General Public License
| > |  * along with this program; if not, write to the Free Software
| > |  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
| > |  */
| > |
| > | #include <linux/kernel.h>
| > | #include <linux/kprobes.h>
| > | #include <linux/socket.h>
| > | #include <linux/dccp.h>
| > | #include <linux/proc_fs.h>
| > | #include <linux/module.h>
| > | #include <linux/kfifo.h>
| > | #include <linux/vmalloc.h>
| > |
| > | #include "dccp.h"
| > | #include "ccid.h"
| > | #include "ccids/ccid3.h"
| > |
| > |
| > | //babil
| > | static const char *ccid3_tx_state_name(enum ccid3_hc_tx_states state)
| > | {
| > | 	static char *ccid3_state_names[] = {
| > | 	[TFRC_SSTATE_NO_SENT]  = "1",
| > | 	[TFRC_SSTATE_NO_FBACK] = "2",
| > | 	[TFRC_SSTATE_FBACK]    = "3",
| > | 	[TFRC_SSTATE_TERM]     = "4",
| > | 	};
| > |
| > | 	return ccid3_state_names[state];
| > | }
| > | //---
| > |
| > |
| > | //babil - copied from loss_interval.h
| > | struct dccp_li_hist_entry {
| > | 	struct list_head dccplih_node;
| > | 	u64		 dccplih_seqno:48,
| > | 			 dccplih_win_count:4;
| > | 	u32		 dccplih_interval;
| > | 	u32		 dccplih_loss_size;
| > | };
| > |
| > | //---
| > |
| > |
| > |
| > |
| > |
| > | static int port;
| > |
| > | static int bufsize = 64 * 1024;
| > |
| > | static const char procname[] = "dccpprobe";
| > |
| > | struct {
| > | 	struct kfifo	  *fifo;
| > | 	spinlock_t	  lock;
| > | 	wait_queue_head_t wait;
| > | 	struct timeval	  tstart;
| > | } dccpw;
| > |
| > | static void printl(const char *fmt, ...)
| > | {
| > | 	va_list args;
| > | 	int len;
| > | 	struct timeval now;
| > | 	char tbuf[256];
| > |
| > | 	va_start(args, fmt);
| > | 	do_gettimeofday(&now);
| > |
| > | 	now.tv_sec -= dccpw.tstart.tv_sec;
| > | 	now.tv_usec -= dccpw.tstart.tv_usec;
| > | 	if (now.tv_usec < 0) {
| > | 		--now.tv_sec;
| > | 		now.tv_usec += 1000000;
| > | 	}
| > |
| > | 	len = sprintf(tbuf, "%lu.%06lu ",
| > | 		      (unsigned long) now.tv_sec,
| > | 		      (unsigned long) now.tv_usec);
| > | 	len += vscnprintf(tbuf+len, sizeof(tbuf)-len, fmt, args);
| > | 	va_end(args);
| > |
| > | 	kfifo_put(dccpw.fifo, tbuf, len);
| > | 	wake_up(&dccpw.wait);
| > | }
| > |
| > | static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,struct
| > | msghdr *msg, size_t size) {
| > | 	const struct dccp_minisock *dmsk = dccp_msk(sk);
| > | 	const struct inet_sock *inet = inet_sk(sk);
| > | 	const struct ccid3_hc_tx_sock *hctx;
| > |
| > | 	//babil
| > | 	const struct ccid3_hc_rx_sock *hcrx;
| > | 	struct dccp_li_hist_entry *li_entry, *li_next;
| > | 	struct list_head *list;
| > | 	int i=1;
| > | 	//---
| > |
| > |
| > | //babil
| > |
| > | 	if (dmsk->dccpms_rx_ccid = DCCPC_CCID3)
| > | 	{
| > | 		hcrx = ccid3_hc_rx_sk(sk);
| > | 		list = &hcrx->ccid3hcrx_li_hist;
| > | 	}
| > | 	else
| > | 		hcrx = NULL;
| > |
| > |
| > | 		if (hcrx)
| > | 		{
| > |
| > | 			list_for_each_entry_safe(li_entry, li_next, list, dccplih_node)
| > | 			{
| > | 				printl("\nbabil ");
| > |
| > | 				if (li_entry->dccplih_interval != ~0U)
| > | 				{
| > | 					printl("s[%d]: %d* ",i,li_entry->dccplih_interval);
| > | 					i++;
| > | 				}
| > | 				else
| > | 				{
| > | 					printl("empty loss interval");
| > | 				}
| > |
| > | 				printl("\n");
| > |
| > | 			}
| > | 		}
| > | //---
| > |
| > |
| > |
| > |
| > | 	if (dmsk->dccpms_tx_ccid = DCCPC_CCID3)
| > | 		hctx = ccid3_hc_tx_sk(sk);
| > | 	else
| > | 		hctx = NULL;
| > |
| > |
| > | 	if (port = 0 || ntohs(inet->dport) = port || ntohs(inet->sport) =
| > | port) {
| > |
| > | 		if (hctx)
| > | 		{
| > | 			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %d %u "
| > | 			       "%llu %llu %d %s\n",
| > | 			       NIPQUAD(inet->saddr), ntohs(inet->sport),
| > | 			       NIPQUAD(inet->daddr), ntohs(inet->dport), size,
| > | 			       hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
| > | 			       hctx->ccid3hctx_p, hctx->ccid3hctx_x_calc,
| > | 			       hctx->ccid3hctx_x_recv >> 6,
| > | 			       hctx->ccid3hctx_x >> 6, hctx->ccid3hctx_t_ipi,
| > | ccid3_tx_state_name(hctx->ccid3hctx_state) ); }
| > | 		else
| > | 		{
| > | 			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d\n",
| > | 			       NIPQUAD(inet->saddr), ntohs(inet->sport),
| > | 			       NIPQUAD(inet->daddr), ntohs(inet->dport), size);
| > | 		}
| > |
| > |
| > | 	}
| > |
| > | 	jprobe_return();
| > | 	return 0;
| > | }
| > |
| > | static struct jprobe dccp_send_probe = {
| > | 	.kp	= {
| > | 		.symbol_name = "dccp_sendmsg",
| > | 	},
| > | 	.entry	= JPROBE_ENTRY(jdccp_sendmsg),
| > | };
| > |
| > | static int dccpprobe_open(struct inode *inode, struct file *file)
| > | {
| > | 	kfifo_reset(dccpw.fifo);
| > | 	do_gettimeofday(&dccpw.tstart);
| > | 	return 0;
| > | }
| > |
| > | static ssize_t dccpprobe_read(struct file *file, char __user *buf,
| > | 			      size_t len, loff_t *ppos)
| > | {
| > | 	int error = 0, cnt = 0;
| > | 	unsigned char *tbuf;
| > |
| > | 	if (!buf || len < 0)
| > | 		return -EINVAL;
| > |
| > | 	if (len = 0)
| > | 		return 0;
| > |
| > | 	tbuf = vmalloc(len);
| > | 	if (!tbuf)
| > | 		return -ENOMEM;
| > |
| > | 	error = wait_event_interruptible(dccpw.wait,
| > | 					 __kfifo_len(dccpw.fifo) != 0);
| > | 	if (error)
| > | 		goto out_free;
| > |
| > | 	cnt = kfifo_get(dccpw.fifo, tbuf, len);
| > | 	error = copy_to_user(buf, tbuf, cnt);
| > |
| > | out_free:
| > | 	vfree(tbuf);
| > |
| > | 	return error ? error : cnt;
| > | }
| > |
| > | static struct file_operations dccpprobe_fops = {
| > | 	.owner	 = THIS_MODULE,
| > | 	.open	 = dccpprobe_open,
| > | 	.read    = dccpprobe_read,
| > | };
| > |
| > | static __init int dccpprobe_init(void)
| > | {
| > | 	int ret = -ENOMEM;
| > |
| > | 	init_waitqueue_head(&dccpw.wait);
| > | 	spin_lock_init(&dccpw.lock);
| > | 	dccpw.fifo = kfifo_alloc(bufsize, GFP_KERNEL, &dccpw.lock);
| > | 	if (IS_ERR(dccpw.fifo))
| > | 		return PTR_ERR(dccpw.fifo);
| > |
| > | 	if (!proc_net_fops_create(procname, S_IRUSR, &dccpprobe_fops))
| > | 		goto err0;
| > |
| > | 	ret = register_jprobe(&dccp_send_probe);
| > | 	if (ret)
| > | 		goto err1;
| > |
| > | 	pr_info("DCCP watch registered (port=%d)\n", port);
| > | 	return 0;
| > | err1:
| > | 	proc_net_remove(procname);
| > | err0:
| > | 	kfifo_free(dccpw.fifo);
| > | 	return ret;
| > | }
| > | module_init(dccpprobe_init);
| > |
| > | static __exit void dccpprobe_exit(void)
| > | {
| > | 	kfifo_free(dccpw.fifo);
| > | 	proc_net_remove(procname);
| > | 	unregister_jprobe(&dccp_send_probe);
| > |
| > | }
| > | module_exit(dccpprobe_exit);
| > |
| > | MODULE_PARM_DESC(port, "Port to match (0=all)");
| > | module_param(port, int, 0);
| > |
| > | MODULE_PARM_DESC(bufsize, "Log buffer size (default 64k)");
| > | module_param(bufsize, int, 0);
| > |
| > | MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>");
| > | MODULE_DESCRIPTION("DCCP snooper");
| > | MODULE_LICENSE("GPL");
| 
| 

|    1205200420.821502 s[0] 54 s[1] 0 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 216 i_tot1 216 w_tot 8 i_mean 27 P: 33333
|    1205200420.858257 s[0] 54 s[1] 0 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 216 i_tot1 216 w_tot 8 i_mean 27 P: 32258
|    1205200420.936190 s[0] 54 s[1] 0 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 216 i_tot1 216 w_tot 8 i_mean 27 P: 32258
|    1205200421.53200 s[0] 54 s[1] 0 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 216 i_tot1 216 w_tot 8 i_mean 27 P: 31250
|    1205200421.151307 s[0] 54 s[1] 0 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 216 i_tot1 216 w_tot 8 i_mean 27 P: 30303
|    1205200421.227928 s[0] 54 s[1] 0 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 216 i_tot1 216 w_tot 8 i_mean 27 P: 29411
|    1205200421.306234 s[0] 54 s[1] 0 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 216 i_tot1 216 w_tot 8 i_mean 27 P: 28571
|    1205200421.384223 s[0] 54 s[1] 0 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 216 i_tot1 216 w_tot 8 i_mean 27 P: 27777
|    1205200421.480497 s[0] 54 s[1] 0 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 216 i_tot1 216 w_tot 8 i_mean 27 P: 27027
|    1205200422.604512 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 30303
|    1205200422.645240 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 29411
|    1205200422.704550 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 29411
|    1205200422.778786 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 28571
|    1205200422.859967 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 28571
|    1205200422.953526 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 27777
|    1205200423.33583 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 27027
|    1205200423.108496 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 27027
|    1205200423.226642 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 26315
|    1205200423.304689 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 25641
|    1205200423.386886 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 25641
|    1205200423.654858 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 25000
|    1205200423.732740 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 24390
|    1205200423.809647 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 24390
|    1205200423.924803 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 23809
|    1205200424.26045 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 23255
|    1205200424.83668 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 23255
|    1205200424.177678 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 22727
|    1205200424.273634 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 22222
|    1205200424.338517 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 22222
|    1205200424.606927 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 21739
|    1205200424.857189 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 21276
|    1205200424.954908 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 21276
|    1205200425.13816 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 20833
|    1205200425.111744 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 20408
|    1205200425.208193 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 20408
|    1205200425.272115 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 20000
|    1205200425.498958 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 19607
|    1205200425.712008 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 19607
|    1205200425.810005 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 19230
|    1205200425.869637 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 18867
|    1205200425.962321 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 18867
|    1205200426.60840 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 18518
|    1205200426.141969 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 18181
|    1205200426.218223 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 18181
|    1205200426.334241 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 17857
|    1205200426.412073 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 17543
|    1205200426.491809 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 17543
|    1205200426.566977 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 17241
|    1205200426.661940 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 16949
|    1205200426.761057 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 16949
|    1205200426.824135 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 16666
|    1205200426.917051 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 16393
|    1205200427.33995 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 16393
|    1205200427.93951 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 16129
|    1205200427.185985 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 15873
|    1205200427.267973 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 15873
|    1205200427.363037 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 15625
|    1205200427.446645 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 15384
|    1205200427.517172 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 15384
|    1205200427.614051 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 15151
|    1205200427.712252 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 14925
|    1205200427.770047 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 14925
|    1205200427.888832 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 14705
|    1205200427.963160 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 14492
|    1205200428.43564 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 14492
|    1205200428.141119 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 14285
|    1205200428.219140 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 14084
|    1205200428.311167 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 14084
|    1205200428.391345 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 13888
|    1205200428.470267 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 13698
|    1205200428.583291 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 13698
|    1205200428.683061 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 13513
|    1205200428.743306 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 13333
|    1205200428.837396 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 13333
|    1205200428.917408 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 13157
|    1205200428.999385 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 12987
|    1205200429.91427 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 12987
|    1205200429.166498 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 12820
|    1205200429.265437 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 12658
|    1205200429.362427 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 12658
|    1205200429.443306 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 12500
|    1205200429.538298 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 12345
|    1205200429.619396 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 12345
|    1205200429.694319 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 12195
|    1205200429.788512 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 12048
|    1205200429.867324 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 12048
|    1205200429.946325 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 11904
|    1205200430.62556 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 11764
|    1205200430.140465 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 11764
|    1205200430.216035 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 11627
|    1205200430.313789 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 11494
|    1205200430.392007 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 11494
|    1205200430.486701 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 11363
|    1205200430.566530 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 11235
|    1205200430.646478 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 11235
|    1205200430.761450 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 11111
|    1205200430.816546 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10989
|    1205200430.915507 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10989
|    1205200431.14583 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10869
|    1205200431.93508 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10752
|    1205200431.176626 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10752
|    1205200431.268652 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10638
|    1205200431.345596 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10526
|    1205200431.440672 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10526
|    1205200431.499761 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10416
|    1205200431.616639 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10309
|    1205200431.713711 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10309
|    1205200431.805000 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10204
|    1205200431.885690 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10101
|    1205200431.957723 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10101
|    1205200432.10233 s[0] 22 s[1] 54 s[2] 0 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 304 i_tot1 304 w_tot 12 i_mean 25 P: 10000
|    1205200432.734874 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 12500
|    1205200432.784817 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 12345
|    1205200432.822036 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 12345
|    1205200432.860726 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 12345
|    1205200432.938674 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 12195
|    1205200433.15669 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 12195
|    1205200433.73826 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 12048
|    1205200433.149757 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 12048
|    1205200433.216893 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 11904
|    1205200433.276865 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 11904
|    1205200433.349189 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 11764
|    1205200433.402772 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 11764
|    1205200433.470430 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 11627
|    1205200433.547934 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 11627
|    1205200433.607007 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 11494
|    1205200433.668029 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 11494
|    1205200433.754128 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 11363
|    1205200433.792845 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 11363
|    1205200433.869917 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 11235
|    1205200433.948345 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 11235
|    1205200434.6080 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 11111
|    1205200434.82009 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 11111
|    1205200434.133154 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10989
|    1205200434.210369 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10989
|    1205200434.283467 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10869
|    1205200434.335053 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10869
|    1205200434.406077 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10752
|    1205200434.461209 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10752
|    1205200434.536976 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10638
|    1205200434.598635 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10638
|    1205200434.663993 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10526
|    1205200434.724021 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10526
|    1205200434.801771 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10416
|    1205200434.880736 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10416
|    1205200434.937202 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10309
|    1205200434.997633 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10309
|    1205200435.63150 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10204
|    1205200435.140266 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10204
|    1205200435.190783 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10101
|    1205200435.266051 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10101
|    1205200435.336079 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10000
|    1205200435.392218 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 10000
|    1205200435.473098 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 9900
|    1205200435.529143 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 9900
|    1205200435.600228 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 9803
|    1205200435.655300 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 9803
|    1205200435.732169 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 9708
|    1205200435.808377 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 9708
|    1205200435.868396 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 9615
|    1205200435.927268 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 9615
|    1205200435.994276 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 9523
|    1205200436.75570 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 9523
|    1205200436.124055 s[0] 226 s[1] 22 s[2] 54 s[3] 0 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1208 i_tot1 1208 w_tot 16 i_mean 75 P: 9433
|    1205200437.365740 s[0] 124 s[1] 226 s[2] 22 s[3] 54 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1650 i_tot1 1704 w_tot 19 i_mean 89 P: 10989
|    1205200437.388483 s[0] 124 s[1] 226 s[2] 22 s[3] 54 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1650 i_tot1 1704 w_tot 19 i_mean 89 P: 10989
|    1205200437.395303 s[0] 124 s[1] 226 s[2] 22 s[3] 54 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1650 i_tot1 1704 w_tot 19 i_mean 89 P: 10869
|    1205200437.769384 s[0] 124 s[1] 226 s[2] 22 s[3] 54 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1650 i_tot1 1704 w_tot 19 i_mean 89 P: 10638
|    1205200438.129482 s[0] 124 s[1] 226 s[2] 22 s[3] 54 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1650 i_tot1 1704 w_tot 19 i_mean 89 P: 10416
|    1205200438.725643 s[0] 124 s[1] 226 s[2] 22 s[3] 54 s[4] 0 s[5] 0 s[6] 0 s[7] 0 i_tot0 1650 i_tot1 1704 w_tot 19 i_mean 89 P: 10101
|    1205200439.430591 s[0] 55 s[1] 124 s[2] 226 s[3] 22 s[4] 54 s[5] 0 s[6] 0 s[7] 0 i_tot0 1794 i_tot1 1870 w_tot 21 i_mean 89 P: 11235
|    1205200439.964578 s[0] 55 s[1] 124 s[2] 226 s[3] 22 s[4] 54 s[5] 0 s[6] 0 s[7] 0 i_tot0 1794 i_tot1 1870 w_tot 21 i_mean 89 P: 10869
|    1205200440.627812 s[0] 55 s[1] 124 s[2] 226 s[3] 22 s[4] 54 s[5] 0 s[6] 0 s[7] 0 i_tot0 1794 i_tot1 1870 w_tot 21 i_mean 89 P: 10526
|    1205200456.470724 s[0] 105 s[1] 25 s[2] 79 s[3] 43 s[4] 15 s[5] 53 s[6] 55 s[7] 124 i_tot0 1103 i_tot1 1338 w_tot 23 i_mean 58 P: 16129
|    1205200459.557219 s[0] 100 s[1] 105 s[2] 25 s[3] 79 s[4] 43 s[5] 15 s[6] 53 s[7] 55 i_tot0 1311 i_tot1 1503 w_tot 23 i_mean 65 P: 14285
|    1205200461.55182 s[0] 100 s[1] 105 s[2] 25 s[3] 79 s[4] 43 s[5] 15 s[6] 53 s[7] 55 i_tot0 1311 i_tot1 1503 w_tot 23 i_mean 65 P: 12820
|    1205200462.546994 s[0] 100 s[1] 105 s[2] 25 s[3] 79 s[4] 43 s[5] 15 s[6] 53 s[7] 55 i_tot0 1311 i_tot1 1503 w_tot 23 i_mean 65 P: 11627
|    1205200464.31630 s[0] 100 s[1] 105 s[2] 25 s[3] 79 s[4] 43 s[5] 15 s[6] 53 s[7] 55 i_tot0 1311 i_tot1 1503 w_tot 23 i_mean 65 P: 10638
|    1205200465.511921 s[0] 100 s[1] 105 s[2] 25 s[3] 79 s[4] 43 s[5] 15 s[6] 53 s[7] 55 i_tot0 1311 i_tot1 1503 w_tot 23 i_mean 65 P: 9803
|    1205200467.14072 s[0] 100 s[1] 105 s[2] 25 s[3] 79 s[4] 43 s[5] 15 s[6] 53 s[7] 55 i_tot0 1311 i_tot1 1503 w_tot 23 i_mean 65 P: 9174
|    1205200472.183580 s[0] 47 s[1] 307 s[2] 100 s[3] 105 s[4] 25 s[5] 79 s[6] 43 s[7] 15 i_tot0 2303 i_tot1 2527 w_tot 23 i_mean 109 P: 8474
|    1205200473.867924 s[0] 47 s[1] 307 s[2] 100 s[3] 105 s[4] 25 s[5] 79 s[6] 43 s[7] 15 i_tot0 2303 i_tot1 2527 w_tot 23 i_mean 109 P: 7874
|    1205200475.577739 s[0] 47 s[1] 307 s[2] 100 s[3] 105 s[4] 25 s[5] 79 s[6] 43 s[7] 15 i_tot0 2303 i_tot1 2527 w_tot 23 i_mean 109 P: 7352

| void babil_printk(struct ccid3_hc_rx_sock *hcrx)
| {
| 	
| 	static const int dccp_li_hist_w[DCCP_LI_HIST_IVAL_F_LENGTH] = {	4, 4, 4, 4, 3, 2, 1, 1,};
| 
| 	
| 	struct dccp_li_hist_entry *li_entry, *li_next;
| 	unsigned int i = 1;
| 	u32 i_tot = 0;
| 	u32 i_tot0 = 0;
| 	u32 i_tot1 = 0;
| 	u32 w_tot  = dccp_li_hist_w[0];
| 	u32 i_mean;
| 	struct list_head *list = &hcrx->ccid3hcrx_li_hist;
| 	
| 	u64 s[]={0,0,0,0,0,0,0,0};
| 	
| 	struct timeval now;
| 	
| 	do_gettimeofday(&now);
| 	printk("\nbabil_printk:: now %lu.%03lu ",(unsigned long) now.tv_sec,(unsigned long) now.tv_usec);
| 	
| 	list_for_each_entry_safe(li_entry, li_next, list, dccplih_node) 
| 	{
| 		
| 		if (li_entry->dccplih_interval != ~0U) 
| 		{
| 
| 			i_tot1 += li_entry->dccplih_interval * dccp_li_hist_w[i-1];
| 
| 			if (i != 8) 
| 			{
| 				i_tot0 += li_entry->dccplih_interval * dccp_li_hist_w[i];
| 				w_tot  += dccp_li_hist_w[i];
| 			}
| 		
| 		}
| 		
| 		s[i-1]= (u64)li_entry->dccplih_interval;
| 		
| 		if((u64)s[i-1] >= 4294967295UL) 
| 		{
| 			s[i-1] = 0;
| 		}
| 			
| 		if (++i > (DCCP_LI_HIST_IVAL_F_LENGTH+1))
| 			break;
| 	}
| 	
| 	i_tot = max(i_tot0, i_tot1);
| 	i_mean = i_tot / w_tot;
| 		
| 	printk("s[0] %llu s[1] %llu s[2] %llu s[3] %llu s[4] %llu s[5] %llu s[6] %llu s[7] %llu ",s[0],s[1],s[2],s[3],s[4],s[5],s[6],s[7]);
| 	
| 	printk(" i_tot0 %u i_tot1 %u w_tot %u i_mean %u P: %u \n\n",i_tot0, i_tot1, w_tot,i_mean,hcrx->ccid3hcrx_p);
| 	
| }
| 
| //---


-- 
