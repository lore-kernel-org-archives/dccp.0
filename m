From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 30 Aug 2021 08:50:35 +0000
Subject: [syzbot] BUG: please report to dccp@vger.kernel.org => prev = NUM, last = NUM at net/dccp/ccids/lib/
Message-Id: <20210830085035.2763839-1-dvyukov@google.com>
List-Id: <dccp.vger.kernel.org>
References: <20180408215707.GE685@sol.localdomain>
In-Reply-To: <20180408215707.GE685@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the same as:

#syz dup: BUG: please report to dccp@vger.kernel.org => prev = 0, last = 0 at net/dccp/ccids/lib/packet_history.c:LINE/tfrc_rx_hist_sample_rtt()

https://syzkaller.appspot.com/bug?id81c535c265ca965edc49c0ac3d0a9850d26eb1
