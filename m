From: gerrit@erg.abdn.ac.uk
Date: Sun, 31 May 2009 17:02:01 +0000
Subject: Re: DCCP socket option TX/RX info
Message-Id: <47722.148.187.160.35.1243789321.squirrel@148.187.160.35>
List-Id: <dccp.vger.kernel.org>
References: <37b5be5c0905280716o4ed3132bpcdc7f2b84a682f40@mail.gmail.com>
In-Reply-To: <37b5be5c0905280716o4ed3132bpcdc7f2b84a682f40@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> - RFC 3448 (3.2.2): "X_recv is the receiver estimate of sending rate
> which is sent by the receiver to the sender";
> X_recv matches the value of tfrcrx_x_recv in the struct tfrc_rx_info,
> and the value of tfrctx_x_recv in struct tfrc_rx_info,
> so the issue is that values of (tfrctx_x_recv,tfrcrx_x_recv) are
> different, is it normal?
In theory this reasoning is correct, in practice it is complicated
by the fact that the kernel can not do floating-point calculations;
therefore all integer arithmetic is scaled (by 2^6 = 64), to avoid
(i) inaccuracies, and (ii) divide-by-zero errors which result from
truncating on integer division.

The short answer to the question is in <linux/tfrc.h>,

  "X and X_recv are both maintained in units of 64 * bytes/second.
   This enables a finer resolution of sending rates and avoids problems
   with integer arithmetic; u32 is not sufficient as scaling consumes 6
   bits."

The longer answer is on
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3/CCID3_Computation_of_Rates.txt

The scaling factor of 64 is balanced, to avoid both over- and underflow.


> - if these values should be the same, why in the code source tfrc.h,
> tfrcrx_x_recv is declared as _U32, and tfrctx_x_recv as _U64?

The receiver merely counts the bytes and does not need to recompute X.
Yet, even here it uses u64 behind the scenes. u32 is sufficient here
since this matches the format of the tag-length-value option that the
receiver fills in.

At the sender, scaling is necessary to avoid truncation upon division.
To avoid inconsistencies, nearly everything in the TX code is scaled
by 2^6, even the rfc3390_initial_rate() to compute X_init.

This continues when passing on the information via the
DCCP_SOCKOPT_CCID_TX_INFO socket call to user space: instead of
truncating to 0, it allows fractional values smaller than 1.

Here is a snippet of user-space code to do the conversion:

 tfrc_get_tx_info(fd, &tfrc);
    if (memcmp(&tfrc, &tfrc_last, sizeof(tfrc))) {
        err_msg("%.6f\t%-9u %-9u %-6u", elapsed_secs(&time0),
                (unsigned) (tfrc.tfrctx_x_recv >> 6), tfrc.tfrctx_rtt,
tfrc.tfrctx_p);
        tfrc_last = tfrc;
    }

This is from the modified ttcp.c bundled with
http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/dccp_applications_lib.tar.gz

However, if you want to look at these values in real-time, it is
better to use dccp_probe, some information is on
http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/


> And a question:
>
> - on the sender, is it possible that the application know about the
> buffer length at the DCCP level (i.e. how many packets are awaiting to
> be sent)?
>
This is not currently supported, there had been initial work by Tomasz
Grobelny on priority queues (his patches are in the test tree, please
see below).

NOTE: for all sorts of development work, please consider using the test
tree. The mainline tree is reasonably up to date with regards to bug fixes,
but lacks the development patches introducing more recent features and
improving on earlier code. Information about this is on
http://www.linuxfoundation.org/en/Net:DCCP_Testing#Experimental_DCCP_source_tree

