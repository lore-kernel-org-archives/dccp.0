From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 29 Nov 2006 19:42:33 +0000
Subject: Setup of CCIDs
Message-Id: <5640c7e00611291142w476280a7r56470a2b1913a779@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

One more thing. I've found you have to set sysctls to get the setup
right (particularly around seq_window size and ackvecs.

Here is the script I use for CCID3:
#
sudo modprobe dccp
sudo modprobe dccp_ccid3
sudo sysctl -w net.dccp.default.seq_window000
sudo sysctl -w net.dccp.default.send_ackvec=0
sudo sysctl -w net.dccp.default.rx_ccid=3
sudo sysctl -w net.dccp.default.tx_ccid=3

and CCID2:
#
sudo modprobe dccp
sudo modprobe dccp_ccid2
sudo sysctl -w net.dccp.default.seq_window000
sudo sysctl -w net.dccp.default.send_ackvec=1
sudo sysctl -w net.dccp.default.rx_ccid=2
sudo sysctl -w net.dccp.default.tx_ccid 

My opinion is that the send_ackvec should automatically change in the
code when you change CCIDs. The default_seq_window increases from the
default specified in the RFC of 100.

Ian

On 11/30/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> Hi Leandro,
>
> I'm doing some tests again today.
>
> Have you got some code/results you can share?
>
> Also can you both try 2.6.19 and see what that is like in comparison?
>
> Also are you using CCID2 or CCID3?
>
> Ian
>
> On 11/30/06, Leandro Melo de Sales <leandroal@gmail.com> wrote:
> > Hi...
> >
> >    I'm in the same situation of Burak, I started working with DCCP
> > again and facing similar problems. Any clue?
> >
> > Leandro.
> >
> > 2006/11/29, Ian McDonald <ian.mcdonald@jandi.co.nz>:
> > > Burak,
> > >
> > > There are a lot of changes going on at present in the tree. I'm going
> > > to test later today to verify them.
> > >
> > > Are you able to give sample code?
> > >
> > > Ian
> > >
> > > On 11/30/06, burak gorkemli <burakgorkemli@yahoo.com> wrote:
> > > > Hi Ian,
> > > >
> > > > After a little gap, I started working with DCCP again. I have downloaded Dave's 2.6.20 tree  and started using the DCCP implementation as out-of-the-box, i.e. without applying your patches. However, I am facing strange problems with that implementation: after sending 4-5 packets, the sender side becomes unable to send any more packets, despite of returning success code in the application layer - send API returns value > 0.
> > > >
> > > > Any comments?
> > > >
> > > > Thanks in advance,
> > > > Burak Gorkemli
> > > > PhD. Candidate
> > > > Koc University
> > > > Turkey
> > > >
> > > >
> > > >
> > >
> > >
> > > --
> > > Ian McDonald
> > > Web: http://wand.net.nz/~iam4
> > > Blog: http://imcdnzl.blogspot.com
> > > WAND Network Research Group
> > > Department of Computer Science
> > > University of Waikato
> > > New Zealand
> > > -
> > > To unsubscribe from this list: send the line "unsubscribe dccp" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > >
> >
>
>
> --
> Ian McDonald
> Web: http://wand.net.nz/~iam4
> Blog: http://imcdnzl.blogspot.com
> WAND Network Research Group
> Department of Computer Science
> University of Waikato
> New Zealand
>


-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
