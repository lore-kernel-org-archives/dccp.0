From: gerrit@erg.abdn.ac.uk
Date: Thu, 12 Aug 2010 11:02:33 +0000
Subject: Re: Problems with idle DCCP connections
Message-Id: <48357.148.187.160.35.1281610953.squirrel@148.187.160.35>
List-Id: <dccp.vger.kernel.org>
References: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
In-Reply-To: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> I have also done some testing with CCID-3 (Linux 2.6.35 kernel.org tree)
> and the same symptoms are present there, but much, much less often.
> Maybe once every for every 2 hours the dccp connection is transferring
> data, as apposed to once for every 2 minutes in CCID-2.
>
Looking back at your other post, it is likely that you will see the
same behaviour also with CCID-3 in the test tree.

If I understand your setting of Delay Tolerant Networking correctly, then
this is a connection which has long idle phases.

The old TFRC specification (RFC 3448) penalized such connections (see
RFC 5348, 9.1), the new specification has support for data-limited
intervals (RFC 5348, 4.3), but the code is still at the in-between state
of rfc3448bis which preceded RFC 5348.

Hence it is a good time to add this missing support.

In the meantime, for testing CCID-248 might be of interest
    CONFIG_IP_DCCP_CCID0=y
and then, after modprobe -v dccp,
    echo  248 > /proc/sys/net/dccp/default/tx_ccid
    echo  248 > /proc/sys/net/dccp/default/rx_ccid

