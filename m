From: David Miller <davem@davemloft.net>
Date: Fri, 25 Apr 2008 20:58:16 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080425.135816.197801806.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 25 Apr 2008 17:40:24 -0300

> I haven't read all the patches, but I guess Tomasz is on the safe side
> as the intended skb->priority usage is limited to DCCP, when IP is
> handed the skb it can do as it pleases with skb->priority.

Great.
