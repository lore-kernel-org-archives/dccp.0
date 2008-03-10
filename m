From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 10 Mar 2008 12:00:07 +0000
Subject: Re: Reporting possible bug in DCCP Feature negotiation
Message-Id: <20080310120007.GA27832@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570803061215s36fac06ctc2015cc2d079ea9@mail.gmail.com>
In-Reply-To: <5bc4c4570803061215s36fac06ctc2015cc2d079ea9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > | Hi Gerrit, during some experiments using iperf to transmit one TCP
| >  | flow against 3 DCCP flows, one DCCP thread stopped and it was shown
| >  | the following message:
| >  |
| >  | "[ 6286.864021] BUG: Failed negotiation in state 2 at
| >  | net/dccp/feat.c:1370/dccp_feat_activate_values()"
| >  |
| >  Did it really stop? The trigger is only possible during the initial
| >  handshake, this is the only place where this activation-code is
| >  executed. So almost certainly it failed at the begin of the connection.
| 
| I started 3 DCCP connection, just 2 transmitted. Then the third is the
| one that had the problem.
| 
<snip>
| 
| Yes, the same version of DCCP. I repeated the same scenario and this
| situation didn't happened anymore
| 
Thank you for checking again. It seems that this may be some kind of
timing problem: 2 parallel connections succeeded, the third could not
negotiate its features. I will try to reproduce this, so far parallel
connections of up to 4 streams worked without glitches.

In the test kernel I have changed the statement from dccp_pr_debug in
feat.c to DCCP_CRIT:

activation_failed:
        DCCP_CRIT("Activation of %s failed", idx < 0 ? "unknown feature" :
                  dccp_feat_fname(dccp_feat_table[idx].feat_num));

So that, should the problem re-appear, the feature name will be printed.


| > | [ 4853.013621] dccp_ackvec_add_new: Warning: large burst loss (583)
| > | [ 5690.125731] dccp_ackvec_add_new: Warning: large burst loss (943)
| > | [ 5747.246785] dccp_ackvec_add_new: Warning: large burst loss (76)
| > | [ 6301.420651] dccp_ackvec_add_new: Warning: large burst loss (77)
| >  I have collated these messages - there is quite a lot of loss going on
| >  and I am wondering whether the Ack Vectors are properly dimensioned.
| 
| Hum... this is one thing to check. For my situation (wifi and ethernet
| link), what do you suggest to use. To properly dimension Ack vectors,
| do I need just to set the parameters like that?:
| 
| sudo sysctl -w net.dccp.default.seq_window000
| sudo sysctl -w net.dccp.default.send_ackvec=1
The short answer is - tuning is not necessary, the Ack Vectors should
take care of this themselves. 

Long answer: The above warning messages indicate that the Ack Vectors switch
from "linear mode" (where one cell is allocated for each missing packet) to
"compressed mode" (where the burst loss is compressed in the minimum number
of cells). 

The disadvantage/trade-off is that in compressed mode no changes are possible,
i.e. if the burst was in part due to reordering, subsequent acknowledgments
will not change this. On the other hand, linear mode is impracticable for all
but the most trivial scenarios, since it has huge demands on memory - in
the order of O(burst_length). This can lead to "fun" when using a
high-speed link in combination with high Ack Ratio.
