From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 29 Jul 2006 20:54:19 +0000
Subject: Re: how to choose ccid3 in ttcp
Message-Id: <5640c7e00607291354s3435de2ax3229804e17173fd@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20060727101530.12584.qmail@web30001.mail.mud.yahoo.com>
In-Reply-To: <20060727101530.12584.qmail@web30001.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/27/06, burakgmail-dccp@yahoo.com <burakgmail-dccp@yahoo.com> wrote:
> Hi,
>
> I started using ttcp (ttcp_acme actually) to test DCCP in my linux box (v2.6.17.7). I did some initial tests with ccid2, but could not manage switching to ccid3. How can I make ttcp to use ccid3?
>
> Thanks.
> Burak Gorkemli
> Ph.D. Candidate
> Koc University
> Turkey
>
>
I would actually recommend using iperf as a side remark.

You need to set the default ccid to 3 as 2 is the default and ttcp
doesn't allow you to chose the CCID. Here is a script I use for setup:

sudo modprobe dccp
sudo modprobe dccp_ccid3
sudo sysctl -w net.dccp.default.seq_window000
sudo sysctl -w net.dccp.default.send_ackvec=0
sudo sysctl -w net.dccp.default.rx_ccid=3
sudo sysctl -w net.dccp.default.tx_ccid=3

send_ackvec should be turned off for CCID3 and the seq_window is for
connections that get out of sync (but you need a recent git tree for
the fix).

CCID3 performance has some issues which I'm working on at present too.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
