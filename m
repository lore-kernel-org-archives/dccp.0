From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 18 Jun 2007 02:05:40 +0000
Subject: [PATCH 0/4]: DCCP ktime_t initial work
Message-Id: <20070618020540.GA4226@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.23

	I briefed Thomas Gleixner about the new ktime_us_delta and
ktime_add_us functions and he is OK with having them added to ktime.h.

	More work on this are going on Gerrit Renker's experimental tree
that I plan to review and cherry pick soon, thanks Gerrit for all the
hard work!

Best Regards,

- Arnaldo
