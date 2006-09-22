From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 22 Sep 2006 10:37:45 +0000
Subject: Re: [PATCH 5/7] [DCCP]: Introduce two new socket options
Message-Id: <200609221137.45879@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200609221430.14555.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221430.14555.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  This creates two new socket options DCCP_SOCKOPT_TX_PACKET_SIZE
|  and DCCP_SOCKOPT_RX_PACKET_SIZE. DCCP_SOCKOPT_PACKET_SIZE doesn't
|  work and packet size should be set independently on two half
|  connections.
I disagree with this solution: it solves one problem by introducing two
new ones:

 * the options are redundant:
     --at the sender the packet size is implicitly communicated via the 
       `len' argument of dccp_sendmsg()
     --the receiver samples the packet sizes of incoming packets

 * it makes the programming interface more complex; currently these options
   only work for CCID 3 (cf. patch 6/7)

 * both CCID 2/3 are for fixed-packet sizes anyway, and the upcoming
   CCID 4 draft-ietf-dccp-tfrc-voip-05.txt looks much rather like a 
   fixed `mini' packet size rather than a variable-size protocols

 * for varying packet sizes, the sender should calculate the mean/avg
   packet size by itself, rather than relying on information. For TFRC, 
   [draft-floyd-rfc3448bis-00, sec. 4.1] suggests here:
      "where the segment size varies depending on the data, the sender MAY estimate the
       segment size s as the average segment size over the last four loss intervals."

In summary, I think it would be better to let the sender/receiver determine the 
packet size from already available data. That is, derive s from the `len' of dccp_sendmsg(),
and use a weighted-average mechanism like
                       s  =   q * len  +  (1-q) * s
to smooth out variations: in accordance with draft-floyd-rfc3448bis-00.

-- Gerrit
