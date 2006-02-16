From: Ian McDonald <imcdnzl@gmail.com>
Date: Thu, 16 Feb 2006 23:49:07 +0000
Subject: [BUG} DCCP - CCID2 Re: [RFC] CCID infrastructure improvements
Message-Id: <cbec11ac0602161549p37e1120l6f7fce3e345ad246@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> As a baseline I downloaded acme-net-2.6.17.git and did some testing.
> When I test with netem in the middle between two boxes the transmitter
> locks solid....
>
> Test
> ./ttcp_acme -c -l500 -n100 -t jandi2
> ./ttcp_acme -c -l500 -r
>
> Netem configured as follows in middle box:
> sudo tc qdisc add dev lan1 root netem delay 50ms loss 10%
> sudo tc qdisc add dev lan0 root netem delay 50ms loss 10%
>
> I don't believe this happens with older version of DCCP (just pre
> CCID2) so I will start trying to track down....
>
> I don't have so much time so may take a little while. Feel free to
> investigate earlier if you wish.
>
OK. Run some more tests. This occurs only in CCID2 in
acme/net-2.6.17.git. CCID3 is fine without CCID2 compiled in from
.config. My transmit buffering is not OK either but that has not been
merged. Only occurs when I use netem in the middle. Locks the machine
solid on the transmitter but the receiver is OK.

Over to you Andrea unless I get further time to look at but not likely
for a few days at least...

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
