From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 20 Oct 2009 05:09:27 +0000
Subject: Re: Doubt in implementations of mean loss interval at sender side
Message-Id: <20091020050927.GA4982@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <4AD4B861.7040107@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B861.7040107@embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| It considers if an interval is 2 RTT old, instead of 2 RTT long. But I
| sent this code in this state anyway, because I want to ask how to solve
| this problem.
This is a good point. Personally, I can not really see an advantage in
storing old data at the sender, as it seems to increase the complexity,
without at the same time introducing a benefit.

Adding the 'two RTTs old' worth of information at the sender re-introduces 
things that were removed already. The old CCID-3 sender used to store
a lot of information about old packets, now it is much leaner and keeps
only the minimum required information.

Your receiver already implements '2 RTTs long':
tfrc_sp_lh_interval_add():

        /* Test if this event starts a new loss interval */
        if (cur != NULL) {
                s64 len = dccp_delta_seqno(cur->li_seqno, cong_evt_seqno);
		
		// ...

                cur->li_length = len;

                if (SUB16(cong_evt->tfrchrx_ccval, cur->li_ccval) <= 8)
                        cur->li_is_short = 1;
        }

Would it help your implementation if the receiver had a more precise measure
for "2 RTT long"? A while ago I got fed up with the imprecise RTT measurements
that the receiver produced when using the CCVal to compute the RTT. The
suggestion was that the sender would supply its RTT estimate via an option,

    "Sender RTT Estimate Option for DCCP"
    http://tools.ietf.org/html/draft-renker-dccp-tfrc-rtt-option-00

If the receiver knew the RTT, it could subtract timestamps and compare
these against the RTT value. Currently, with the CCVal it is (as for
the receiver-based RTT estimation), a bit difficult. RFC 5622, 8.1:

 "None of these procedures require the receiver to maintain an explicit
  estimate of the round-trip time. However, Section 8.1 of [RFC4342]
  gives a procedure that implementors may use if they wish to keep such
  an RTT estimate using CCVal."

But the problem is that the algorithm in section 8.1 of RFC 4342 (which
is used by the CCID-3/4 receiver has already proven not to be very reliable,
it suffers from similar problems as the packet-pair technique.

As a second point, I still think that a receiver-based CCID-4 implementation
would be the simplest possible starting point. In this light, do you see an
advantage in supplying an RTT estimate from sender to receiver?
