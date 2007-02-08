From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 08 Feb 2007 00:29:58 +0000
Subject: Re: [dccp] Question on resetting nominal send time
Message-Id: <45CA6F06.3040107@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00701161351q19360335mf2862a31596ae94a@mail.gmail.com>
In-Reply-To: <5640c7e00701161351q19360335mf2862a31596ae94a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Ian,

Sorry for the delay in responding.

I agree that the t_ipi implementation sketched in RFC3448 Section 4.6 is 
incomplete with respect to slow applications, idle periods, and the like. :(

What follows is a first cut at a solution.  Any thoughts from others??

If t_ipi is used to schedule transmissions, then the following equation should 
be applied each time the application is scheduled:

    t_ipi := max(t_ipi, t_now - RTT/2)

This never lets t_ipi fall more than 1/2 RTT behind the current time.  An 
application is still allowed to send packets in a small burst after an idle 
period, but the size of that burst is limited to RTT/2 worth of packets.

RTT/2 was chosen because senders can send 2*last_receive_rate in any RTT.

I am sure that this simple choice has disadvantages, such as little bursts at 
the beginnings of idle periods.  One could be more conservative and set e.g.

     t_ipi := max(t_ipi, t_now - t_gran).

But I think RTT/2 might be OK.  Implementation experience would be preferred.

This issue is really an implementation issue.  RFC3448 4.6 is not exactly 
normative; it discusses one way to achieve a send rate, not a required 
implementation.  So in some sense the implementer is free to choose anything 
reasonable.

Eddie


Ian McDonald wrote:
> Folks,
> 
> While Gerrit and I have been refining the CCID3 implementation in
> Linux we have noticed some issues around packet scheduling. I would
> like some clarification around this please as I can't find the answers
> in the RFCs. It may well be that I have just missed something obvious.
> 
> Section 4.6 of RFC3448 talks about calculating the nominal sending
> time being the previous nominal sending time plus t_ipi (inter packet
> interval).
> 
> The aim of this is to allow an average packet rate per second and
> section 4.6 explicitly allows bursts of traffic.
> 
> This generally works well except for two scenarios that I can think of:
> 
> 1) The application sends at less than the permitted rate. This means
> that the nominal send time becomes further and further in the past for
> the current packet. This means we can basically transmit whenever we
> want until we catch up in time. I would guess that this is not what is
> intended, particularly as it means it will take time to respond to the
> beginning of increased loss.
> 
> 2) The sender becomes idle. However there is no talk of resetting the
> nominal sending time. So if we are idle for 10 seconds then when we
> become active again we can send 10 seconds worth of packets
> instantaneously. I am guessing that this was also not the intent of
> the RFC authors.
> 
> Can some clarification please be provided or pointing out what I have
> missed in the RFCs?
> 
> I'm guessing there should be some mechanism for resending the nominal 
> send time.
> 
> Regards,
> 
> Ian
