From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 16 Jan 2007 21:51:00 +0000
Subject: Question on resetting nominal send time
Message-Id: <5640c7e00701161351q19360335mf2862a31596ae94a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Folks,

While Gerrit and I have been refining the CCID3 implementation in
Linux we have noticed some issues around packet scheduling. I would
like some clarification around this please as I can't find the answers
in the RFCs. It may well be that I have just missed something obvious.

Section 4.6 of RFC3448 talks about calculating the nominal sending
time being the previous nominal sending time plus t_ipi (inter packet
interval).

The aim of this is to allow an average packet rate per second and
section 4.6 explicitly allows bursts of traffic.

This generally works well except for two scenarios that I can think of:

1) The application sends at less than the permitted rate. This means
that the nominal send time becomes further and further in the past for
the current packet. This means we can basically transmit whenever we
want until we catch up in time. I would guess that this is not what is
intended, particularly as it means it will take time to respond to the
beginning of increased loss.

2) The sender becomes idle. However there is no talk of resetting the
nominal sending time. So if we are idle for 10 seconds then when we
become active again we can send 10 seconds worth of packets
instantaneously. I am guessing that this was also not the intent of
the RFC authors.

Can some clarification please be provided or pointing out what I have
missed in the RFCs?

I'm guessing there should be some mechanism for resending the nominal send time.

Regards,

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
