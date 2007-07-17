From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 17 Jul 2007 04:16:09 +0000
Subject: Re: [PATCH 0/10]: Support for passive close
Message-Id: <5640c7e00707162116y1553b91fp74d0b998b78e84e1@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200707121520.48349@strip-the-willow>
In-Reply-To: <200707121520.48349@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi there Gerrit,

On 7/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I am sending the last two batches in my current patch set; both
> are concerned with ensuring correct behaviour on closing a DCCP
> connection. This requires the use of intermediate states, details
> are described on

I'm not 100% sure about this patch set. I'm not saying you're wrong,
just wondering if there's a simpler way.
>
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/closing_states/
>
OK - here is the first part from that website:

>1. General
>DCCP has no half-closed states, i.e. it has no analogue of TCP's
CLOSE_WAIT (passive
> half-close) and FIN_WAIT_1 (active half-close) states; cf. section 4.6 of RFC 4340.

Agree

> The receiver of a CloseReq or Close packet is asked to subsequently close its end of the > connection, and to acknowledge connection termination by sending a Close or Reset
> packet, respectively (RFC 4340, 8.3). Before sending such confirmation, the receiver of a
> connection-termination request needs to have a chance to process yet-unread data of its
> receive queue. Otherwise, immediately following through with a connection-termination
> request has the same effect as an abortive release of the connection: unread data is
> discarded, leading to unexpected API behaviour.

Agree totally with this part. Data has to be read.

> For example, it was observed in the Linux implementation that immediately replying with a
> Close to a CloseReq has the undesirable consequence of removing all unread data
> whenever the Reset answering the Close arrived too early; data was sent to the receiver
> (and could be captured on the wire), but the receiver never got a chance to read it.

And herein lies the problem. But I have, possible, another solution in mind.
- receive CloseReq from server
- client sends Close immediately (without putting at tail of queue)
- server sends Reset
- client receives Reset but does NOT tear down connection immediately
because as per Section 5.6 of RFC4340 there is a reset code. If this
is code 1 then it is a normal connection close
- client processes all packets in receive queue
- client tears down connection

> Therefore, Close and CloseReq packets should be enqueued in the receive queue so that
> required confirmation of connection-termination is produced after all previously-received
> data has been processed.

The other cases where client sends close don't matter as if client is
sending close it should be ready to die.

With your solution the server has to keep track of state longer as it
is waiting for a userspace program to read all packets before
acknowledging closereq. For a server with many short lived flows this
could be significant.

I suspect the method I outline would be a relatively simple fix to the
existing code but I haven't looked at it yet.

Please note your method works perfectly fine and is an acceptable fix,
and can go in. My method may not even work as I'm thinking out loud
here really.

Would appreciate your comments.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
