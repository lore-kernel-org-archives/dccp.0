From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
Date: Tue, 22 Apr 2008 02:40:42 +0000
Subject: Re: [PATCH] [DCCP]: Convert do_gettimeofday() to getnstimeofday().
Message-Id: <20080422.114042.70459573.yoshfuji@linux-ipv6.org>
List-Id: <dccp.vger.kernel.org>
References: <20080421.023503.242108516.davem@davemloft.net>
In-Reply-To: <20080421.023503.242108516.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In article <20080421.142857.234288906.davem@davemloft.net> (at Mon, 21 Apr 2008 14:28:57 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> Thanks for reviewing, patch applied.

Sorry I have just realized set_normalized_timespec() (used in timespec_sub())
is not exported, and link will fail because of it...

What should I/we do?  Send the patch to LKML as well?

---

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
diff --git a/kernel/time.c b/kernel/time.c
index a5ec013..35d373a 100644
--- a/kernel/time.c
+++ b/kernel/time.c
@@ -379,6 +379,7 @@ void set_normalized_timespec(struct time
 	ts->tv_sec = sec;
 	ts->tv_nsec = nsec;
 }
+EXPORT_SYMBOL(set_normalized_timespec);
 
 /**
  * ns_to_timespec - Convert nanoseconds to timespec


--yoshfuji
