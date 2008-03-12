From: Steven Brown <swbrown@variadic.org>
Date: Wed, 12 Mar 2008 22:19:26 +0000
Subject: 'err=-113 after ccid_hc_tx_packet_sent'
Message-Id: <47D856EE.2030102@variadic.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I've been seeing these errors fairly regularly in all the kernels I've
tried it with for the past few months (the most recent being the test
tree as of 2008-03-04) - I suspect that it's also the cause of close() 
sometimes blocking (can be ^Ced).  Using the default settings (CCID2, 
etc.) with an updated .config from Debian's 2.6.24.

BUG: err=-113 after ccid_hc_tx_packet_sent at
net/dccp/output.c:280/dccp_write_xmit()
Pid: 14115, comm: test Not tainted 2.6.25-rc3-dccp-200803041 #3
  [<d0141401>] ccid2_hc_tx_packet_sent+0x0/0xad [dccp_ccid2]
  [<d01551f7>] dccp_write_xmit+0x21e/0x29a [dccp]
  [<c024909d>] lock_sock_nested+0x75/0x7c
  [<c024d611>] memcpy_fromiovec+0x28/0x4b
  [<d01567a3>] dccp_sendmsg+0x127/0x14b [dccp]
  [<c0288ce4>] inet_sendmsg+0x35/0x3f
  [<c02475d0>] sock_sendmsg+0xc6/0xe0
  [<c012784f>] autoremove_wake_function+0x0/0x2d
  [<c016c999>] core_sys_select+0x1d0/0x2a4
  [<c0172ee8>] mntput_no_expire+0x11/0x55
  [<c0247e86>] sys_sendto+0xf9/0x124
  [<c012784f>] autoremove_wake_function+0x0/0x2d
  [<c0247eca>] sys_send+0x19/0x1d
  [<c024874d>] sys_socketcall+0xed/0x19e
  [<c0104792>] syscall_call+0x7/0xb

