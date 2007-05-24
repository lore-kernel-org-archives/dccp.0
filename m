From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 24 May 2007 21:30:43 +0000
Subject: Re: problem with CCID3 loss events
Message-Id: <5640c7e00705241430v72fb64fey55b938a150e3b9ee@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <9442.39900.qm@web30009.mail.mud.yahoo.com>
In-Reply-To: <9442.39900.qm@web30009.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 5/25/07, Burak Gorkemli <burakgmail-dccp@yahoo.com> wrote:
> Hi Ian,

Hi Burak,

Adding DCCP @ vger as I think you mistakenly added DCCP @ ietf to the mailing...

> Last but not the least, I have discovered that I am having some trouble with the sizes of the packets sent. When the packet sizes are equal to each other - which is not the actual case in my tests - everything goes fine. However, when they are not, DCCP behaves strangely, it halts for some period of time during the stream - I think due to the mismatch between the sizes of the packets sent and the average packet size used in the TCP equation. I must confess that I am not aggregating smaller packets into larger ones - which is the next thing that I will do - but I was not expecting such a big effect. I will post the test results later, as I implement packet aggregation.

CCID3 in Linux keeps a moving average of the packet size. If you look
at the TFRC equation  the rate = some numbers / packet size. In effect
CCID3 therefore becomes rate limited by packets per second as it does
not perform packet aggregation within the protocol (unlike TCP). This
would explain your results in this regard.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
