From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Jan 2007 07:56:34 +0000
Subject: Re: [PATCH 1/1] DCCP: Fix up t_nom - FOLLOW-UP
Message-Id: <200701150756.35069@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701101021.38920@strip-the-willow>
In-Reply-To: <200701101021.38920@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > I have a snapshot which illustrates this state:
|  >
|  >  http://www.erg.abdn.ac.uk/users/gerrit/dccp/dccp_probe/examples/no_tx_locking/transmit_rate.png
|  >
|  > The oscillating behaviour is well visible. In contrast, I am sure that you would agree that the
|  > desirable state is the following:
|  >
|  >  http://www.erg.abdn.ac.uk/users/gerrit/dccp/dccp_probe/examples/with_tx_locking/transmit_rate.png
|  >
|  
|  Questions on the graphs:
|  - are these direct connect nodes?
The nodes are on the same Ethernet LAN, connected via 100Mbps / 1GBps interfaces. There is no
other traffic on that LAN.
|  - why is Xcalc 0?
Since no losses occurred (p is always 0 on these tests).
|  - why on the stable one is Xrecv different from X. Is X the rate that
|  it is allowed to send at but doesn't so only achieves Xrecv?
When there is no loss, X = max(min(2*X, 2*X_recv), s/R) - the graph agrees with this, since
X is about 2*X_recv.
